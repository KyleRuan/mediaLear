#!/bin/sh

X264_ROOT_DIR="`pwd`"
mkdir -p ./X264-thin/arm64
export AS="gas-preprocessor.pl -arch arm -- xcrun -sdk iphoneos clang"
export CC="xcrun -sdk iphoneos clang"

$X264_ROOT_DIR/x264-stable/configure \
--enable-static \
--enable-pic \
--disable-asm \
--disable-shared \
--host=arm-apple-darwin \
--extra-cflags="-arch arm64 -mios-version-min=8.0" \
--extra-asflags="-arch arm64 -mios-version-min=8.0" \
--extra-ldflags="-arch arm64 -mios-version-min=8.0" \
--prefix="$X264_ROOT_DIR/X264-thin/arm64"
make clean
make -j8
make install