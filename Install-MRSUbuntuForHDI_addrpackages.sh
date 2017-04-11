#!/usr/bin/env bash

echo "Action script for installing MRS on HDI..."

#versions
MRO_FILE_VERSION=3.3
MRS_FILE_VERSION=9.0
AZUREML_VERSION=2.13

#filenames
MRS_FILENAME=MRS_Linux.tar.gz
REVO_PROBE_FILENAME=RevoProbe.py
MRSOP_PROBE_FILENAME=MrsOpProbe.py
AZUREML_TAR_FILE=AzureML_"$AZUREML_VERSION"_Compiled.tar.gz
ELAPSED_TIME_LOG=/tmp/installRServerElapsedTime.log

#storage with CDN enabled
#the pattern we're using here is, http://mrshdiprod.azureedge.net/{mrs release}/{mrs build number}.{version number of all other packages}
BLOB_STORAGE=https://mrshdiprod.azureedge.net/mrs-hdi-binaries-9-0-1/1978.0
SAS="?sv=2014-02-14&sr=c&sig=D92aent8YxDetGS%2B6abbUou0oEzp2KDkLcwUq%2FUGmzs%3D&st=2016-11-04T07%3A00%3A00Z&se=2020-01-01T08%3A00%3A00Z&sp=r"
#hostname identifiers
HEADNODE=^hn
EDGENODE=^ed
WORKERNODE=^wn
ZOOKEEPERNODE=^zk

#misc
USERNAME=""
IS_HEADNODE=0
IS_EDGENODE=0
R_LIBRARY_DIR=/usr/lib64/microsoft-r/"$MRO_FILE_VERSION"/lib64/R/library
RPROFILE_PATH=/usr/lib64/microsoft-r/"$MRO_FILE_VERSION"/lib64/R/etc/Rprofile.site
TRACKR_OPTIN_PATH=/usr/lib64/microsoft-r/"$MRO_FILE_VERSION"/lib64/R/.optIn
PROBES_CONFIG=`python -c "from pkg_resources import resource_filename; print resource_filename('hdinsight_probes', 'probes_config.json')"`
PROBES_PYTHON_DIR=`python -c "import os, hdinsight_probes.probes; print os.path.dirname(hdinsight_probes.probes.__file__)"`
R_LOG_PYTHON="$R_LIBRARY_DIR"/RevoScaleR/pythonScripts/common/logScaleR.py

#retry
MAXATTEMPTS=3

#set non-interactive mode
export DEBIAN_FRONTEND=noninteractive

#main function
main()
{
    #if there is any failure in the script, retry the entire script
	retry start
}

start()
{
	SECONDS=0

	executor installRpackages
	if [[ $? -ne 0 ]]; then return 1; fi

	echo "Total elapsed time = $SECONDS seconds" | tee -a $ELAPSED_TIME_LOG
	logElapsedTime
	echo "Finished"
	exit 0
}

retry()
{
	#retries to install if there is a failure

	ATTMEPTNUM=1
	RETRYINTERVAL=2
	RETVAL_RETRY=0

	"$1"
    if [ "$?" != "0" ]
    then
        RETVAL_RETRY=1
	fi

	while [ $RETVAL_RETRY -ne 0 ]; do
		if (( ATTMEPTNUM == MAXATTEMPTS ))
		then
			echo "Attempt $ATTMEPTNUM failed. no more attempts left."
			return 1
		else
			echo "Attempt $ATTMEPTNUM failed! Retrying in $RETRYINTERVAL seconds..."
			sleep $(( RETRYINTERVAL ))
			let ATTMEPTNUM=ATTMEPTNUM+1

			"$1"
			if [ "$?" != "0" ]
			then
				RETVAL_RETRY=1
			else
				return 0
			fi
		fi
	done

	return 0
}

executor()
{
	#wrapper function that calculates time to execute another function

	RETVAL_EXE=0
	START=`date +%s%N`

	#execute the function passed as a parameter
	"$1"
	if [ "$?" != "0" ]
	then
		RETVAL_EXE=1
	fi

	END=`date +%s%N`
	ELAPSED=`awk 'BEGIN {printf("%.3f", ('$END' - '$START') / 1000000000)}'`
	echo "Elapsed time for $1 = $ELAPSED seconds" >> $ELAPSED_TIME_LOG

	return $RETVAL_EXE
}

downloadHelper()
{
	echo "-------------------------------------------------------"
	echo "Import the helper method module..."
	echo "-------------------------------------------------------"

	wget -O /tmp/HDInsightUtilities-v01.sh -q https://hdiconfigactions.blob.core.windows.net/linuxconfigactionmodulev01/HDInsightUtilities-v01.sh && source /tmp/HDInsightUtilities-v01.sh && rm -f /tmp/HDInsightUtilities-v01.sh
}

downloadMRS()
{
	echo "-------------------------------------------------------"
	echo "Download MRS files..."
	echo "-------------------------------------------------------"

	download_file "$BLOB_STORAGE/$MRS_FILENAME$SAS" /tmp/$MRS_FILENAME
	download_file "$BLOB_STORAGE/$REVO_PROBE_FILENAME$SAS" /tmp/$REVO_PROBE_FILENAME
	download_file "$BLOB_STORAGE/$MRSOP_PROBE_FILENAME$SAS" /tmp/$MRSOP_PROBE_FILENAME
}

installMRS()
{
	echo "-------------------------------------------------------"
	echo "Install MRS ..."
	echo "-------------------------------------------------------"

	if [ -f /tmp/"$MRS_FILENAME" ]
	then
		tar xvfz /tmp/"$MRS_FILENAME" -C /tmp
		cd /tmp/MRS_Linux
		chmod 777 install.sh
		./install.sh -a -p -s
		rm -f $TRACKR_OPTIN_PATH
	else
		echo "MRS not downloaded"
		return 1
	fi

	echo "Configure R env variables for MRS..."
	if [ -f $RPROFILE_PATH ]
	then
		sed -i.bk -e "1s@^@Sys.setenv(SPARK_HOME=\"/usr/hdp/current/spark2-client\")\n@" $RPROFILE_PATH
		sed -i -e "1s@^@Sys.setenv(SPARK_MAJOR_VERSION=2)\n@" $RPROFILE_PATH
		sed -i -e "1s@^@Sys.setenv(AZURE_SPARK=1)\n@" $RPROFILE_PATH
	else
		echo "$RPROFILE_PATH does not exist"
		return 1
	fi
}

createSymbolLinkForDeployR()
{
	echo "-------------------------------------------------------"
	echo "Create symbol link for DeployR..."
	echo "-------------------------------------------------------"

	cd /lib/x86_64-linux-gnu
	ln -sf libpcre.so.3 libpcre.so.0
	ln -sf liblzma.so.5 liblzma.so.0

	cd /usr/lib/x86_64-linux-gnu
	ln -sf libicui18n.so.55 libicui18n.so.36
	ln -sf libicuuc.so.55 libicuuc.so.36
	ln -sf libicudata.so.55 libicudata.so.36
}

configureRWithJava()
{
	echo "-------------------------------------------------------"
	echo "Configure R for use with Java..."
	echo "-------------------------------------------------------"

	ln -sf /usr/bin/realpath /usr/local/bin/realpath

	echo "Configure R for use with Java..."
	R CMD javareconf
}

updateDependencies()
{
	echo "-------------------------------------------------------"
	echo "Update dependencies..."
	echo "-------------------------------------------------------"

	apt-get install -y -f
}

configureSSHUser()
{
	echo "-------------------------------------------------------"
	echo "Configuration for the specified 'ssh' user..."
	echo "-------------------------------------------------------"

	if [ $IS_HEADNODE == 1 ] || [ $IS_EDGENODE == 1 ]
	then
		USERNAME=$( grep :Ubuntu: /etc/passwd | cut -d ":" -f1)

		if [ $IS_EDGENODE == 1 ]
		then
			$(hadoop fs -test -d /user/RevoShare/$USERNAME)
			if [[ "$?" != "0" ]]
			then
				echo "Creating HDFS directory..."
				hadoop fs -mkdir /user/RevoShare/$USERNAME
				hadoop fs -chmod 777 /user/RevoShare/$USERNAME
			fi
		fi

		if [ ! -d /var/RevoShare/$USERNAME ]
		then
			echo "Creating local directory..."
			mkdir -p /var/RevoShare/$USERNAME
			chmod 777 /var/RevoShare/$USERNAME
		fi
	fi
}

removeTempFiles()
{
	echo "-------------------------------------------------------"
	echo "Remove MRS temp files..."
	echo "-------------------------------------------------------"

	cd /tmp

	if [ -f /tmp/"$MRS_FILENAME" ]
	then
		rm -f /tmp/"$MRS_FILENAME"
	fi
	if [ -d /tmp/MRS_Linux ]
	then
		rm -rf /tmp/MRS_Linux
	fi
}

testR()
{
	#Run a small set of R commands to give some confidence that the install went ok
	echo "-------------------------------------------------------"
	echo "Test R..."
	echo "-------------------------------------------------------"

	R --no-save --no-restore -q -e 'options(mds.telemetry=0);d=rxDataStep(iris)'  2>&1 >> /tmp/rtest_inst.log
	if [ $? -eq 0 ]
	then
		echo "R installed properly"
	else
		echo "R not installed properly"
		return 1
	fi

	echo "-------------------------------------------------------"
	echo "Test Rscript..."
	echo "-------------------------------------------------------"

	Rscript --no-save --no-restore -e 'options(mds.telemetry=0);d=rxDataStep(iris)'  2>&1 >> /tmp/rtest_inst.log
	if [ $? -eq 0 ]
	then
		echo "Rscript installed properly"
	else
		echo "Rscript not installed properly"
		return 1
	fi
}

installRpackages()
{
	#Run a small set of R commands to give some confidence that the install went ok
	echo "-------------------------------------------------------"
	echo "Installing official R packages"
	echo "-------------------------------------------------------"

	Rscript -e "install.packages('lubridate', 'tidyverse', 'stringr', 'optparse', dependencies = TRUE)" 2>&1 >> /tmp/rpackages_inst.log
#	R --no-save --no-restore -q -e 'options(mds.telemetry=0);d=rxDataStep(iris)'  2>&1 >> /tmp/rtest_inst.log
	if [ $? -eq 0 ]
	then
		echo "installed rpackages list"
	else
		echo "failed to install packages"
		return 1
	fi
}

determineNodeType()
{
	echo "-------------------------------------------------------"
	echo "Determine node type..."
	echo "-------------------------------------------------------"

	if hostname | grep "$HEADNODE"0 2>&1 > /dev/null
	then
		IS_HEADNODE=1
	fi

	if hostname | grep $EDGENODE 2>&1 > /dev/null
	then
		IS_EDGENODE=1
	fi
}

setupTelemetry()
{
	# We only want to install telemetry on the headnode or edgenode
	if [ $IS_HEADNODE == 1 ] || [ $IS_EDGENODE == 1 ]
	then
		echo "-------------------------------------------------------"
		echo "Setup telemetry and logging..."
		echo "-------------------------------------------------------"

		MDS_OPTIONS='options(mds.telemetry=1)\noptions(mds.logging=1)\noptions(mds.target=\"azurehdi\")\n\n'

		if [ -f $RPROFILE_PATH ]
		then
			if ! grep 'options(mds' $RPROFILE_PATH 2>&1 > /dev/null
			then
				sed -i.bk -e "1s/^/$MDS_OPTIONS/" $RPROFILE_PATH
				sed -i 's/\r$//' $RPROFILE_PATH
			fi
		else
			echo "$RPROFILE_PATH does not exist"
			return 1
		fi
	fi
}

setupHealthProbe()
{
	# We only want to install the health probe on the headnode or edgenode
	if [ $IS_HEADNODE == 1 ] || [ $IS_EDGENODE == 1 ]
	then
		echo "-------------------------------------------------------"
		echo "Setup the R-Server HDI health probe..."
		echo "-------------------------------------------------------"

		if [ -f $PROBES_CONFIG ]
		then
			if ! grep 'RevoProbe' $PROBES_CONFIG 2>&1 > /dev/null
			then
				echo "Modify the probes config file..."

				cp "$PROBES_CONFIG" "$PROBES_CONFIG".bk

				#define the probe config entry
				read -d '' REVOPROBE <<-"EOF"
[\\n
           {\\n
               \"name\" : \"RevoProbe\",\\n
               \"version\" : \"0.1\",\\n
               \"script\" : \"probes.RevoProbe.RevoProbe\",\\n
               \"interval_seconds\" : 300,\\n
               \"timeout_seconds\" : 60,\\n
               \"node_types\" : \[\"headnode\"\]\\n
           },\\n
           {\\n
               \"name\" : \"MrsOpProbe\",\\n
               \"version\" : \"0.1\",\\n
               \"script\" : \"probes.MrsOpProbe.MrsOpProbe\",\\n
               \"interval_seconds\" : 300,\\n
               \"timeout_seconds\" : 60,\\n
               \"node_types\" : \[\"headnode\"\]\\n
           },
EOF

				# Remove all other probe configurations on the edgenode
				if [ $IS_EDGENODE == 1 ]
				then
					REVOPROBE=$(echo "$REVOPROBE"|sed 's/headnode/edgenode/')
				fi

				REVOPROBE=$(echo "$REVOPROBE"|tr '\n' ' ')

				# Insert the RevoProbe configuration
				sed -i -e "0,/\[/s//${REVOPROBE}/" $PROBES_CONFIG

				# Get rid of any remaining '\r' characters
				sed -i 's/\r$//' $PROBES_CONFIG

				if [ -d $PROBES_PYTHON_DIR ]
				then
					if [ -f /tmp/"$REVO_PROBE_FILENAME" ]
					then
						cd $PROBES_PYTHON_DIR
						mv /tmp/"$REVO_PROBE_FILENAME" .
						pycompile "$REVO_PROBE_FILENAME"
						chmod 755 "$REVO_PROBE_FILENAME"
					fi

					if [ -f /tmp/"$MRSOP_PROBE_FILENAME" ]
					then
						cd $PROBES_PYTHON_DIR
						mv /tmp/"$MRSOP_PROBE_FILENAME" .
						pycompile "$MRSOP_PROBE_FILENAME"
						chmod 755 "$MRSOP_PROBE_FILENAME"
					fi

					echo "Restart the probes service.."
					service hdinsight-probes stop
					service hdinsight-probes start
				else
					echo "$PROBES_PYTHON_DIR does not exist"
					return 1
				fi
			fi
		else
			echo "$PROBES_CONFIG does not exist"
			return 1
		fi
	fi
}

writeClusterDefinition()
{
	echo "-------------------------------------------------------"
	echo "Writing cluster definition to HDFS..."
	echo "-------------------------------------------------------"

	NODETYPE="unknown"
	if hostname | grep $HEADNODE 2>&1 > /dev/null
	then
		NODETYPE="headnode"
	fi

	if hostname | grep $EDGENODE 2>&1 > /dev/null
	then
		NODETYPE="edgenode"
	fi

	if hostname | grep $WORKERNODE 2>&1 > /dev/null
	then
		NODETYPE="workernode"
	fi

	if hostname | grep $ZOOKEEPERNODE 2>&1 > /dev/null
	then
		NODETYPE="zookeepernode"
	fi

	CORES=""
	if grep 'cpu cores' /proc/cpuinfo 2>&1 > /dev/null
	then
		CORES=$(grep 'cpu cores' /proc/cpuinfo | head -1 | cut -d ':' -f2 | tr -d '[:blank:]')
	else
		echo "Cannot get node cpu settings"
		return 1
	fi

	MEMORY=""
	if grep 'cpu cores' /proc/cpuinfo 2>&1 > /dev/null
	then
		MEMORY=$(grep 'MemTotal' /proc/meminfo |  cut -d ':' -f2 | tr -d '[:blank:]')
		MEMORY=${MEMORY::-2}
	else
		echo "Cannot get node memory settings"
		return 1
	fi

	HOSTNAME=`hostname`
	NODEINFO="$NODETYPE;$MEMORY;$CORES"
	echo $NODEINFO > /tmp/$HOSTNAME

	$(hadoop fs -test -d /cluster-info)
	if [[ "$?" != "0" ]]
	then
		echo "Creating HDFS directory for cluster-info..."
		hadoop fs -mkdir /cluster-info
	fi

	if [ -f /tmp/$HOSTNAME ]
	then
		echo "Creating HDFS hostname file..."
		hadoop fs -copyFromLocal -f /tmp/$HOSTNAME /cluster-info
		rm -rf /tmp/$HOSTNAME
	else
		echo "/tmp/$HOSTNAME does not exist"
	fi
}

installAzureMLRPackage()
{
	# We only want to install AzureML on the edgenode
	if  [ $IS_EDGENODE == 1 ]
	then

		echo "-------------------------------------------------------"
		echo "Installing AzureML R package..."
		echo "-------------------------------------------------------"

		if [ -d $R_LIBRARY_DIR ]
		then

			cd $R_LIBRARY_DIR

			echo "Download and install AzureML tar file..."
			#the tar file contains a "pre-compiled" archive of dependent R packages needed for the AzureML R package
			download_file "$BLOB_STORAGE/$AZUREML_TAR_FILE$SAS" ./$AZUREML_TAR_FILE

			if [ -f $R_LIBRARY_DIR/$AZUREML_TAR_FILE ]
			then
				tar -xzf $AZUREML_TAR_FILE
				rm $AZUREML_TAR_FILE
			else
				echo "AzureML R Package not downloaded"
				return 1
			fi
		else
			echo "Cannot find $R_LIBRARY_DIR"
			return 1
		fi
	fi
}

autoSparkSetting()
{
	if [ $IS_EDGENODE == 1 ]
	then
		echo "-------------------------------------------------------"
		echo "Setup spark executor settings..."
		echo "-------------------------------------------------------"
		HADOOP_CONFDIR=$(hadoop envvars | grep HADOOP_CONF_DIR | cut -d "'" -f 2)
		YARN_MEMORY=$(xmllint --xpath "/configuration/property[name[text()='yarn.nodemanager.resource.memory-mb']]/value/text()" ${HADOOP_CONFDIR}/yarn-site.xml)
		VCORES=$(xmllint --xpath "/configuration/property[name[text()='yarn.nodemanager.resource.cpu-vcores']]/value/text()" ${HADOOP_CONFDIR}/yarn-site.xml)
		CORES_AVL=$(($VCORES-3))
		EXECUTOR_MEMORY=$(($((YARN_MEMORY-3000))*2/5))
		CORE_NUM=$(($((YARN_MEMORY-3000))*8/35000))
		TMPCORE=$(($CORE_NUM<$CORES_AVL?$CORE_NUM:$CORES_AVL))
		EXECUTOR_CORES=$(($TMPCORE>1?$TMPCORE:1))
		EXECUTOR_NUM=$(grep -c -v '^ *$' ${HADOOP_CONFDIR}/slaves)

		SPARK_OPTIONS='RevoScaleR::rxOptions(spark.executorCores='${EXECUTOR_CORES}',spark.executorMem=\"'${EXECUTOR_MEMORY}'m\",spark.executorOverheadMem=\"'${EXECUTOR_MEMORY}'m\",spark.numExecutors='$EXECUTOR_NUM')\n'

		if [ -f $RPROFILE_PATH ]
		then
			if ! grep 'options(executor' $RPROFILE_PATH 2>&1 > /dev/null
			then
				sed -i.bk -e "$ a $SPARK_OPTIONS" $RPROFILE_PATH
			fi
		else
			echo "$RPROFILE_PATH does not exist"
			return 1
		fi
	fi
}

logElapsedTime()
{
	echo "-------------------------------------------------------"
	echo "Log Elapsed time..."
	echo "-------------------------------------------------------"

	if [ -f $R_LOG_PYTHON ]
	then
			python $R_LOG_PYTHON -m $ELAPSED_TIME_LOG -f 1 -p 1 2>&1 > /dev/null
	else
			echo "$R_LOG_PYTHON does not exist"
	fi
}

#call the main function
main "$@"
