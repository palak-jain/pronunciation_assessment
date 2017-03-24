

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

# lexicon
echo "---- Preparing Lexicon ----"

tr "\t" " " < $data/tables/alignmnt.dic > $home/data/local/dict/lexicon.txt  
echo "<UNK>   SPN" >> $home/data/local/dict/lexicon.txt
dos2unix $home/data/local/dict/lexicon.txt 2> /dev/null

# corpus
echo "---- Preparing Corpus ----"

cut -f 3 $data/tables/sentence.tbl | tr '[a-z]' '[A-Z]' > $home/data/local/corpus.txt

# text
echo "---- Preparing transcription ----"

grep '^\w*1 ' $data/tables/transcrp.tbl | sort | sed 's/\w\{7\}[1-2] //g' | tr '[a-z]' '[A-Z]' > $home/data/text

# wav.scp  change this
for f in $home/audio/*;
do
	id=${f: -12:8 }
	if [ ${id: -1 } == "1" ]; then
		echo -e $id "\t" $f
	fi
done > $home/data/wav.scp

sort $home/data/wav.scp > $home/data/wavsort.scp
paste $home/data/wavsort.scp $home/data/text > $home/data/wav_text
gshuf $home/data/wav_text > $home/data/wav_shuf
cut -f 1,2 $home/data/wav_shuf > $home/data/wav.scp
cut -f 1,3 $home/data/wav_shuf > $home/data/text


# Train - Test data split

totfiles=`wc -l $home/data/wav.scp|sed 's/[^[0-9]]*//g'`
testfiles=$((totfiles/5))
trainfiles=$((totfiles - testfiles))
echo "Total" $totfiles "audio files. Train:" $trainfiles "Test:" $testfiles

split -l $trainfiles -a 1 $home/data/wav.scp $home/data/wav.
split -l $trainfiles -a 1 $home/data/text $home/data/text.


# utt2spk and spk2gender
# Note that utt_id in wav.scp and utt2spk follow the same order. ()not sure if req.

sort $home/data/wav.a > $home/data/train/wav.scp
sort $home/data/wav.b > $home/data/test/wav.scp
sort $home/data/text.a > $home/data/train/text
sort $home/data/text.b > $home/data/test/text

for x in train test;
do
	# utt2spk 
	cut -d " " -f 1 $home/data/$x/wav.scp > $home/details/utt_$x.id
	cut -c-4 $home/details/utt_$x.id > $home/details/spk_$x.id
	paste -d " " $home/details/utt_$x.id $home/details/spk_$x.id > $home/data/$x/utt2spk

    # spk2gender
	uniq $home/details/spk_$x.id > $home/details/spk_$x_uniq.id
	cut -c1 $home/details/spk_$x_uniq.id > $home/details/gen_$x.id
	paste $home/details/spk_$x_uniq.id $home/details/gen_$x.id > $home/data/$x/spk2gender;
done

# phones
# copied from doc/alignment.doc

# Cleaning up
rm $home/data/wav*  $home/data/text*


