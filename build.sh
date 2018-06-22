BITCOIN_CONFIG_ALL="--disable-dependency-tracking --prefix=$TRAVIS_BUILD_DIR/depends/$HOST --bindir=$OUTDIR/bin --libdir=$OUTDIR/lib"
depends/$HOST/native/bin/ccache --max-size=$CCACHE_SIZE
test -n "$USE_SHELL" && eval '"$USE_SHELL" -c "./autogen.sh"' || ./autogen.sh
./configure --cache-file=config.cache $BITCOIN_CONFIG_ALL $BITCOIN_CONFIG || ( cat config.log && false)
make distdir PACKAGE=bitcoin VERSION=$HOST
cd bitcoin-$HOST
./configure --cache-file=../config.cache $BITCOIN_CONFIG_ALL $BITCOIN_CONFIG || ( cat config.log && false)
make $MAKEJOBS $GOAL || ( echo "Build failure. Verbose build follows." && make  V=1 ; false )
export LD_LIBRARY_PATH=$TRAVIS_BUILD_DIR/depends/$HOST/lib
