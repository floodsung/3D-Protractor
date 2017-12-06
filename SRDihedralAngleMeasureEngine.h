//
//  SRDihedralAngleMeasureEngine.h
//  3D Protractor
//
//  Created by Rotek on 13-1-9.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import <GLKit/GLKit.h>

@protocol SRDihedralAngleMeasureEngineProtocol <NSObject>

- (NSTimeInterval)timeSinceLastDraw;
- (GLKQuaternion)deviceAttitude;
- (void)drawAxis;
- (void)drawCircle;
- (void)drawDegree;
- (void)drawChip;
- (void)drawAnotherChip;

@end

@interface SRDihedralAngleMeasureEngine : NSObject
@property (nonatomic,assign,readonly) float freeAngle;
@property (nonatomic,assign,readonly) float measureAngle;
@property (nonatomic,weak) id<SRDihedralAngleMeasureEngineProtocol> delegate;

- (void)storeFirstPlain;
- (void)storeSecondPlain;
- (void)clearPlains;

- (void)drawFreeRotationWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawFirstPlainAndFreeRotationWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawFinalAngleMeasureWithBaseEffect:(GLKBaseEffect *)aBaseEffect;

@end
