//
//  SRMath.h
//  3D Protractor
//
//  Created by Rotek on 12-12-25.
//  Copyright (c) 2012年 Rotek. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface SRMath : NSObject

// 精确到小数点后precision 位
+ (double)changePrecision:(int)precision WithNumber:(double)number;

+ (GLKQuaternion)GLKQuaternion:(GLKQuaternion)q1 rotateWithQuaternion:(GLKQuaternion)q2;
+ (GLKQuaternion)createFromVector0:(GLKVector3)v0 vector1:(GLKVector3)v1;

+ (GLKVector3)verticalLineOfPlain:(GLKQuaternion)aPlain; // 注意这里的plain 经过了90度的旋转变换 使初始平面由垂直变成水平

+ (float)dihedralAngleBetweenPlain1:(GLKQuaternion)plain1 plain2:(GLKQuaternion)plain2;

@end

extern GLfloat SceneScalarFastLowPassFilter(
                                            NSTimeInterval timeSinceLastUpdate,
                                            GLfloat target,
                                            GLfloat current);

extern GLfloat SceneScalarSlowLowPassFilter(
                                            NSTimeInterval timeSinceLastUpdate,
                                            GLfloat target,
                                            GLfloat current);

extern GLKVector3 SceneVector3FastLowPassFilter(
                                                NSTimeInterval timeSinceLastUpdate,
                                                GLKVector3 target,
                                                GLKVector3 current);

extern GLKVector3 SceneVector3SlowLowPassFilter(
                                                NSTimeInterval timeSinceLastUpdate,
                                                GLKVector3 target,
                                                GLKVector3 current);
extern GLKQuaternion SceneQuaternionFastLowPassFilter( NSTimeInterval timeSinceLastUpdate,GLKQuaternion target, GLKQuaternion current);

extern GLKQuaternion SceneQuaternionSlowLowPassFilter( NSTimeInterval timeSinceLastUpdate,GLKQuaternion target, GLKQuaternion current);
