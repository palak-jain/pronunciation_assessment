for f in *
do
	fname=`head -n 1 $f | cut -d ' ' -f 1`
	tail -n +1 $f > $fname.feat
	sed -i -e 's/\]//' $fname.feat
	rm $f
done