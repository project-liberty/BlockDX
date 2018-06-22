#!/bin/bash

VERSION_MAJOR=`sed -n 's/#define CLIENT_VERSION_MAJOR \([0-9]*$\)/\1/p' bitcoin-$HOST/src/clientversion.h`
VERSION_MINOR=`sed -n 's/#define CLIENT_VERSION_MINOR \([0-9]*$\)/\1/p' bitcoin-$HOST/src/clientversion.h`
VERSION_REVISION=`sed -n 's/#define CLIENT_VERSION_REVISION \([0-9]*$\)/\1/p' bitcoin-$HOST/src/clientversion.h`
VERSION_BUILD=`sed -n 's/#define CLIENT_VERSION_BUILD \([0-9]*$\)/\1/p' bitcoin-$HOST/src/clientversion.h`

OUTDIR=$TRAVIS_BUILD_DIR/out/$TRAVIS_PULL_REQUEST/$TRAVIS_JOB_NUMBER-$HOST
mkdir -p $OUTDIR/bin

ARCHIVE_CMD="zip"
ARCHIVE_NAME="v$VERSION_MAJOR.$VERSION_MINOR.$VERSION_REVISION.$VERSION_BUILD-"

if [[ $HOST = "i686-w64-mingw32" ]]; then
  ARCHIVE_NAME+="windows-x86.zip"
elif [[ $HOST = "x86_64-w64-mingw32" ]]; then
    ARCHIVE_NAME+="windows-x64.zip"
elif [[ $HOST = "x86_64-unknown-linux-gnu" ]]; then
    if [[ $DEP_OPTS = "NO_WALLET=1" ]]; then    
        ARCHIVE_NAME+="linux-x64-no-wallet.tar.gz"
        ARCHIVE_CMD="tar -czf"
    else
        ARCHIVE_NAME+="linux-x64.tar.gz"
        ARCHIVE_CMD="tar -czf"
    fi  
elif [[ $HOST = "i686-pc-linux-gnu" ]]; then
    ARCHIVE_NAME+="linux-x86.tar.gz"
    ARCHIVE_CMD="tar -czf"
elif [[ $HOST = "x86_64-apple-darwin11" ]]; then
    ARCHIVE_NAME+="osx-x64.zip"
fi

if [[ $HOST = "x86_64-apple-darwin11" ]]; then
    find $TRAVIS_BUILD_DIR -type f | grep -i Liberty-Core.dmg$ | xargs -i cp {} $OUTDIR/bin
else
    cp bitcoin-$HOST/src/qt/liberty-qt $OUTDIR/bin/ || cp bitcoin-$HOST/src/qt/liberty-qt.exe $OUTDIR/bin/ || echo "no liberty wallet binaries!"
    cp bitcoin-$HOST/src/libertyd $OUTDIR/bin/ || cp bitcoin-$HOST/src/libertyd.exe $OUTDIR/bin/ || echo "no liberty daemon binaries!"
    cp bitcoin-$HOST/src/liberty-cli $OUTDIR/bin/ || cp bitcoin-$HOST/src/liberty-cli.exe $OUTDIR/bin/ || echo "no liberty-cli binaries!"
    strip "$OUTDIR/bin"/* || echo "nothing to strip"
fi


cd $OUTDIR/bin
#delete any test bins that may have been copied to our archive folder.
find . -name 'test*' -delete
ARCHIVE_CMD="$ARCHIVE_CMD $ARCHIVE_NAME *"
eval $ARCHIVE_CMD

mkdir -p $OUTDIR/zip
mv $ARCHIVE_NAME $OUTDIR/zip

sleep $[ ( $RANDOM % 6 )  + 1 ]s