# FFmpeg命令行工具的使用


## ffprobe

ffprobe是用于查看媒体文件头信息的工具。比如查看一下音频文件。`ffprobe high.mp3`
![ffprobe 音频文件](../md_pic/%E6%88%AA%E5%B1%8F2019-11-17%E4%B8%8B%E5%8D%8811.28.36.png)

这行信息表明，该音频文件的时长是5分14秒零830毫秒，开始播放时间是0，整个媒体文件的比特率是346Kbit/s。
紧接着上面那行的消息表示这个流是音频流，编码格式是MP3格式，采样率是44.1kHz，声道是立体声，采样表示格式是fltp，这路流的比特率是320Kbit/s。
再比如查看一个视频文件`ffprobe movie.mp4`


![ffprobe 视频文件](../md_pic/%E6%88%AA%E5%B1%8F2019-11-17%E4%B8%8B%E5%8D%8811.44.08.png)

可以看到视频文件有两个流。首先是整个文件的metadata信息，包裹总时长，起始时间，比特率10593kb/s。然后是各个流的信息。第二个流是一个视频流，编码方式是H264的格式（封装格式是AVC1），每一帧的数据表示是YUV420P的格式，分辨率是720×1280，这路流的比特率是10548Kbit/s，帧率是每秒钟29.3帧

### fprobe高级的用法

1. ` -show_format `  输出格式信息format_name、时间长度duration、文件大小size、比特率bit_rate、流的数目nb_streams等,例如`ffprobe -show_format movie.mp4`
2. `-print_format json -show_streams` 可以以JSON格式的形式输出具体每一个流最详细的信息，视频中会有视频的宽高信息、是否有b帧、视频帧的总数目、视频的编码格式、显示比例、比特率等信息，音频中会有音频的编码格式、表示格式、声道数、时间长度、比特率、帧的总数目等信息  `ffprobe -print_format json -show_streams movie.mp4`
3. ` -show_frames` 显示帧信息`ffprobe -show_frames movie.mp4`


## ffplay
`ffplay movie.mp4` 就开始播放音频或者视频，按s键则可以进入frame-step模式,即按s键一次就会播放下一帧图像.

1. `-loop n` 让文件重复播放n次。 `ffplay movie.mp4 -loop 10`
2. `-ast` 可以指定一路音频流播放（普通话，粤语双音的时候） `ffplay movie.mp4 -ast 1`,如果当指定的流，不存在时，就会静音。同样`-vst`指定一路视频流
3. 音频pcm文件的播放，`ffplay song.pcm -f s16le -channels 2 -ar 44100` 。其实本质就是设置了格式（-f）、声道数（-channels）、采样率（-ar）。这些设置必须设置正确，如果其中任何一项参数设置不正确，都不会得到正常的播放结果。WAV无损音乐其实就是在PCM头部添加44个字节，用于标识这个PCM的采样表示格式、声道数、采样率等信息
4. `ffplay -f rawvideo -pixel_format yuv420p -s 480*480 texture.yuv`,若想让ffplay显示一张YUV的原始数据表示的图片，那么需要告诉ffplay一些重要的信息，其中包括格式（-f rawvideo代表原始格式）、表示格式（-pixel_format yuv420p）、宽高（-s 480*480）。
5. 对于RGB表示的图像，其实是一样的，命令如下：`ffplay -f rawvideo -pixel_format rgb24 -s 480*480 texture.rgb`

### 音视频同步

对于视频播放器，不得不提的一个问题就是音画同步，在ffplay中音画同步的实现方式其实有三种，分别是：
1. 以音频为主时间轴作为同步源；
2. 以视频为主时间轴作为同步源；
3. 以外部时钟为主时间轴作为同步源。

下面就以音频为主时间轴来作为同步源来作为案例进行讲解，这也是后面章节中完成视频播放器项目时要使用到的对齐策略，并且在ffplay中默认的对齐方式也是以音频为基准进行对齐的。
首先要声明的是，播放器接收到的视频帧或者音频帧，内部都会有时间戳（PTS时钟）来标识它实际应该在什么时刻进行展示。实际的对齐策略如下：比较视频当前的播放时间和音频当前的播放时间，如果视频播放过快，则通过加大延迟或者重复播放来降低视频播放速度；如果视频播放慢了，则通过减小延迟或者丢帧来追赶音频播放。关键就在于音视频时间的比较以及延迟的计算，当然在比较的过程中会设置一个阈值（Threshold），若超过预设的阈值就应该做调整（丢帧渲染或者重复渲染），这就是整个对齐策略。

1. 使用音频为基准进行音视频同步 `ffplay movie.mp4 -sync audio`
2. 使用视频为基准进行音视频同步 `ffplay movie.mp4 -sync video`
3. 使用外部时钟作为基准进行音视频同步 `ffplay 32037.mp4 -sync ext`


## ffmpeg

强大的媒体文件转换工具。

### 通用参数

1. -f fmt：指定格式（音频或者视频格式）。
2. -i filename：指定输入文件名，在Linux下当然也能指定：0.0（屏幕录制）或摄像头。
3. -y：覆盖已有文件。
4. -t duration：指定时长。
5. -fs limit_size：设置文件大小的上限。
6. -ss time_off：从指定的时间（单位为秒）开始，也支持[-]hh：mm：ss[.xxx]的格式。
7. -re：代表按照帧率发送，尤其在作为推流工具的时候一定要加入该参数，否则ffmpeg会按照最高速率向流媒体服务器不停地发送数据。
8. -map：指定输出文件的流映射关系。例如：“-map 1：0-map 1：1”要求将第二个输入文件的第一个流和第二个流写入输出文件。如果没有-map选项，则ffmpeg采用默认的映射关系。

### 视频参数

1. -b：指定比特率（bit/s），ffmpeg是自动使用VBR的，若指定了该参数则使用平均比特率。
2. -bitexact：使用标准比特率。
3. -vb：指定视频比特率（bits/s）。
4. -r rate：帧速率（fps）。
5. -s size：指定分辨率（320×240）。
6. -aspect aspect：设置视频长宽比（4：3，16：9或1.3333，1.7777）。
7. -croptop size：设置顶部切除尺寸（in pixels）。
8. -cropbottom size：设置底部切除尺寸（in pixels）。
9. -cropleft size：设置左切除尺寸（in pixels）。
10. -cropright size：设置右切除尺寸（in pixels）。
11. -padtop size：设置顶部补齐尺寸（in pixels）。
12. -padbottom size：底补齐（in pixels）。
13. -padleft size：左补齐（in pixels）。
14. -padright size：右补齐（in pixels）。
15. -padcolor color：补齐带颜色（000000-FFFFFF）。
16. -vn：取消视频的输出。
17. -vcodec codec：强制使用codec编解码方式（'copy'代表不进行重新编码）。


### 音频参数
1. -ab：设置比特率（单位为bit/s，老版的单位可能是Kbit/s），对于MP3格式，若要听到较高品质的声音则建议设置为160Kbit/s（单声道则设置为80Kbit/s）以上。
2. -aq quality：设置音频质量（指定编码）
3. -ar rate：设置音频采样率（单位为Hz）。
4. -ac channels：设置声道数，1就是单声道，2就是立体声。
5. -an：取消音频轨。
6. -acodec codec：指定音频编码（'copy'代表不做音频转码，直接复制）。
7. -vol volume：设置录制音量大小（默认为256）<百分比>。


## 最佳实践

1. 列出ffmpeg支持的所有格式：`ffmpeg -formats`
2. 剪切一段媒体文件。可以是音频或者视频文件`ffmpeg -i input.mp4 -ss 00:00:50.0 -codec copy -t 20 output.mp4`表示将文件input.mp4从第50s开始剪切20s的时间，输出到文件output.mp4中，其中-ss指定偏移时间（time Offset），-t指定的时长（duration
3. 使用ffmpeg将该视频文件切割为多个文件：`ffmpeg -i input.mp4 -t 00:00:50 -c copy small-1.mp4 -ss 00:00:50 -codec copy small-2.mp4`
4. 提取一个视频文件中的音频文件：`ffmpeg -i input.mp4 -vn -acodec copy output.m4a`
5. 个视频中的音频静音，即只保留视频:`ffmpeg -i input.mp4 -an -vcodec copy output.mp4`
6. 从MP4文件中抽取视频流导出为裸H264数据：`ffmpeg -i output.mp4 -an -vcodec copy -bsf:v h264_mp4toannexb output.h264`
7. 使用AAC音频数据和H264的视频生成MP4文件：`ffmpeg -i test.aac -i test.h264 -acodec copy -bsf:a aac_adtstoasc -vcodec copy -f mp4 output.mp4`上述代码中使用了一个名为aac_adtstoasc的bitstream filter，AAC格式也有两种封装格式，前面的章节中也曾提到过，而且在后续的章节中也会继续使用API调用该bitstream filter。
8. 对音频文件的编码格式做转换：`ffmpeg -i input.wav -acodec libfdk_aac output.aac`
9. WAV音频文件中导出PCM裸数据：`ffmpeg -i input.wav -acodec pcm_s16le -f s16le output.pcm`这样就可以导出用16个bit来表示一个sample的PCM数据了，并且每个sample的字节排列顺序都是小尾端表示的格式，声道数和采样率使用的都是原始WAV文件的声道数和采样率的PCM数据。
10. 重新编码视频文件，复制音频流，同时封装到MP4格式的文件中：`ffmpeg -i input.flv -vcodec libx264 -acodec copy output.mp4 `
11. 将一个MP4格式的视频转换成为gif格式的动图：`ffmpeg -i input.mp4 -vf scale=100:-1 -t 5 -r 10 image.gif`上述代码按照分辨比例不动宽度改为100（使用VideoFilter的scaleFilter），帧率改为10（-r），只处理前5秒钟（-t）的视频，生成gif。
12. 将一个视频的画面部分生成图片`ffmpeg -i output.mp4 -r 0.25 frames_%04d.png`.上述命令每4秒钟截取一帧视频画面生成一张图片，生成的图片从frames_0001.png开始一直递增下去。
13. 使用一组图片可以组成一个gif，如果你连拍了一组照片，就可以用下面这行命令生成一个gif.`ffmpeg -i frames_%04d.png -r 5 output.gif`
14. 使用音量效果器，可以改变一个音频媒体文件中的音量.`ffmpeg -i input.wav -af ‘volume=0.5’ output.wav`上述命令是将input.wav中的声音减小一半，输出到output.wav文件中，可以直接播放来听，或者放到一些音频编辑软件中直接观看波形幅度的效果。
15. 淡入效果器的使用：`ffmpeg -i input.wav -filter_complex afade=t=in:ss=0:d=5 output.wav`上述命令可以将input.wav文件中的前5s做一个淡入效果，输出到output.wav中，可以将处理之前和处理之后的文件拖到Audacity音频编辑软件中查看波形图。
16. 淡出效果器的使用：`ffmpeg -i input.wav -filter_complex afade=t=out:st=200:d=5 output.wav`上述命令可以将input.wav文件从200s开始，做5s的淡出效果，并放到output.wav文件中。
17. 将两路声音进行合并，比如要给一段声音加上背景音乐：`ffmpeg -i vocal.wav -i accompany.wav -filter_complex amix=inputs=2:duration=shortest output.wav`上述命令是将vocal.wav和accompany.wav两个文件进行mix，按照时间长度较短的音频文件的时间长度作为最终输出的output.wav的时间长度。
18. 对声音进行变速但不变调效果器的使用：`ffmpeg -i vocal.wav -filter_complex atempo=0.5 output.wav`上述命令是将vocal.wav按照0.5倍的速度进行处理生成output.wav，时间长度将会变为输入的2倍。但是音高是不变的，这就是大家常说的变速不变调.
19. 为视频增加水印效果：`ffmpeg -i input.mp4 -i changba_icon.png -filter_complex '[0:v][1:v]overlay=main_w-overlay_w-10:10:1[out]' -map '[out]' output.mp4`上述命令包含了几个内置参数，main_w代表主视频宽度，overlay_w代表水印宽度，main_h代表主视频高度，overlay_h代表水印高度。
20. 视频提亮效果器的使用：`ffmpeg -i input.flv -c:v libx264 -b:v 800k  -c:a libfdk_aac -vf eq=brightness=0.25 -f mp4 output.mp4`提亮参数是brightness，取值范围是从-1.0到1.0，默认值是0。
21. 为视频增加对比度效果：`ffmpeg -i input.flv -c:v libx264 -b:v 800k  -c:a libfdk_aac -vf eq=contrast=1.5 -f mp4 output.mp4`对比度参数 contrast，取值范围是从-2.0到2.0，默认值是1.0。
22. 视频旋转效果器的使用：`ffmpeg -i input.mp4 -vf "transpose=1" -b:v 600k output.mp4`
23. 视频裁剪效果器的使用：`ffmpeg -i input.mp4 -an -vf "crop=240:480:120:0" -vcodec libx264 -b:v 600k output.mp4`
24. 将一张RGBA格式表示的数据转换为JPEG格式的图片：`ffmpeg -f rawvideo -pix_fmt rgba -s 480*480 -i texture.rgb -f image2 -vcodec mjpeg output.jpg`
25. 将一个YUV格式表示的数据转换为JPEG格式的图片：`ffmpeg -f rawvideo -pix_fmt yuv420p -s 480*480 -i texture.yuv -f image2 -vcodec mjpeg output.jpg`
26. 将两个音频文件以两路流的形式封装到一个文件中，比如在K歌的应用场景中，原伴唱实时切换的场景下，可以使用一个文件包含两路流，一路是伴奏流，另外一路是原唱流：`ffmpeg -i 131.mp3 -i 134.mp3 -map 0:a -c:a:0 libfdk_aac -b:a:0 96k -map 1:a -c:a:1 libfdk_aac -b:a:1 64k -vn -f mp4 output.m4a`
