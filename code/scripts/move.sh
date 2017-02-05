cd $1
for f in *
do 
	q=`echo $f|sed 's/_.*\.wav//g'|sed 's/\([a-z]\)\([A-Z]\)/\1_\2/g'`;
	i=0
	mv "$f" $q"_"$i".wav"
		# mv $f/$g ./$f_$i.wav
	((i+=1))
done 