#!/bin/sh
CONFIGURE_FLAGS="--disable-shared --disable-frontend"

ARCHS="arm64 armv7 i386"
for ARCH in $ARCHS
do  
    OUTPUT_PATH="`pwd`/thin/$ARCH"
    mkdir -p $OUTPUT_PATH
    ./lame/configure \
    ${CONFIGURE_FLAGS} \
    --host=arm-apple-darwin \
    --prefix=${OUTPUT_PATH} \
    CC="xcrun -sdk iphoneos clang -arch $ARCH" \
    CFLAGS="-arch $ARCH -fembed-bitcode -miphoneos-version-min=7.0" \
    LDFLAGS="-arch $ARCH -fembed-bitcode -miphoneos-version-min=7.0"
    make clean
    make -j8
    make install
done
echo "合并lib"
ARCHS_ARR=(${ARCHS})
# lipo
lipo -create `pwd`/thin/${ARCHS_ARR[0]}/lib/libmp3lame.a  \
`pwd`/thin/${ARCHS_ARR[1]}/lib/libmp3lame.a  \
`pwd`/thin/${ARCHS_ARR[2]}/lib/libmp3lame.a \
-output libmp3lame.a
