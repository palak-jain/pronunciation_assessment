import re
import sys

lexFile = sys.argv[1]
vocabFile = sys.argv[2]

f1 = open(lexFile)
f2 = open(vocabFile)
lex = [x.split('\n')[0].split('\t') for x in f1]
lexdict = dict(lex)
vocab = [x.split('\n')[0] for x in f2]

# notpresent = set(vocab) - set(lex[:,0])
for x in vocab:
	# regex = re.compile("^x+"(\(|$)")
	# match = filter(regex.match, lexdict.keys())
	# for r in match:
	if x not in lexdict:
		print(x)

