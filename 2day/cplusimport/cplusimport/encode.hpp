//
//  encode.hpp
//  cplusimport
//
//  Created by kyleruan on 2019/11/11.
//  Copyright © 2019 github.io.kyleruan. All rights reserved.
//

#ifndef encode_hpp
#define encode_hpp
#include "lame.h"
#include <stdio.h>
class Mp3Encoder {
private:
    FILE* pcmFile;
    FILE* mp3File;
    lame_t lameClient;
public:
    void encoder();
    Mp3Encoder();
    ~Mp3Encoder();
    int Init(const char* pcmFilePath, const char *mp3FilePath, int
             sampleRate, int channels, int bitRate);
    void Encode();
    void Destory();
};
#endif /* encode_hpp */
