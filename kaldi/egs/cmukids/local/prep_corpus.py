import sys

wordMapFile = sys.argv[1]
corpusFile = sys.argv[2]
wordMapRaw = open(wordMapFile)
wordMap = [ x.split('\n')[0].split('\t') for x in wordMapRaw ]
lexdict = dict(wordMap)

corpus = open(corpusFile)
for sent in corpus:
	words = sent.split('\n')[0].split(' ')
	for w in words[:-1]:
		if w in lexdict:
			print(lexdict[w], end='\t', flush=True)
		else:
			print("<UNK>", end='\t', flush=True)
	if words[-1] in lexdict:
		print(lexdict[words[-1]])
	else:
		print("<UNK>")
