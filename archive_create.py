#!/proj/sot/ska3/flight/bin/python
from urllib.request import urlopen

ace_url = "ftp://ftp.swpc.noaa.gov/pub/lists/ace/ace_epam_5m.txt"
try:
	ace = urlopen(ace_url)
	ace_content = ace.readlines()
	ace_content = ace_content[18:]
	with open('ace_12h_archive', 'r') as f:
		archive = f.readlines()


	for line in ace_content:
		line = line.decode('utf-8')
		time = line[:16]
		if line not in archive:
			match = False
			for i, arch_line in enumerate(archive):
				arch_time = arch_line[:16]
				#print (arch_time)
				if arch_time == time:
					archive[i] = line
					match = True
			if not match:
				archive += [line]
		

	ace_12h_archive = archive[-144:]

	with open('ace_12h_archive', 'w') as f:
		for line in ace_12h_archive:
			f.write(line)

except Exception as e:
	print (str(e))

