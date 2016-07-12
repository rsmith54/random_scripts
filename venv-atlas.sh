#!/bin/bash

if [ -d venv ]
then
    echo 'venv already exists locally.  Exiting'.
    exit
else
    virtualenv venv

    source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
    lsetup python
    lsetup root

    if [ -f venv/bin/activate ]
    then
	sed -i '1i setupATLAS\n' venv/bin/activate
	sed -i '2i lsetup python\n' venv/bin/activate
	sed -i '3i lsetup root\n' venv/bin/activate
    else
	echo 'Missing venv/bin/activate!!!'
    fi

    echo 'venv successfully started! '
    echo 'start your venv with source venv/bin/activate'
fi