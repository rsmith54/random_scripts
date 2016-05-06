
if [ !"$ARCONDSET" ]; then
    source /a/data/xenia/share/atlasadmin/condor/Arcond/etc/arcond/arcond_setup.sh
    export ARCONDSET=1
fi

filePaths=($(arc_nevis_ls /data/xrootd))

for query in $@; do

    # remove _tid* from the end of the query:
    if [[ $query == *_tid* ]]; then
	query=${query%_tid*}
    fi
    # remove and .# from the very end of the query:
    query=${query%%.[0-9]}


    lastDatasetName=0

    for filePath in $filePaths; do

	if [[ $filePath == */data/xrootd/* ]]; then

	    datasetName=${filePath%/*}
	    datasetName=${datasetName##*/}
	
	    if [[ $datasetName == $query* || $query == all ]]; then
		
		if [[ $datasetName != $lastDatasetName ]]; then
		    
		    lastDatasetName=$datasetName
		    
		    print 
		    print $datasetName
		fi
		
		fileName=${filePath##*/}
		
		print    $fileName
		
		if [[ $(source /data/users/common/xrootls.sh $datasetName $fileName) != $fileName ]]; then
		    
		    echo $fileName >>! /data/users/common/fileCatalog/$datasetName
		fi
	    fi
	fi
    done
done
