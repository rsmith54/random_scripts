import rootpy.ROOT as ROOT
#import ROOT

import os
from os import path
# Workaround to fix threadlock issues with GUI
ROOT.PyConfig.StartGuiThread = False
import logging
logging.basicConfig(level=logging.INFO)

logging.info("loading packages")
#import shutil                                                                                                                                       #shutil.copyfile(ROOT.gSystem.ExpandPathName('$ROOTCOREDIR/scripts/load_packages.C'), 'load_packages.C')
lineLoadPackages = '.x ' + ROOT.gSystem.ExpandPathName('$ROOTCOREDIR/scripts/load_packages.C')
print lineLoadPackages
ROOT.gROOT.ProcessLine(lineLoadPackages)

# Initialize the xAOD infrastructure
ROOT.xAOD.Init()

files = [f for f in os.listdir(".") if os.path.isfile(f)]

print files

totalEventCounter = 0

for ifile in files:
    if(not (".py" in ifile) ):
#    print ifile.isfile
        rootfile = ROOT.TFile.Open(ifile)
        treeName = "CollectionTree"

        if(rootfile.GetListOfKeys().Contains(treeName)):
            tree = ROOT.xAOD.MakeTransientTree(rootfile, treeName)

            nentries = tree.GetEntries()

            totalEventCounter += nentries
            print nentries

            for entry in xrange(nentries) :
                tree.GetEntry(entry)
                process = 'Processing run #%i, event #%i' % (tree.EventInfo.runNumber(), tree.EventInfo.eventNumber())
                print(process)



        rootfile.Close()

print "Total number of events in the sample:" , totalEventCounter
