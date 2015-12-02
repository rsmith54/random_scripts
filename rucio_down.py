#from Brad Axen

import subprocess
import glob
import os
import shutil
import argparse

class bcolors:
    BLUE = '\033[95m'
    LIGHT = '\033[94m'
    ORANGE = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    ENDC = '\033[0m'


def download(sample):
    out, err = subprocess.Popen(["rucio", "list-dids", sample], stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    for line in out.split('\n'):
        if ("COLLECTION" in line or "CONTAINER" in line) and not "tid" in line:
            d = line.split()[1].split(":")[1]
            print ""
            print "Downloading sample:", bcolors.BOLD + bcolors.ORANGE + d + bcolors.ENDC
            print ""
            subprocess.Popen(["rucio","download",d, "--ndownloader", "5"]).wait()
            print ""
            print "Finished sample:", bcolors.BOLD + bcolors.ORANGE + d + bcolors.ENDC
            print ""

    out, err = subprocess.Popen(["du", "-h", "--summarize"] + glob.glob(os.path.join(sample,"*")), stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    for line in out.split('\n'):
        if "512\t" == line[:4]: # This is the size of one completely empty xAOD file, apparently
            print "Found an empty dataset, removing:", bcolors.BOLD + bcolors.ORANGE + line.split()[1] + bcolors.ENDC
            os.remove(line.split()[1]) # remove it to avoid odd EventLoop failures


def main():
    parser = argparse.ArgumentParser("Download all samples matching the specified string (expanding wildcards) and remove any empty files.")
    parser.add_argument("sample", nargs="+", help = "The sample or samples (or wildcarded expressions) to download.")

    args = parser.parse_args()

    for sample in args.sample:
        download(sample)



if __name__ == "__main__":
    main()
