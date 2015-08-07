#!/usr/bin/python

import os
import subprocess
from optparse import OptionParser

parser = OptionParser()
parser.add_option("--datasetName"   , help="dataset name"                , default="")
parser.add_option("--taskId"        , help="taskId for your dataset"     , default="")
parser.add_option("--overwriteLinks", help="Overwrite the existing links", default=False)
(options, args) = parser.parse_args()

#set these here
#todo set these command line

datasetName = options.datasetName #'mc15_13TeV.361044.Sherpa_CT10_SinglePhotonPt70_140_BFilter.merge.DAOD_TRUTH1.e3587_p2375'
taskId      = options.taskId
if( not options.taskId ):
    print "Checking rucio is configured"
    if(not os.getenv('RUCIO_HOME')) :
        print "You haven't configured rucio"
        print "Either set up rucio or give the taskId for your dataset manually"
        exit()

    rucioCall = 'rucio list-files ' + datasetName
    print "Running rucio to find taskId for the files in your dataset : " + datasetName
    print rucioCall

    result = subprocess.check_output(rucioCall, shell=True)
    print result
    splitresult =  result.split()
    matching  = [s for s in splitresult if "AOD"  in s]
    matching += [s for s in splitresult if "DAOD" in s]
    matchingset =  set(matching)
    print "List of files in your dataset :"
    print matchingset

    if not matching :
        print "your dataset seems to have no files according to rucio.  Check your dataset name or give your taskId as an argument and try again"
        exit()

    print "Retrieving taskId from a member :"
    taskId = matchingset.pop().split(".")[1]
    print "TaskId : " + taskId

print "Dataset : " + datasetName
print "TaskId  : " + taskId


from glob import glob

rucioDir = '/xrootdfs/atlas/dq2/rucio/'
paths = glob(rucioDir+'/*/*/*/*'+taskId+'*')

print "Symlinking the following paths to your /data/users/USER directory"
print paths

userDataDir = '/data/users/' + os.getenv('USER')

print "Located your user data directory:  " + userDataDir

fullDatasetName = userDataDir + '/' + datasetName

if options.overwriteLinks:
    print "Removing existing links"
    import shutil
    shutil.rmtree(fullDatasetName, True)

if os.path.isdir(fullDatasetName):
    print "Your dataset already exists at :"
    print fullDatasetName
    print "Either delete it or use the --overwriteLinks option"
    exit()

print "Creating directory for your dataset symlinks at : " +  fullDatasetName
os.mkdir(fullDatasetName)

for ipath in paths:
    symlinkFullPath = fullDatasetName + '/'+ os.path.basename(ipath)
    print "Created link at " + symlinkFullPath
    os.symlink(ipath, symlinkFullPath)

print "Symlinks created"
