import sys
import numpy as np



posteriorgramFile = sys.argv[1]
tidFileName = sys.argv[2]
phoneFile = sys.argv[3]
featurePath = sys.argv[4]

# phone to id
phones = open(phoneFile)
phone2id = {"UNK" : 0}
idx = 1
for ph in phones:
	ph = ph.split()[0]
	phone2id[ph] = idx
	print ph ,"\t", idx
	idx += 1

nPhone = len(phone2id)


# tid to phone id map
tidFile = open(tidFileName)
tid2phone = {}
for x in tidFile:
	y = x.split('\n')[0].split('\t')
	tid = y[0]
	ph = y[1]
	if ph in phone2id: 
		tid2phone[tid] = phone2id[ph]
	else:
		tid2phone[tid] = phone2id["UNK"]

# posteriorgrams
pgram = open(posteriorgramFile)
for audio in pgram:
	frames = audio.split('[')
	fid = frames[0].split(' ')[0]
	frames = frames[1:]
	nFrame = len(frames)
	posterior = np.zeros([nFrame, nPhone])

	for k in range(nFrame):
		pdf = frames[k].split(']')[0].split()
		if (len(pdf) % 2):
			print "pdf format should be even in length"
			exit();

		for i in range(len(pdf)/2):
			tid = pdf[i*2];
			phoneId = tid2phone[tid] 
			prob = np.float(pdf[i*2 + 1])
			posterior[k][phoneId] += prob

	np.savetxt(featurePath + fid + ".feat", posterior)
