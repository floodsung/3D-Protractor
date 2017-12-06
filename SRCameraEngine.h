//
//  SRCameraEngine.h
//  3D Protractor
//
//  Created by Rotek on 2/21/13.
//  Copyright (c) 2013 Rotek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SRCameraEngine : NSObject<AVCaptureAudioDataOutputSampleBufferDelegate>
+ (void)captureStillImageWithCompletionHandler:(void(^)(BOOL success))block;
+ (void)embedPreviewInView:(UIView *)aView;
+ (void)startRunning;
+ (void)stopRunning;
+ (UIImage *)image;
@end
