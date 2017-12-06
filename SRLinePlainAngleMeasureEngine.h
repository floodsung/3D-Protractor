//
//  SRLinePlainAngleMeasureEngine.h
//  3D Protractor
//
//  Created by Rotek on 13-1-11.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import <GLKit/GLKit.h>

@protocol SRLinePlainAngleMeasureEngineProtocol <NSObject>

- (NSTimeInterval)timeSinceLastDraw;
- (GLKQuaternion)deviceAttitude;
- (void)drawAxis;
- (void)drawCircle;
- (void)drawDegree;
- (void)drawChip;
- (void)drawAnotherChip;

@end


@interface SRLinePlainAngleMeasureEngine : NSObject
@property (nonatomic,assign,readonly) float freeAngle;
@property (nonatomic,assign,readonly) float measureAngle;
@property (nonatomic,weak) id<SRLinePlainAngleMeasureEngineProtocol> delegate;

- (void)storeLine;
- (void)storePlain;
- (void)clearLineAndPlain;

- (void)drawFreeRotationPlainWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawPlainAndFreeRotationLineWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawFinalAngleMeasureWithBaseEffect:(GLKBaseEffect *)aBaseEffect;

@end
