export KALDI_ROOT=`pwd`/../..
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
# Setting paths to useful tools
export PATH=$PWD/utils/:$KALDI_ROOT/src/bin:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/srilm/bin/macosx:$PWD:$PATH

[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
# Defining audio data directory (modify it for your installation directory!)
export DATA_ROOT="$PWD/audio"

# Variable needed for proper data sorting
export LC_ALL=C