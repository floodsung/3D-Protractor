//
//  SRAngleMeasureEngine.h
//  3D Protractor
//
//  Description: this file is to be an engine to measure the angle of two line in the 3d space,return the angle value and draw the 3d view
//  Created by Rotek on 13-1-9.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//   

#import <GLKit/GLKit.h>

@protocol SRAngleMeasureEngineProtocol <NSObject>

- (NSTimeInterval)timeSinceLastDraw;
- (GLKQuaternion)deviceAttitude;
- (void)drawAxis;
- (void)drawCircle;
- (void)drawDegree;

@end

@interface SRAngleMeasureEngine : NSObject
@property (nonatomic,assign,readonly) float freeAngle;
@property (nonatomic,assign,readonly) float measureAngle;
@property (nonatomic,weak) id<SRAngleMeasureEngineProtocol> delegate;
- (void)storeFirstLine;
- (void)storeSecondLine;
- (void)clearStore;

- (void)drawFreeRotationWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawFirstLineAndFreeRotationWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawFinalAngleMeasureWithBaseEffect:(GLKBaseEffect *)aBaseEffect;

@end


