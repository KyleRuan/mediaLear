### FFmpeg的编译产物

FFmpeg默认的编译会生成4个可执行文件和8个静态库。

1. 可执行文件包括用于转码、推流、Dump媒体文件的ffmpeg
2. 用于播放媒体文件的ffplay
3. 用于获取媒体文件信息的ffprobe
4. 作为简单流媒体服务器的ffserver。

8个静态库其实就是FFmpeg的8个模块，具体包括如下内容。

1. AVUtil：核心工具库，该模块是最基础的模块之一，下面的许多其他模块都会依赖该库做一些基本的音视频处理操作。
2. AVFormat：文件格式和协议库，该模块是最重要的模块之一，封装了Protocol层和Demuxer、Muxer层，使得协议和格式对于开发者来说是透明的。
3. AVCodec：编解码库，该模块也是最重要的模块之一，封装了Codec层，但是有一些Codec是具备自己的License的，FFmpeg是不会默认添加像libx264、FDK-AAC、lame等库的，但是FFmpeg就像一个平台一样，可以将其他的第三方的Codec以插件的方式添加进来，然后为开发者提供统一的接口。
4. AVFilter：音视频滤镜库，该模块提供了包括音频特效和视频特效的处理，在使用FFmpeg的API进行编解码的过程中，直接使用该模块为音视频数据做特效处理是非常方便同时也非常高效的一种方式。
5. AVDevice：输入输出设备库，比如，需要编译出播放声音或者视频的工具ffplay，就需要确保该模块是打开的，同时也需要libSDL的预先编译，因为该设备模块播放声音与播放视频使用的都是libSDL库。
6. SwrRessample：该模块可用于音频重采样，可以对数字音频进行声道数、数据格式、采样率等多种基本信息的转换。
7. SWScale：该模块是将图像进行格式转换的模块，比如，可以将YUV的数据转换为RGB的数据。
8. PostProc：该模块可用于进行后期处理，当我们使用AVFilter的时候需要打开该模块的开关，因为Filter中会使用到该模块的一些基础函数。

新增X264编码器需要在编辑FFmpeg里新增以下脚本：
```
--enable-muxer=h264 \
--enable-encoder=libx264 \
--enable-libx264 \
--extra-cflags=”-Iexternal-libs/x264/include” \
--extra-ldflags=”-Lexternal-libs/x264/lib” \
```

新增LAME编码器需要新增以下脚本：
```
--enable-muxer=mp3 \
--enable-encoder=libmp3lame \
--enable-libmp3lame \
--extra-cflags=”-Iexternal-libs/lame/include” \
--extra-ldflags=”-Lexternal-libs/lame/lib” \
```

新增FDK-AAC编码器需要新增以下脚本：
```
--enable-encoder=libfdk_aac \
--enable-libfdk_aac \
--extra-cflags=”-Iexternal-libs/fdk-aac/include” \
--extra-ldflags=”-Lexternal-libs/fdk-aac/lib” \
```
