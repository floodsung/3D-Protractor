//
//  SRAppDelegate.h
//  3D Protractor
//
//  Created by Rotek on 12-12-31.
//  Copyright (c) 2012年 Rotek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
@interface SRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) CMMotionManager *motionManager;
@end
