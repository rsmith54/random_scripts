import ROOT
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


file = ROOT.TFile.Open("AOD.05590490._000596.pool.root.1")
treeName = "CollectionTree"

# Make the "transient tree"
tree = ROOT.xAOD.MakeTransientTree(file, treeName)

tree.GetListOfBranches().Print()
