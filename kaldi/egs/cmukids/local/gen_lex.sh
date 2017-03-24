# ------------------------------- LEXICON DATA------------------------------------ #
# Language data

# data/local/dict

# lexicon.txt        [<word> <phone 1> <phone 2> ...]    (alignment.dic)    
# nonsilence_phones.txt    [<phone>]   
# silence_phones.txt    [<phone>]		
# optional_silence.txt    [<phone>]   
# ------------------------------------------------------------------- #

. local/path.sh

# phones
rm -rf $dict
mkdir $dict
cp $static/phone/*silence*.txt $dict/

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
paste $dict/nonsilence_phones.txt $dict/nonsilence_phones.txt > $dict/lexicon.txt 
paste $dict/silence_phones.txt $dict/silence_phones.txt >> $dict/lexicon.txt 

# Add SIL and UNK
echo -e "<UNK> \t SPN" >> $dict/lexicon.txt

rm -rf $dict/*.phones_ 
