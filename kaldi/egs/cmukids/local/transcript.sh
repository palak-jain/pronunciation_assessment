

# ------------------------------- NOTES------------------------------------ #

# Add <UNK> SPN to lexicon and SPN to non_silence phones

# ------------------------------- DESCRIPTION------------------------------------ #

# Acoustic data

# data/$trgt/ and data/test

# File 			CONTENT					PATH  		MAPPING to CMU 
# spk2gender    [<speaker-id> <gender>]
# text        [<uterranceID> <text_transcription>]   (transcription.tbl)
# utt2spk    [<uterranceID> <speakerID>]
# corpus.txt    [<text_transcription>]    (data/local/)   (sentence.tbl)


# ------------------------------- PATHS------------------------------------ #

home="$PWD"
data="/Users/Palak/Desktop/Rnd/data/cmu/kids1/"
data2="/Users/Palak/Desktop/Rnd/data/cmu/kids2/"
dict="$home/data/local/dict"
lex="$home/data/local/lex"
static="$home/.static_data"
transcript=$2
trgt=$1

if [[ $# -lt 2 ]]; then
	echo "Usage: ./transcript.sh trgt_dir transcript_path";
	echo "Example: ./transcript.sh train_all text"
	exit 1;
fi

# ------------------------------- PREPARATION -------------------------------------- #
rm -rf data/$trgt/
mkdir -p data/$trgt/
# text
echo "---- Preparing transcription ----"

sort  $transcript  > $home/data/$trgt/text_sort_
cut -c-8 $home/data/$trgt/text_sort_ > $home/details/utt_$trgt.id
sed 's:.\{7\}[0-9]::g' < $home/data/$trgt/text_sort_ > $home/data/$trgt/text_word_   # tab to space replace in other text files
./local/refine_transcript.sh $home/data/$trgt/text_word_ $home/data/$trgt/text_word
python3 local/prep_corpus.py $static/lexicon/word2phone $home/data/$trgt/text_word > $home/data/$trgt/text_
paste $home/details/utt_$trgt.id $home/data/$trgt/text_ > $home/data/$trgt/text

ntext=`wc -l $home/data/$trgt/text`
echo "Number of transcriptions : $ntext"

# utt2spk spk2gender
x=$trgt
echo "---- Generate utt2spk $x ----"
cut -c-4 $home/details/utt_$x.id > $home/details/spk_$x.id
paste -d " " $home/details/utt_$x.id $home/details/spk_$x.id > $home/data/$x/utt2spk

echo "---- Generate spk2gender $x  ----"
uniq $home/details/spk_$x.id > $home/details/spk_$x_uniq.id
cut -c1 $home/details/spk_$x_uniq.id > $home/details/gen_$x.id
paste $home/details/spk_$x_uniq.id $home/details/gen_$x.id > $home/data/$x/spk2gender;


# spk2utt
utils/utt2spk_to_spk2utt.pl data/$trgt/utt2spk > data/$trgt/spk2utt

# Cleaning up
rm -f $home/data/$trgt/*_  
