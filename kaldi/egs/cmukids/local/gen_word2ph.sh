# Generates vocabulary 
# Generates lexicon, provides list of lexicon not in word2phone mapping
# Usage: ./genvocab.sh vocabulary_corpus lexicon notpresent(for words not present in lexicon)

corpus=$1
lexicon=$2
notpresent=$3


# vocab
voc_path=`echo $corpus | sed 's:\/[^\/]*$::'`
echo "---- GENERATE VOCAB ----"
tr ' ' '\n' < $corpus | grep -v "(^\s*$)" |  sort | uniq -c | sort -bnr | sed 's:[0-9]\| ::g' > $voc_path/vocab.txt

# lexicon
echo "---- GET LEXICONS NOT IN LIST ----"
python3 local/common_words.py $lexicon $voc_path/vocab.txt > $notpresent #> $dir/lex/common.lex

if [[ `cat $notpresent` ]]; then
  echo "Get lexicon mapping for $notpresent at http://www.speech.cs.cmu.edu/tools/lextool.html"
  # echo "Run sed 's:\t:\t/:g' < inp | sed 's:$:\/:g'"
  echo "Append it to $lexicon"
  exit 1;
fi