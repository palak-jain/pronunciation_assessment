recording='../../data/teachers'
scripts='../../kaldi/src/featbin'
ow=0


# if [ $# -ge 1 ] || [ $# -gt 3 ]; then
#    echo "Usage: $0 [options] <data-dir> [<log-dir> [<mfcc-dir>] ]";
#    echo "e.g.: $0 data/train exp/make_mfcc/train mfcc"
#    echo "Note: <log-dir> defaults to <data-dir>/log, and <mfccdir> defaults to <data-dir>/data"
#    echo "Options: "
#    echo "  --mfcc-config <config-file>                      # config passed to compute-mfcc-feats "
#    echo "  --nj <nj>                                        # number of parallel jobs"
#    echo "  --cmd (utils/run.pl|utils/queue.pl <queue opts>) # how to run jobs."
#    echo "  --write-utt2num-frames <true|false>     # If true, write utt2num_frames file."
#    exit 1;
# fi


# set paths
if [ $# -ge 1 ]; then
  recording=$1
fi
if [ $# -ge 2 ]; then
  scripts=$2
fi
if [ $# -ge 3 ]; then
  ow=$3
fi

echo "Recordings path " $recording
echo "Scripts path " $scripts
mkdir -p $recording/features
echo -n > $recording/features/feat.scp
echo -n > $recording/wav.scp


for f in $recording/*
do
	echo "Producing mfcc features for" $f
	id=`echo $f|sed -e 's/.*\/\(\w*\)\.wav/\1/g'`
	feature_file=$recording/features/$id.feat
	echo $id  $f > wav.scp
	echo $id $feature_file > feat.scp

	# check its a wav file
	if ! [[ $f == *.wav ]]; then
		echo "File not of correct format. Skipping..."
		continue;
	fi

	# if feature file already exists
	if [ -f $feature_file ] && ((ow==0)); then
		echo "$feature_file already exist. Do you want to overwrite(0)/backup(1)/leave(2)?"
		read x;
		if ((x==1)); then
  			mkdir -p $recording/features/backup
  			echo "$0: moving $feature_file to $recording/features/backup"
  			mv $feature_file $recording/features/.backup/
  		elif ((x==2)); then
  			echo "$0: Leaving $feature_file untouched"
  			continue;
		fi
	fi

	compute-mfcc-feats --config=mfcc.config scp:wav.scp ark,t:- | sed 's/.*\[/\[/g' > $feature_file # | tail -n +2|sed 's/\]//' > $feature_file
	add-deltas scp:feat.scp ark,t:- | sed 's/.*\[/\[/g' > $feature_file.delta
	mv $feature_file.delta $feature_file
	compute-cmvn-stats scp:feat.scp ark,t:- > cmvn.ark
	apply-cmvn --norm-vars ark,t:cmvn.ark scp:feat.scp ark,t:- | tail -n +2|sed 's/\]//' > $feature_file.norm
	mv $feature_file.norm $feature_file
	cat feat.scp >> $recording/features/feat.scp 
	cat wav.scp >> $recording/wav.scp
done;

rm *.scp


