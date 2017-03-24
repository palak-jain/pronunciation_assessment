## gen_lex.sh

word boudaries or without

## lm.sh

set original corpus path and lexicon
in prepare_lang.sh set phone position to false, silence phone map to one l54, l57


## transcript.sh  

(run for various datasets)
set trgt and transcript

## featextract.sh  (independent of pervious steps, run parallel)

1. set $trgt directory to place wav.scp in 
2. set audio configuration in conf/mfcc.conf
3. change lines 40-43 accordingly

## train.sh

set data paths for experiments

decode.sh