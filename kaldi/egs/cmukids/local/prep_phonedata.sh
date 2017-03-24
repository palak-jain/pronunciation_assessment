

# ------------------------------- NOTES------------------------------------ #

# First data set only bin1 8th character 1
# Add <UNK> SPN to lexicon and SPN to non_silence phones
# nonsilence_phones.txt/ lexicon.txt  : new line at end
# (optional)silence_phones.txt   : no new line at end


# ------------------------------- DESCRIPTION------------------------------------ #

# Acoustic data

# data/train/ and data/test

# File 			CONTENT					PATH  		MAPPING to CMU 
# spk2gender    [<speaker-id> <gender>]
# wav.scp    [<uterranceID> <full_path_to_audio_file>]
# text        [<uterranceID> <text_transcription>]   (transcription.tbl)
# utt2spk    [<uterranceID> <speakerID>]
# corpus.txt    [<text_transcription>]    (data/local/)   (sentence.tbl)


# Language data

# data/local/dict

# lexicon.txt        [<word> <phone 1> <phone 2> ...]    (alignment.dic)    
# nonsilence_phones.txt    [<phone>]   
# silence_phones.txt    [<phone>]		
# optional_silence.txt    [<phone>]   

# ------------------------------- PATHS------------------------------------ #
. local/path.sh

# ------------------------------- PREPARATION -------------------------------------- #


# audio files
# if [ $1 == "audio" ]; then
# 	# mkdir $home/audio
# 	for f in $data/kids/* $data2/kids/*;
# 	do 
# 		for g in $f/signal/*;
# 		do 
# 			id=`echo "${g: -12:8}"`; 
# 			sox $g "$home/audio/$id.wav"
# 		done;
# 	done 
# fi

# # phones
# # copied from doc/alignment.doc
# cp $static/phone/*silence.phone $dict/

# # lexicon
# echo "---- Preparing Lexicon ----"

# sed 's:^:\/:g' < $dict/nonsilence.phones > $dict/pre.phones_
# sed 's:$:\/:g' < $dict/nonsilence.phones > $dict/post.phones_
# sed 's:^:\/:g' < $dict/post.phones > $dict/prepost.phones_
# cat $dict/*.phones* > $dict/nonsilence.lex
# cat $dict/nonsilence.phones $dict/nonsilence.phones $dict/nonsilence.phones $dict/nonsilence.phones > $dict/nonsilence.phones_
# paste $dict/nonsilence.lex $dict/nonsilence.phones_ > $dict/lexicon.txt

# sed 's:\(\w*\):\/\1\/:g' < $dict/silence.phones > $dict/silence.lex
# paste $dict.silence.lex $dict/silence.phones >> $dict/lexicon.txt

# # Add SIL and UNK
# echo -e "SIL \t SIL \n <UNK> \t SPN" >> lexicon.txt

# rm $dict/*.phones_ 

# Refine corpus
# rm $home/data/local/lex/notpresent.txt

# echo "---- Refining Corpus and Preparing Word Phone Map ----"
# . $home/local/genvocab.sh $static/corpus/corpus.txt $dict/word2phone $home/data/local/

# # If all words not in phone mapping, stop
# if [[ `cat $home/data/local/lex/notpresent.txt` ]]; then
# 	echo "Get lexicon mapping for $lex/notpresent.txt at http://www.speech.cs.cmu.edu/tools/lextool.html and place it in $lex/cmutools.lex";
# 	exit 1;
# fi

# echo "---- Get Word to Phone map ----"
# sed 's:\t:\t/:g' $lex/cmutool.lex | sed 's:$:\/:g' > $lex/notpresent.lex
# cat $lex/common.lex $lex/notpresent.lex > $dict/word2phone

# echo "---- Preparing Corpus (Phones) ----"

# python3 local/prep_corpus.py $dict/word2phone $static/corpus/corpus.txt > $home/data/local/corpus.txt

# text
# echo "---- Preparing transcription ----"

cat  $data/tables/transcrp.tbl | sort | sed 's/\w\{7\}[1-2] //g' | tr '[a-z]' '[A-Z]' > $home/data/train/text_word
# grep -v "^\s*$"  < $corpus.refine | sed 's:^\s*::g' | sed 's:\s*$::g'   > $corpus
python3 local/prep_corpus.py $dict/word2phone $home/data/train/text_word > $home/data/train/text_

# wav.scp  change this
echo "---- Generate wav.scp for cmu data (id to Audio Path map) ----"

for f in $home/audio/*;
do
	id=${f: -12:8 }
	# if [ ${id: -1 } == "1" ]; then
		echo -e $id "\t" $f
	# fi
done > $home/data/train/wav.scp_

sort $home/data/train/wav.scp_ > $home/data/train/wav.scp
# head -n 10 $home/data/train/wav.scp > $home/data/test/wav.scp

# # wav.scp  change this
# echo "---- Generate wav.scp for dahanu child data (id to Audio Path map) ----"

# for f in $home/../../../data/children/Bunty_And_Bubbly_0_sent/*;
# do
# 	ext=${f: -4 }
# 	if [ $ext == ".wav" ]; then
# 		echo -e $f "\t" $f
# 	fi
# done > $home/data/test/wav.scp_

# sort $home/data/test/wav.scp_ > $home/data/test/wav.scp

for x in train test;
do
	# utt2spk 
	echo "---- Generate utt2spk $x ----"
	cut -d " " -f 1 $home/data/$x/wav.scp > $home/details/utt_$x.id
	cut -c-4 $home/details/utt_$x.id > $home/details/spk_$x.id
	paste -d " " $home/details/utt_$x.id $home/details/spk_$x.id > $home/data/$x/utt2spk

    # spk2gender
    echo "---- Generate spk2gender $x  ----"
	uniq $home/details/spk_$x.id > $home/details/spk_$x_uniq.id
	cut -c1 $home/details/spk_$x_uniq.id > $home/details/gen_$x.id
	paste $home/details/spk_$x_uniq.id $home/details/gen_$x.id > $home/data/$x/spk2gender;
done

paste $home/details/utt_train.id $home/data/train/text_ > $home/data/train/text
# head -n 10 $home/data/train/text > $home/data/test/text

# Cleaning up
rm -f $home/data/train/*_  $home/data/test/*_
