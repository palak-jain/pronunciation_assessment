# ------------------------------- LEXICON DATA------------------------------------ #
# Language data

# data/local/dict

# lexicon.txt        [<word> <phone 1> <phone 2> ...]    (alignment.dic)    
# nonsilence_phones.txt    [<phone>]   
# silence_phones.txt    [<phone>]		
# optional_silence.txt    [<phone>]   
# ------------------------------------------------------------------- #

. ./path.sh

# phones
cp $static/phone/*silence.phone $dict/

# lexicon
echo "---- Preparing Lexicon ----"

# with word boundaries

# sed 's:^:\/:g' < $dict/nonsilence.phones > $dict/pre.phones_
# sed 's:$:\/:g' < $dict/nonsilence.phones > $dict/post.phones_
# sed 's:^:\/:g' < $dict/post.phones > $dict/prepost.phones_
# cat $dict/*.phones* > $dict/nonsilence.lex
# cat $dict/nonsilence.phones $dict/nonsilence.phones $dict/nonsilence.phones $dict/nonsilence.phones > $dict/nonsilence.phones_
# paste $dict/nonsilence.lex $dict/nonsilence.phones_ > $dict/lexicon.txt

# sed 's:\(\w*\):\/\1\/:g' < $dict/silence.phones > $dict/silence.lex
# paste $dict.silence.lex $dict/silence.phones >> $dict/lexicon.txt


# No word boundaries
paste $dict/nonsilence.phone $dict/nonsilence.phone > $dict/lexicon.txt 
paste $dict/silence.phone $dict/silence.phone >> $dict/lexicon.txt 

# Add SIL and UNK
echo -e "<UNK> \t SPN" >> lexicon.txt

rm -rf $dict/*.phones_ 
