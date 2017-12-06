//
//  SRSlopeMeasureEngine.h
//  3D Protractor
//
//  Created by Rotek on 13-1-9.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import <GLKit/GLKit.h>

@protocol SRSlopeMeasureEngineProtocol <NSObject>

- (GLKQuaternion)deviceAttitude;
- (NSTimeInterval)timeSinceLastDraw;
- (void)drawAxis;
- (void)drawCircle;
- (void)drawDegree;
- (void)drawPlain;

@end

@interface SRSlopeMeasureEngine : NSObject
@property (nonatomic,assign,readonly) float freeSlope;
@property (nonatomic,assign,readonly) float measureSlope;
@property (nonatomic,weak) id<SRSlopeMeasureEngineProtocol> delegate;
- (void)storeSlope;
- (void)clearSlope;

- (void)drawFreeSlopeWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
- (void)drawMeasureSlopeWithBaseEffect:(GLKBaseEffect *)aBaseEffect;
@end
