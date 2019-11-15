#!/bin/sh

FDK_ROOT_DIR="`pwd`"

$FDK_ROOT_DIR/opencore-amr-fdk-aac/configure \
--enable-static \
--disable-shared \
--host=aarch64-apple-darwin \
--prefix="$FDK_ROOT_DIR/fdk-aac-thin-output/arm64"
CC="xcrun -sdk iphoneos clang" \
AS="gas-preprocessor.pl $CC"
CFLAGS="-arch arm64 -miphoneos-version-min=7.0" \
LDFLAGS="-arch arm64 -miphoneos-version-min=7.0"
make clean
make -j8
make install
