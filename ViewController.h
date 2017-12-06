//
//  ViewController.h
//  3D Protractor
//
//  Created by Rotek on 12-12-24.
//  Copyright (c) 2012年 Rotek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController
@property (nonatomic,weak) CMMotionManager *motionManager;
@end
