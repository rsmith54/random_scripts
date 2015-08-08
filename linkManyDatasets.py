#!/usr/bin/python

import subprocess
import os

print 'linking your dataset list'
from optparse import OptionParser

parser = OptionParser()
parser.add_option("--datasetListFile"   , help="txt file listing all of your datasets" , default="")
(options, args) = parser.parse_args()

datasetListFile = open(options.datasetListFile, 'r')

print datasetListFile

for line in datasetListFile :
    datasetname = line
    print "creating symlink for : " + datasetname
#    subprocess.call(["ls","$HOME"], shell = True)

#    exit()
    linkDatasetCall = os.getenv('PWD') + "/linkDataset.py " + " --datasetName " + datasetname
    print linkDatasetCall
    result = subprocess.Popen(linkDatasetCall.split(), stdout=subprocess.PIPE).communicate()[0]
    print result

print "finished creating symlinks"
