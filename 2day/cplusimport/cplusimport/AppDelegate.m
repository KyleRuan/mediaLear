//
//  AppDelegate.m
//  cplusimport
//
//  Created by kyleruan on 2019/11/11.
//  Copyright © 2019 github.io.kyleruan. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <FLEX/FLEX.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [ViewController new];
    [self.window makeKeyAndVisible];
    [[FLEXManager sharedManager] showExplorer];
    return YES;
}


@end
