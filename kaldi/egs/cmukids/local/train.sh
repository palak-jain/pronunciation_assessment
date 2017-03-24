#!/bin/bash

. local/path.sh || exit 1
. local/cmd.sh || exit 1

nj=3        # number of parallel jobs - 1 is perfect for such a small data set
# Safety mechanism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; } 

# Removing previously created data (from last run.sh execution)
rm -rf  exp/tri* 
rm -rf exp/mono*
rm -rf map*

echo
echo "===== MONO TRAINING ====="
echo

steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/train_all data/lang exp/mono  || exit 1

echo
echo "===== MONO GRAPH ====="
echo

utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph || exit 1

echo
echo "===== MONO ALIGNMENT =====" 
echo

steps/align_si.sh --use-graphs true --nj $nj --cmd "$train_cmd" data/train_all data/lang exp/mono exp/mono_ali || exit 1


echo
echo "===== TRI1 (first triphone pass) TRAINING ====="
echo

steps/train_deltas.sh --cmd "$train_cmd" --nj $nj 2000 10000 data/train_all data/lang exp/mono_ali exp/tri1 || exit 1

echo
echo "===== TRI1 (first triphone pass) GRAPH ====="
echo

utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph || exit 1

echo
echo "===== TRI1 ALIGNMENT =====" 
echo

steps/align_si.sh --use-graphs true --nj $nj --cmd "$train_cmd" data/train_all data/lang exp/tri1 exp/tri1_ali || exit 1


echo
echo "===== TRI2b TRAINING ====="
echo

steps/train_lda_mllt.sh --cmd "$train_cmd" --nj $nj --splice-opts "--left-context=3 --right-context=3" 2500 15000 data/train_all data/lang exp/tri1_ali exp/tri2b || exit 1;

echo
echo "===== TRI2b GRAPH ====="
echo

utils/mkgraph.sh data/lang exp/tri2b exp/tri2b/graph || exit 1;

echo
echo "===== TRI2b ALIGNMENT =====" 
echo

steps/align_si.sh --use-graphs true --nj $nj --cmd "$train_cmd" data/train_teacher data/lang exp/tri2b exp/tri2b_ali || exit 1;

echo
echo "===== MAP TEACHER ADAPTATION =====" 
echo

./steps/train_map.sh data/train_teacher data/lang exp/tri2b_ali exp/map_teacher

# echo
echo "===== MAP TEACHER GRAPH =====" 
echo

utils/mkgraph.sh data/lang exp/map_teacher/ exp/map_teacher/graph || exit 1;

echo
echo "===== MAP TEACHER ALIGNMENT =====" 
echo
# TODO(palakj): --use-graphs true in below command
steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" data/train_all data/lang exp/map_teacher/ exp/map_teacher_ali || exit 1;

echo
echo "===== TRI3b TRAINING ====="
echo

steps/train_sat.sh --cmd "$train_cmd" --nj $nj 2500 15000 data/train_all data/lang exp/map_teacher_ali exp/tri3b || exit 1;

echo
echo "===== TRI3b GRAPH ====="
echo

utils/mkgraph.sh data/lang exp/tri3b exp/tri3b/graph || exit 1;

echo
echo "===== TRI3b ALIGNMENT =====" 
echo

steps/align_fmllr.sh --use-graphs true --nj $nj --cmd "$train_cmd" --use-graphs true data/train_dahanu data/lang exp/tri3b exp/tri3b_ali || exit 1;

local/run_basis_fmllr.sh --lang-suffix "_fmllr"

echo
echo "===== MAP  DAHANU ADAPTATION =====" 
echo

./steps/train_map.sh data/train_dahanu data/lang exp/tri3b_ali exp/map_dahanu

echo
echo "===== MAP DAHANU GRAPH =====" 
echo

utils/mkgraph.sh data/lang exp/map_dahanu/ exp/map_dahanu/graph || exit 1;

echo
echo "===== MAP DAHANU ALIGNMENT =====" 
echo
# --use-graph true : should be there in this
steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" data/train_all data/lang exp/map_dahanu/ exp/map_dahanu_ali || exit 1;

echo
echo "===== TRI4a TRAINING =====" 
echo
# TODO(palakj): params 4200, 40000
steps/train_sat.sh  --cmd "$train_cmd" --nj $nj 4200 40000 data/train_all data/lang exp/map_dahanu_ali exp/tri4a || exit 1;

echo
echo "===== TRI4a GRAPH =====" 
echo

utils/mkgraph.sh data/lang exp/tri4a exp/tri4a/graph || exit 1;


echo
echo "===== TRI4a ALIGNMENT =====" 
echo

steps/align_si.sh --use-graphs true --nj $nj --cmd "$train_cmd" --use-graphs true data/train_dahanu data/lang exp/tri4a exp/tri4a_ali || exit 1;


echo
echo "===== MAP DAHANU ADAPTATION =====" 
echo

./steps/train_map.sh data/train_dahanu data/lang exp/tri4a_ali exp/map_dahanu2/

echo
echo "===== MAP DAHANU GRAPH =====" 
echo

utils/mkgraph.sh data/lang exp/map_dahanu2 exp/map_dahanu2/graph || exit 1;

# echo
# echo "===== MAP DAHANU ALIGNMENT =====" 
# echo

# steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" data/train_all data/lang exp/map_dahanu2 exp/map_dahanu2_ali || exit 1;


# tri4a

# ( # from the 3b system.  This is to demonstrate that script.
#  steps/mixup.sh --cmd "$train_cmd" \
#    20000 data/train_si84 data/lang_nosp exp/tri3b exp/tri3b_20k || exit 1;
#  steps/decode_fmllr.sh --cmd "$decode_cmd" --nj 10 \
#    exp/tri3b/graph_nosp_tgpr data/test_dev93 \
#    exp/tri3b_20k/decode_nosp_tgpr_dev93  || exit 1;
# )

# From 3b system, train_all another SAT system (tri4a) with all the si284 data.

# echo
# echo "===== TRI4a Dahanu ALIGNMENT =====" 
# echo

# steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train_dahanu data/lang exp/tri4a exp/tri4a_dahanu_ali || exit 1;

echo
echo "===== run.sh script is finished ====="
echo


