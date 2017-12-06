//
//  SRViewController.h
//  3D Protractor
//
//  Created by Rotek on 12-12-31.
//  Copyright (c) 2012年 Rotek. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <iAd/iAd.h>
#import <CoreMotion/CoreMotion.h>
#import "GADBannerViewDelegate.h"
#import "SRAngleMeasureEngine.h"
#import "SRCameraAngleMeasureEngine.h"
#import "SRSettingViewController.h"

@protocol SRViewControllerProtocol <NSObject>

- (void)startCameraView;
- (void)stopCameraView;
- (void)hideCameraView;
- (void)showStillImage;
- (void)hideStillImage;
- (void)showStoredImage;

@end

@interface SRViewController : GLKViewController<SRAngleMeasureEngineProtocol,SRCameraAngleMeasureEngineProtocol,UIAlertViewDelegate,GADBannerViewDelegate,ADBannerViewDelegate,SRSettingViewControllerProtocol>

@property (nonatomic,weak) CMMotionManager *motionManager;
@property (nonatomic,weak) id<SRViewControllerProtocol>viewControllerDelegate;

@end
