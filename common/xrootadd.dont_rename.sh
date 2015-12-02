#!/bin/zsh
#Script to add all of the files from a dataset to xrootd, discarding tid information and naming files in a systematic way

inputDSPath=$1
inputDSPath=${inputDSPath%/}

datasetName=${inputDSPath##*/}

relativePath=$2
relativePath=${relativePath#/}
relativePath=${relativePath%/}


if [[ $#relativePath == 0 ]]; then

    print "you must now specify a relative path in xrootd which matches the directory structure of fileCatalog"
    print "to add a path, specify it with xrootmkdir.sh"
    return
    
fi

if [ ! -d /data/users/common/fileCatalog/$relativePath ]; then

    print $relativePath" does not exist, please check that this is the right path, if so, use xrootmkdir.sh to create it"

    return
fi



# remove _tid* from the end of the dataset name:
if [[ $datasetName == *_tid* ]]; then
    datasetName=${datasetName%_tid*}
fi
# remove and .# from the very end of the dataset name:
datasetName=${datasetName%%.[0-9]}

integer nfiles
nfiles=0

integer nfilesadded
nfilesadded=0

for inputFilePath in $inputDSPath/*; do
    
    inputFileName=${inputFilePath##*/}
    
    if [[ $inputFileName == *.root* && $inputFileName != *.GLOBAL.* ]]; then

	if [[ $inputFileName == NTUP.*.root ]]; then

	    number=${inputFileName#NTUP.}
	    number=${inputFileName%%[!0-9]*}

	    outputFile=$inputFileName
	
	else

# 	    if [[ $inputFileName == *._[0-9]*.root* ]]; then

#      	        #Isolate the file number from the data file (format should be universal?)
# 		number=${inputFileName#*._}
# 		number=${number%%[!0-9]*}
	  
#    	        #Fix the number of digits, if necessary:
# 		if [[ $#number -ne 5 ]]; then
# 		    if [[ temp -lt 99999 ]]; then
# 			number=$(printf "%05d" $number)
# 		    fi
# 		fi
		
# 	        outputFile=NTUP.$number.root
		
# 	    else
	    
	    number="-1"
	    
	    outputFile=$inputFileName		
		
#	    fi

	fi
	    
	#check if this file has already been added:
	if [[ $(source /data/users/common/xrootls.sh $relativePath/$datasetName $outputFile) == $outputFile ]]; then
	    #it has been added, continue
	    print $relativePath/$datasetName/$outputFile has already been added to xrootd
		
	else
	    print
	    print xrdcp $inputFilePath xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$relativePath/$datasetName/$outputFile
	    xrdcp $inputFilePath xroot://xenia.nevis.columbia.edu:1094//data/xrootd/$relativePath/$datasetName/$outputFile
	    
	    if [[ $? = 0 ]]; then
		print adding record of $outputFile to /data/users/common/fileCatalog/$relativePath/$datasetName
		echo $outputFile >>! /data/users/common/fileCatalog/$relativePath/$datasetName
		((nfilesadded++))
	    fi
	fi
	((nfiles++))
    fi

done

if [[ $nfilesadded -ne 0 ]]; then
#Write to dataset catalog:
    print writing entry for dataset to /data/users/common/datasetLog
    if [[ $((number)) == $nfiles ]]; then
	echo $datasetName" : "$nfiles" files,  0 missing,  user: "$USER"  date: "$(date)"  comments: ">>! /data/users/common/datasetLog
    else

	if [[ $((number)) == -1 ]]; then

	    print "Files where not of the right format to determine if the number of files ("$nfiles") was correct. Dataset MAY be incomplete"
	    echo $datasetName" : "$nfiles" files,  ? missing,  user: "$USER"  date: "$(date)"  comments: ">>! /data/users/common/datasetLog

	else
	    print Warning: the dataset is incomplete. It seems to be missing at least $((number - $nfiles)) files
	    echo $datasetName" : "$nfiles" files,  "$((number - $nfiles))" missing,  user: "$USER"  date: "$(date)"  comments: ">>! /data/users/common/datasetLog
	fi
    fi
    
    print $nfilesadded files from dataset $datasetName were copied to xrootd
else
    print no files from $datasetName where copied to xrootd
fi
