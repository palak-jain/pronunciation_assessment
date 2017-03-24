#!/bin/bash

. local/path.sh || exit 1
. local/cmd.sh || exit 1

nj=3         # number of parallel jobs - 1 is perfect for such a small data set
model=$1
features=$3
trgt=$2
# Safety mechnism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
# [[ $# -ge 4 ]] && { echo "Wrong arguments!"; exit 1; } 

# Removing previously created data (from last decode.sh execution)
rm -rf exp/${model}/decode/ $features
# mkdir -p exp/${model}/decode/${trgt}
mkdir -p $features

echo
echo "===== $model DECODING =====" 
echo

steps/decode_fmllr.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/$model/graph data/${trgt} exp/$model/decode || exit 1;

echo
echo "===== POSTERIORS ====="
echo
# TODO(palakj): Compute dimension of feature from aminfo

gunzip -c exp/$model/decode/lat.1.gz > exp/$model/decode/final.lat
lattice-to-post ark:exp/${model}/decode/final.lat ark,t:- > exp/$model/decode/final.post

echo
echo "===== TID 2 PHONE ====="
echo

fstmaketidsyms --show-tids exp/$model/phones.txt exp/$model/final.mdl | tr '_' '\t' | awk 'BEGIN{FS="\t"}{print $NF "\t"  $1}' > details/tid2phone

echo
echo "===== EXTRACT FEATURES FROM POSTERIOR ====="
echo

python local/getposterior.py exp/$model/decode/final.post details/tid2phone data/local/dict/phone.txt $features > details/phone2id.txt                     

# mv exp/${model}/decode/ exp/${model}/decode/${trgt}

echo
echo "===== Features extracted in $features ====="
echo
