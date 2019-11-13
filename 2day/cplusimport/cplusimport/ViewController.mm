//
//  ViewController.m
//  cplusimport
//
//  Created by kyleruan on 2019/11/11.
//  Copyright © 2019 github.io.kyleruan. All rights reserved.
//

#import "ViewController.h"
#include "encode.hpp"

using namespace std;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Mp3Encoder *encode = new Mp3Encoder();
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"vocal.mp3"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.pcm" ofType:@""];

    int sampleRate = 44100;
    int channels = 2;
    int bitRate = 128 * 1024;
    encode->Init(path.UTF8String, documentsDirectory.UTF8String, sampleRate, channels, bitRate);

    encode->Encode();

}


@end
