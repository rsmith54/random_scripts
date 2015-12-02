#!/bin/zsh
# quick script to return the files that have been added to xrootd for the specified dataset and otherwise mimic ls, with a bit of extra globbing

relativePath=$1
relativePath=${relativePath#/}
relativePath=${relativePath%/}


if [ -f "/a/data/xenia/users/common/fileCatalog/$relativePath" ]; then

    while read line; do
        if [[ $line == *$2* ]]; then
	    print $line
        fi
    done < /a/data/xenia/users/common/fileCatalog/$relativePath
else
    if [ -d "/a/data/xenia/users/common/fileCatalog/$relativePath" ]; then
	
	matches=(/a/data/xenia/users/common/fileCatalog/$relativePath/*) 2>&-
	for resultPath in $matches; do
	    resultPath=${resultPath#/a/data/xenia/users/common/fileCatalog/}
	    print $resultPath
	done
	
    else
	matches=(/a/data/xenia/users/common/fileCatalog/$relativePath*) #2>&-
	for resultPath in $matches; do
	    resultPath=${resultPath#/a/data/xenia/users/common/fileCatalog/}
	    print $resultPath
	done
    fi
fi


