#!/bin/bash

. ./path.sh || exit 1
. ./cmd.sh || exit 1

lm_order=3     # language model order (n-gram quantity) - 1 is enough for digits grammar

home="$PWD"
lexicon="$static/lexicon/word2phone"
corpus="$static/corpus/corpus_orig.txt"


# Refine corpus
rm -rf data/local/lex/notpresent.txt data/local/lang data/lang data/local/tmp data/local/dict/lexiconp.txt

echo "---- Refining Word Corpus and Preparing Word Phone Map ----"
. $home/local/refine_corpus.sh $corpus $static/corpus/corpus.txt
[[ . $home/local/gen_word2ph.sh $corpus $lexicon $lex/notpresent.txt ]] || { exit 1; }

echo "---- Preparing Phone Corpus ----"

python3 local/prep_corpus.py $lexicon $corpus > $home/data/local/corpus.txt

echo "---- Preparing Language data ----"
utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang

echo
echo "===== LANGUAGE MODEL CREATION ====="
echo "===== MAKING lm.arpa ====="
echo

loc=`which ngram-count`;
if [ -z $loc ]; then
    echo "================ ngram-count found ================"
    if uname -a | grep 64 >/dev/null; then
        sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64 
    else
            sdir=$KALDI_ROOT/tools/srilm/bin/$os   # [MODIFY] Check the path here
      fi
      if [ -f $sdir/ngram-count ]; then
            echo "Using SRILM language modelling tool from $sdir"
            export PATH=$PATH:$sdir
      else
            echo "SRILM toolkit is probably not installed.
              Instructions: tools/install_srilm.sh"
            exit 1
      fi
fi

# if vocab greater than 20k , truncate vocab file and add --vocab= vocabfile to ngram-count

local=data/local
mkdir $local/tmp
touch $local/tmp/lm.arpa    # [MODIFY]Palak Required to create this file
ngram-count -order $lm_order -write-vocab $local/tmp/vocab-full.txt -wbdiscount -text $local/corpus.txt -lm $local/tmp/lm.arpa

echo
echo "===== MAKING G.fst ====="
echo

lang=data/lang
cat $local/tmp/lm.arpa | arpa2fst - | fstprint | utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=$lang/words.txt --osymbols=$lang/words.txt --keep_isymbols=false --keep_osymbols=false | fstrmepsilon | fstarcsort --sort_type=ilabel > $lang/G.fst

echo "===== LANGUAGE MODEL CREATED at $lang/G.fst ====="
