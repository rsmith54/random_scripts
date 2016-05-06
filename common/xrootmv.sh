#Script to mv dataset from one existing location in the xrootd directory structure to another using xrdcp, followed by rm

sourcePath=$1
sourcePath=${sourcePath#/}
sourcePath=${sourcePath%/}
sourceLocation=${sourcePath%/*}
datasetName=${sourcePath##*/}

detinationLocation=$2
detinationLocation=${detinationLocation#/}
detinationLocation=${detinationLocation%/}

if [[ ! -d /data/users/common/fileCatalog/$sourceLocation ]]; then

    print the path $sourceLocation" does not exist in the fileCatalog. Please check that this is correct."
    return
fi

if [[ ! -f /data/users/common/fileCatalog/$sourceLocation/$datasetName ]]; then

    print there is no dataset $datasetName at $sourceLocation". Moving directories is not supported at this time."
    return
fi

if [[ ! -d /data/users/common/fileCatalog/$detinationLocation ]]; then

    print $detinationLocation" does not exist in the fileCatalog. Check that this is the correct destination path. If so, create it with xrootmkdir.sh"
    return
fi

#Copy the files:
print copying files from source path to destination:
print
while read fileName; do

    print xrdcp xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$sourceLocation/$datasetName/$fileName xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$detinationLocation/$datasetName/$fileName
    xrdcp xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$sourceLocation/$datasetName/$fileName xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$detinationLocation/$datasetName/$fileName

    if [[ $? = 0 ]]; then
	print adding record of $fileName to /data/users/common/fileCatalog/$detinationLocation/$datasetName
	echo $fileName >>! /data/users/common/fileCatalog/$detinationLocation/$datasetName
    fi

done </data/users/common/fileCatalog/$sourceLocation/$datasetName
print
print removing files from source path:
if [ ! "$XRDPOSIXSET" ]; then
    source /data/users/common/setupxrdposix.sh
fi

while read fileName; do

    print rm xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$sourceLocation/$datasetName/$fileName
    rm xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$sourceLocation/$datasetName/$fileName
    

done </data/users/common/fileCatalog/$sourceLocation/$datasetName 

print
print removing dataset directory from source path:
print rm xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$sourceLocation/$datasetName
rm xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$sourceLocation/$datasetName
print 
print removing dataset file from catalog:
print rm /data/users/common/fileCatalog/$sourceLocation/$datasetName
rm /data/users/common/fileCatalog/$sourceLocation/$datasetName
