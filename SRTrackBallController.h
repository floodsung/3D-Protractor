utf-8;134217984allController.h
//  3D Protractor
//
//  Created by Rotek on 13-1-8.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface SRTrackBallController : NSObject

@property (nonatomic,strong) UIView *view;


- (id)initWithView:(UIView *)aView trackBallRadius:(float)aRadius;
- (void)startTrackBallUpdate;
- (void)stopTrackBallUpdate;
- (void)resetTrackBall;
- (GLKQuaternion)trackBallOrientation;


@end
