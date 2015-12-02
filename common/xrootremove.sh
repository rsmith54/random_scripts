#Remove all files from a dataset, or a collection of datasets, from xrootd

if [ ! "$XRDPOSIXSET" ]; then
    source /a/data/xenia/users/common/setupxrdposix.sh
fi


initSearchPath=$1
initSearchPath=${initSearchPath#/}
initSearchPath=${initSearchPath%/}

if [[ $#initSearchPath == 0 ]]; then

    print "a valid path must be given to the directories you wish to delete"

    return
fi


#Make a list of all directories and all dataset files:

directories=()
datasets=()

newDirsToCheck=($initSearchPath)

if [[ -f /a/data/xenia/users/common/fileCatalog/$initSearchPath ]]; then

    datasets=($initSearchPath)

else

    if [[ -d /a/data/xenia/users/common/fileCatalog/$initSearchPath ]]; then

	directories=($initSearchPath)


	while [[ $#newDirsToCheck != 0 ]]; do
	    
	    
	    dirsToCheck=($newDirsToCheck)
	    newDirsToCheck=()
	    
	    for searchPath in $dirsToCheck; do

		if [ ! -z "/a/data/xenia/users/common/fileCatalog/$searchPath/*" ]; then
		    
		    matching=($(source /a/data/xenia/users/common/xrootls.sh $searchPath))

		    for entry in $matching; do

			if [ -f /a/data/xenia/users/common/fileCatalog/$entry ]; then
			    datasets=($entry $datasets)			    
			else 

			    if [ -d /a/data/xenia/users/common/fileCatalog/$entry ]; then

				directories=($entry $directories)
				newDirsToCheck=($entry $newDirsToCheck)

			    fi
			fi
		    done
		    
		fi
	    done
	    
	done
    
    else

	print "there is no directory or file at "$initSearchPath" in the file catalog."

    fi

fi


print "Removing files:"
for datasetPath in $datasets; do
    
    print
    print "dataset "$datasetPath" found in catalog. Will remove all files."
    print "."
	
    while read line; do
	
	print rm xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$datasetPath/$line
	rm xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$datasetPath/$line
	
    done < /a/data/xenia/users/common/fileCatalog/$datasetPath
	
    print rm xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$datasetPath
    rm xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$datasetPath
    
    if [[ $? = 0 ]]; then
	print rm /a/data/xenia/users/common/fileCatalog/$datasetPath
	rm /a/data/xenia/users/common/fileCatalog/$datasetPath
    fi
    
    echo $datasetPath >>! dirstorm
	
    print writing entry for dataset removal to /a/data/xenia/users/common/datasetLog
    echo "removed "$datasetName" : user: "$USER"  date: "$(date)"  comments: ">>! /a/data/xenia/users/common/datasetLog

done


print "Attempting to remove directories: "
for dir in $directories; do

    print rm xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$dir
    rm xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$dir

    if [[ $? = 0 ]]; then
	print rm -r /a/data/xenia/users/common/fileCatalog/$dir
	rm -r /a/data/xenia/users/common/fileCatalog/$dir
    fi

    echo $dir >>! dirstorm

done

