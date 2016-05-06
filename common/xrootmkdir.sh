#!/bin/zsh
#script to make directories NOT in xrootd, a la mkdir -f, but still to keep a paralel structiure in fileCatalog

localPath=/a/data/xenia/users/common/fileCatalog
#xrdPath=xroot://xenia.nevis.columbia.edu:1094//data/xrootd

relativePath=$1

dirName=${relativePath%%/*}
remainingPath=${relativePath#*/}

dirs=($dirName)

while [[ $remainingPath != $dirName ]]; do

    dirName=${remainingPath%%/*}
    remainingPath=${remainingPath#*/}

    dirs=($dirs $dirName)
done

print .

for dir in $dirs; do

    localPath=$localPath/$dir

    print checking $localPath
    if [ -d $localPath ]; then
 
	print $localPath exists, moving on.
	print .
    else

	print "Adding directory to fileCatalog: "
	print mkdir $localPath
	mkdir $localPath
	chmod 777 $localPath

	#Print $localPath $xrdPath
	#xrdcp $localPath $xrdPath
	print .
    fi

    #xrdPath=$xrdPath/$dir

done