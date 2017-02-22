#!/bin/bash

# Corrects audio format and places it in audio/
# Generates wav.scp    [<uterranceID> <full_path_to_audio_file>]
# Extracts mfccfeatures
. ./cmd.sh || { exit 1; }
. ./path.sh || { exit 1; }

audiogen=$1
dict="$home/data/local/dict"
lex="$home/data/local/lex"
static="$home/.static_data"
trgt="test_cmu"
nj=1

echo
echo "===== FEATURES EXTRACTION ====="
echo

# rm -rf $home/data/$trgt/wav.scp 
rm -rf exp/make_mfcc/$trgt
mkdir -p exp/make_mfcc/$trgt
# echo "---- Convert audio to correct format ----"

# # audio files
# if [ $audiogen == "audio" ]; then
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

echo "---- Generate wav.scp for cmu data (id to Audio Path map) ----"


# for f in $home/audio/*;
# do
# 	id=${f: -12:8 }
# 	# if [ ${id: -1 } == "2" ]; then   # change here
# 		echo -e $id "\t" $f
# 	# fi
# done > $home/data/$trgt/wav.scp_

# sort $home/data/$trgt/wav.scp_ > $home/data/$trgt/wav.scp


# DONT generate features again and again
# Making feats.scp files
mfccdir=mfcc
utils/validate_data_dir.sh data/$trgt # data/test   # script for checking if prepared data is all right
# utils/fix_data_dir.sh data/$trgt          # tool for data sorting if something goes wrong above
steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj $nj --cmd "run.pl" data/$trgt exp/make_mfcc/$trgt $mfccdir

# Making cmvn.scp files
steps/compute_cmvn_stats.sh data/$trgt exp/make_mfcc/$trgt $mfccdir

# Cleaning up
rm -f data/$trgt/wav.scp_