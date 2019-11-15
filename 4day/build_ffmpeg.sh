#!/bin/sh
OUTPUT_PATH="`pwd`/ffmpeg-output"

CONFIGURE_FLAGS="--disable-stripping \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-avdevice \
--disable-devices \
--disable-indevs \
--disable-outdevs \
--disable-debug \
--disable-asm \
--disable-yasm \
--disable-doc \
--enable-small \
--enable-dct \
--enable-dwt \
--enable-lsp \
--enable-mdct \
--enable-rdft \
--enable-fft \
--enable-version3 \
--enable-nonfree \
--disable-filters \
--disable-postproc \
--disable-bsfs \
--enable-bsf=aac_adtstoasc \
--enable-bsf=h264_mp4toannexb \
--disable-encoders \
--enable-encoder=pcm_s16le \
--enable-encoder=aac \
--enable-encoder=libvo_aacenc \
--disable-decoders \
--enable-decoder=aac \
--enable-decoder=mp3 \
--enable-decoder=pcm_s16le \
--disable-parsers \
--enable-parser=aac  \
--disable-muxers \
--enable-muxer=flv \
--enable-muxer=wav \
--enable-muxer=adts \
--disable-demuxers \
--enable-demuxer=flv \
--enable-demuxer=wav \
--enable-demuxer=aac \
--disable-protocols \
--enable-protocol=rtmp \
--enable-protocol=file \
--enable-libfdk_aac \
--enable-libx264 \
--enable-gpl \
--enable-cross-compile \
--prefix=$OUTPUT_PATH"

X264="`pwd`/external/X264"
FDKAAC="`pwd`/external/FDK-AAC"

./ffmpeg-4.2/configure \
$CONFIGURE_FLAGS \
--target-os=darwin \
--cc="xcrun -sdk iphoneos clang" \
--arch=arm64 \
--extra-cflags="-arch arm64 -mios-version-min=8.0 -I$FDKAAC/include -I$X264/include" \
--extra-ldflags="-arch arm64 -mios-version-min=8.0 -L$FDKAAC/lib -L$X264/lib"
make clean
make -j8
make install
