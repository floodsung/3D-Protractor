//
//  SRCameraAngleMeasureEngine.h
//  3D Protractor
//
//  Created by Rotek on 2/21/13.
//  Copyright (c) 2013 Rotek. All rights reserved.
//

#import <GLKit/GLKit.h>
@protocol SRCameraAngleMeasureEngineProtocol <NSObject>

- (NSTimeInterval)timeSinceLastDraw;
- (GLKQuaternion)deviceAttitude;
- (void)drawAxis;
- (void)drawCircle;
- (void)drawDegree;
- (void)drawTarget;

@end

@interface SRCameraAngleMeasureEngine : NSObject
@property (nonatomic,assign,readonly) float freeAngle;
@property (nonatomic,assign,readonly) float measureAngle;
@property (nonatomic,weak) id<SRCameraAngleMeasureEngineProtocol>delegate;

- (void)storePlain;
- (void)confirmDisplayPlain;
- (void)confirmFirstLine;
- (void)confirmSecondLine;
- (void)clearBuffers;

- (void)drawFreePlainWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawCameraPlainWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawCameraPlainWithOneLineWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawCameraPlainWithTwoLineWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawFinalResultWithBaseEffect:(GLKBaseEffect *)aBaseEffect;



@end
