#!/bin/sh

virtualenv venv

setupATLAS
lsetup python
lsetup root

if [ -s venv/bin/activate ]
then
    sed -i -e '1isetupATLAS\n
lsetup python\n
lsetup root\n' venv/bin/activate
else
    echo 'Missing venv/bin/activate!!!'
fi

echo 'venv successfully started! '
echo 'start your venv with source venv/bin/activate'