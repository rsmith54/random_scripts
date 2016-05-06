

setupATLAS
source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/atlasLocalGccSetup.sh --gccVersion=gcc432_x86_64_slc5
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ROOTSYS/lib/
export LD_PRELOAD=$ROOTSYS/lib/libXrdPosixPreload.so
export XRDPOSIXSET=1
alias xrdcp='cp'

print "WARNING: xrdcp had been aliased to cp. Scripts that rely on xrdcp may not function properly; if so, try cleaning up your LD* environment variables."