import rootpy.ROOT as ROOT
from rootpy.io import root_open
#import rootpy.numpy
import root_numpy as rnp

import os
from os import path
# Workaround to fix threadlock issues with GUI
import logging
logging.basicConfig(level=logging.INFO)

logging.info("loading packages")
#import shutil                                                                                                                                       #shutil.copyfile(ROOT.gSystem.ExpandPathName('$ROOTCOREDIR/scripts/load_packages.C'), 'load_packages.C')
lineLoadPackages = '.x ' + ROOT.gSystem.ExpandPathName('$ROOTCOREDIR/scripts/load_packages.C')
print lineLoadPackages
ROOT.gROOT.ProcessLine(lineLoadPackages)

# Initialize the xAOD infrastructure
ROOT.xAOD.Init()

#files = [f for f in os.listdir(".") if os.path.isfile(f)]
files = ["ttbar_alljet.root", "ttbar_tenjet.root"]

print files

totalEventCounter = 0

treeName = "PassThroughNT"

rootfile = {files[0] : root_open(files[0]),
            files[1] : root_open(files[1])
            }


trees = {files[0] : rootfile[files[0]].PassThroughNT,
         files[1] : rootfile[files[1]].PassThroughNT
         }

# nentries = tree.GetEntries()
# totalEventCounter += nentries
# print nentries

for entry in xrange(trees[files[0]].GetEntries()) :
    if(entry % 10000 == 0 ) : print entry
    mDeltaR_tenVsAll = ROOT.Hist2D(100, 0, 3000, 100, 0, 3000, type='F')
    for tree in trees.itervalues() :
        tree.GetEntry(entry)

    mDeltaR = {}
    for ifile in files :
        mDeltaR[ifile] = trees[ifile].GetLeaf("RJVars_PP_MDeltaR").GetValue(0)


#    print mDeltaR
    mDeltaR_tenVsAll.Fill(mDeltaR[files[0]] , mDeltaR[files[1]])
            # for entry in xrange(nentries):
            #     tree.GetEntry(entry)
            #     process = 'Processing run #%i, event #%i' % (tree.EventInfo.runNumber(), tree.EventInfo.eventNumber())
            #     print(process)


outfile = root_open("outfile.root" , "recreate")
mDeltaR_tenVsAll.Write()
outfile.Close()
for ifile in rootfile.itervalues() :
    ifile.Close()


print "Total number of events in the sample:" , totalEventCounter
