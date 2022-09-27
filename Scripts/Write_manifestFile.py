#!/usr/bin/env python

'''
@uthor: Geizecler Tomazetto, Ph.D.
email:geizetomazetto@gmail.com
'''
import sys
import os
import glob
import re

# Helping my friends
usage = '''
Create a manifest_file.txt from any directory - I hope that!

1. Type on your terminal: python Write_manifestFile.py $PWD/
2. Open the file named as manisfest_file.txt.
🔥 The output file == "manifest_file.txt". Do not change it.

3.Is there any line with word 'ERROR' written?
4. No. Great! It worked pretty well. 😅
5. But if you find the "ERROR", please back to your directory and check your fastq.gz files.
   It is not my fault.

    My  script is considering:
        - You have Forward (R1) and Reverse (R2) files.
        - If you are not working with paired-end sequences... uhhh it won't work.
        - Your fastq.gz files are similar to the "Sample01_R1.fastq.gz".
'''


if str(sys.argv[1]) == "-help":
    print(usage)
    sys.exit()

# output file - It'll always be manifest_file.txt
# Write the header line -
output_file= open("manifest_file.txt", 'w')
output_file.write("sample-id,absolute-filepath,direction\n")


# On the terminal just type "$PWD/"
path_fastq = sys.argv[1]
directory= sorted(glob.glob(os.path.join(path_fastq, '*.fastq.gz')))


for f in directory:
    file =f.split('/')[-1]
    sample_id = file.split('_')[0]
    direction = ''

#Testing...
#    print(f, file, sample_id)

    if("R1" in file):
        direction = "forward"

    elif("R2" in file):
        direction = "reverse"

    else:
        sample_id =('\n' + "File ERROR")

#Testing...
#    print(sample_id + "," + f + "," + direction)


    # Writing each line...
    output_file.write(sample_id + "," + f + "," + direction + "\n")



#Let's take a look on this file.
output_file.close()
