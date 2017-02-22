# Removes all punctuation marks and numbers
# To upper case
# Removes extra white space and empty lines

corpus_orig=$1
corpus=$2

if [ $# -lt 2 ]; then
	echo "[ $0 ] Usage: ./refine_corpus.sh unrefined_corpus.in refined_corpus.out"
	echo "One sentence on each line"
	exit 1;
fi

echo "---- REFINE CORPUS ----"
sed "s:'::g" < $corpus_orig | tr '[a-z]' '[A-Z]' | tr -cs 'A-Z\n' ' ' > $corpus.refine
cat $corpus.refine | grep -v "^\s*$"  | sed 's:^\s*::g' | sed 's:\s*$::g'   > $corpus
rm $corpus.refine