#!/bin/bash

. local/path.sh || exit 1
. local/cmd.sh || exit 1

nj=1         # number of parallel jobs - 1 is perfect for such a small data set
lm_order=3     # language model order (n-gram quantity) - 1 is enough for digits grammar
os="macosx"
# Safety mechanism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; } 

# Removing previously created data (from last run.sh execution)
# rm -rf exp data/train/spk2utt data/train/cmvn.scp data/train/feats.scp data/train/split1 
# rm -rf data/test/spk2utt data/test/cmvn.scp data/test/feats.scp data/test/split1 data/local/lang data/lang data/local/tmp data/local/dict/lexiconp.txt

# echo
# echo "===== PREPARING ACOUSTIC DATA ====="
# echo

# # Needs to be prepared by hand (or using self written scripts): 
# #
# # spk2gender    [<speaker-id> <gender>]
# # wav.scp    [<uterranceID> <full_path_to_audio_file>]
# # text        [<uterranceID> <text_transcription>]
# # utt2spk    [<uterranceID> <speakerID>]
# # corpus.txt    [<text_transcription>]

# # Making spk2utt files
# utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt

# echo
# echo "===== FEATURES EXTRACTION ====="
# echo

# # DONT generate features again and again
# # Making feats.scp files
# mfccdir=mfcc
# utils/validate_data_dir.sh data/train # data/test   # script for checking if prepared data is all right
# # utils/fix_data_dir.sh data/train          # tool for data sorting if something goes wrong above
# steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj $nj --cmd "$train_cmd" data/train exp/make_mfcc/train $mfccdir

# # Making cmvn.scp files
# steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir

# echo
# echo "===== PREPARING LANGUAGE DATA ====="
# echo

# # Needs to be prepared by hand (or using self written scripts): 
# #
# # lexicon.txt        [<word> <phone 1> <phone 2> ...]        
# # nonsilence_phones.txt    [<phone>]
# # silence_phones.txt    [<phone>]
# # optional_silence.txt    [<phone>]

# # Preparing language data
# utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang

# echo
# echo "===== LANGUAGE MODEL CREATION ====="
# echo "===== MAKING lm.arpa ====="
# echo

# loc=`which ngram-count`;
# if [ -z $loc ]; then
#     echo "================ ngram-count found ================"
#     if uname -a | grep 64 >/dev/null; then
#         sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64 
#     else
#             sdir=$KALDI_ROOT/tools/srilm/bin/$os   # [MODIFY] Check the path here
#       fi
#       if [ -f $sdir/ngram-count ]; then
#             echo "Using SRILM language modelling tool from $sdir"
#             export PATH=$PATH:$sdir
#       else
#             echo "SRILM toolkit is probably not installed.
#               Instructions: tools/install_srilm.sh"
#             exit 1
#       fi
# fi
 
# local=data/local
# mkdir $local/tmp
# touch $local/tmp/lm.arpa    # [MODIFY]Palak Required to create this file
# ngram-count -order $lm_order -write-vocab $local/tmp/vocab-full.txt -wbdiscount -text $local/corpus.txt -lm $local/tmp/lm.arpa

# echo
# echo "===== MAKING G.fst ====="
# echo

# lang=data/lang
# cat $local/tmp/lm.arpa | arpa2fst - | fstprint | utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=$lang/words.txt --osymbols=$lang/words.txt --keep_isymbols=false --keep_osymbols=false | fstrmepsilon | fstarcsort --sort_type=ilabel > $lang/G.fst

echo
echo "===== MONO TRAINING ====="
echo

steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono  || exit 1

echo
echo "===== MONO DECODING ====="
echo

utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph || exit 1
# steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/mono/graph data/test exp/mono/decode

echo
echo "===== MONO ALIGNMENT =====" 
echo

steps/align_si.sh --use-graphs true --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono exp/mono_ali || exit 1

echo
echo "===== TRI1 (first triphone pass) TRAINING ====="
echo

steps/train_deltas.sh --cmd "$train_cmd" 2000 10000 data/train data/lang exp/mono_ali exp/tri1 || exit 1

echo
echo "===== TRI1 (first triphone pass) DECODING ====="
echo

utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph || exit 1
# steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri1/graph data/test exp/tri1/decode

echo
echo "===== TRI1 ALIGNMENT =====" 
echo

steps/align_si.sh --use-graphs true --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri1 exp/tri1_ali || exit 1


echo
echo "===== TRI2b TRAINING ====="
echo

steps/train_lda_mllt.sh --cmd "$train_cmd" --splice-opts "--left-context=3 --right-context=3" 2500 15000 data/train data/lang exp/tri1_ali exp/tri2b || exit 1;

echo
echo "===== TRI2b DECODING ====="
echo

utils/mkgraph.sh data/lang exp/tri2b exp/tri2b/graph || exit 1;
# steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri2b/graph data/test exp/tri2b/decode || exit 1;

echo
echo "===== TRI2b ALIGNMENT =====" 
echo

steps/align_si.sh --use-graphs true --nj $nj --cmd "$train_cmd" --use-graphs true data/train data/lang exp/tri2b exp/tri2b_ali || exit 1;

# From 2b system, train 3b which is LDA + MLLT + SAT.

echo
echo "===== TRI3b TRAINING ====="
echo

steps/train_sat.sh --cmd "$train_cmd" 2500 15000 data/train data/lang exp/tri2b_ali exp/tri3b || exit 1;

echo
echo "===== TRI3b DECODING ====="
echo

utils/mkgraph.sh data/lang exp/tri3b exp/tri3b/graph || exit 1;
# steps/decode_fmllr.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri3b/graph data/test exp/tri3b/decode || exit 1;

echo
echo "===== TRI3b ALIGNMENT =====" 
echo

steps/align_fmllr.sh --use-graphs true --nj $nj --cmd "$train_cmd" --use-graphs true data/train data/lang exp/tri3b exp/tri3b_ali || exit 1;

local/run_basis_fmllr.sh --lang-suffix "_fmllr"



# tri4a

# ( # from the 3b system.  This is to demonstrate that script.
#  steps/mixup.sh --cmd "$train_cmd" \
#    20000 data/train_si84 data/lang_nosp exp/tri3b exp/tri3b_20k || exit 1;
#  steps/decode_fmllr.sh --cmd "$decode_cmd" --nj 10 \
#    exp/tri3b/graph_nosp_tgpr data/test_dev93 \
#    exp/tri3b_20k/decode_nosp_tgpr_dev93  || exit 1;
# )

# From 3b system, train another SAT system (tri4a) with all the si284 data.
echo
echo "===== TRI4a TRAINING =====" 
echo

steps/train_sat.sh  --cmd "$train_cmd" 4200 40000 data/train data/lang exp/tri3b_ali exp/tri4a || exit 1;

echo
echo "===== TRI4a ALIGNMENT =====" 
echo

steps/align_si.sh --use-graphs true --nj $nj --cmd "$train_cmd" --use-graphs true data/train data/lang exp/tri4a exp/tri4a_ali || exit 1;


echo
echo "===== run.sh script is finished ====="
echo
