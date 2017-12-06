//
//  SRAppDelegate.m
//  3D Protractor
//
//  Created by Rotek on 12-12-31.
//  Copyright (c) 2012年 Rotek. All rights reserved.
//

#import "SRAppDelegate.h"
#import "ViewController.h"
#import <AdSupport/ASIdentifierManager.h>
@implementation SRAppDelegate
@synthesize motionManager = _motionManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    /*
    if (NSClassFromString(@"ASIdentifierManager")) {
        NSLog(@"GoogleAdMobAdsSDK ID for testing: %@" ,
              [[[ASIdentifierManager sharedManager]
                advertisingIdentifier] UUIDString]);
    } else {
        NSLog(@"GoogleAdMobAdsSDK ID for testing: %@" ,
              [[UIDevice currentDevice] uniqueIdentifier]);
    }
     */
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.01;
    if (self.motionManager.deviceMotionAvailable) {
        [self.motionManager startDeviceMotionUpdates];
        NSLog(@"device motion work");
    } else NSLog(@"device motion unavailable");
    
    
    ViewController *viewController = (ViewController *)self.window.rootViewController;
    viewController.motionManager = self.motionManager;
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"enter background");
    if (self.motionManager.isDeviceMotionAvailable) {
        if (self.motionManager.isDeviceMotionActive) {
            [self.motionManager stopDeviceMotionUpdates];
            NSLog(@"Stop device motion");
        }
    } else NSLog(@"Device motion unavailable");

    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"enter foreground");
    if (self.motionManager.isDeviceMotionAvailable) {
        if (!self.motionManager.isDeviceMotionActive) {
            [self.motionManager startDeviceMotionUpdates];
            NSLog(@"Start device motion");
        }
    } else NSLog(@"Device motion unavailable");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if (self.motionManager.isDeviceMotionAvailable) {
        if (self.motionManager.isDeviceMotionActive) {
            [self.motionManager stopDeviceMotionUpdates];
            NSLog(@"Stop device motion");
        }
    }
}

@end
