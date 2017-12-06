//
//  SRCameraAngleMeasureEngine.m
//  3D Protractor
//
//  Created by Rotek on 2/21/13.
//  Copyright (c) 2013 Rotek. All rights reserved.
//

#import "SRCameraAngleMeasureEngine.h"
#import "SRMath.h"

@interface SRCameraAngleMeasureEngine ()
{
    GLKQuaternion _plain; // 实际测量的平面
    GLKQuaternion _currentPlain;
    GLKQuaternion _displayPlain; // 相对摄像头要显示的平面
    GLKQuaternion _firstLine;
    GLKQuaternion _secondLine;
    
}
@property (nonatomic,assign,readwrite) float freeAngle;
@property (nonatomic,assign,readwrite) float measureAngle;

@end

@implementation SRCameraAngleMeasureEngine
@synthesize freeAngle = _freeAngle;
@synthesize measureAngle = _measureAngle;
@synthesize delegate = _delegate;

- (void)storePlain
{
    _plain = [self.delegate deviceAttitude];
}

- (void)confirmDisplayPlain
{
    _currentPlain = [self.delegate deviceAttitude];
}

- (void)confirmFirstLine
{
    _firstLine = [self.delegate deviceAttitude];
    
}

- (void)confirmSecondLine
{
    _secondLine = [self.delegate deviceAttitude];
}

- (void)clearBuffers
{
    _plain = GLKQuaternionMake(0, 0, 0, 0);
    _firstLine = GLKQuaternionMake(0, 0, 0, 0);
    _secondLine = GLKQuaternionMake(0, 0, 0, 0);
    
}

- (void)drawFreePlainWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    GLKQuaternion _freePlain = [self.delegate deviceAttitude];
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_freePlain));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    
    // Draw
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    [self.delegate drawTarget];
}

- (void)drawCameraPlainWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    // Calculate DisplayPlain
    _currentPlain = [self.delegate deviceAttitude];
    
    // 基本原理就是坐标变换，原来的世界坐标系不变，手机坐标变，要改成手机坐标系不变，世界在变
    GLKQuaternion delta = GLKQuaternionInvert(_currentPlain);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(delta));
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_plain));
    
    
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    [self.delegate drawTarget];
}

- (void)drawCameraPlainWithOneLineWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    // 基本原理就是坐标变换，原来的世界坐标系不变，手机坐标变，要改成手机坐标系不变，世界在变
    GLKQuaternion delta = GLKQuaternionInvert(_currentPlain);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(delta));
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_plain));
    
    
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    
    
    // draw axis
    GLKQuaternion freeLine = [self.delegate deviceAttitude];
    GLKVector3 initLine = GLKVector3Make(0, 1, 0);
    GLKVector3 endLine = GLKQuaternionRotateVector3(freeLine, initLine);
    GLKVector3 projectionLine = GLKVector3Normalize(GLKVector3Make(endLine.x, endLine.y, 0));
    GLKQuaternion rotation = [SRMath createFromVector0:initLine vector1:projectionLine];
    
    
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(rotation));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawAxis];
}

- (void)drawCameraPlainWithTwoLineWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    // 基本原理就是坐标变换，原来的世界坐标系不变，手机坐标变，要改成手机坐标系不变，世界在变
    GLKQuaternion delta = GLKQuaternionInvert(_currentPlain);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(delta));
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_plain));
    
    
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    
    
    // draw axis
    
    GLKVector3 initLine = GLKVector3Make(0, 1, 0);
    GLKVector3 endLine1 = GLKQuaternionRotateVector3(_firstLine, initLine);
    GLKVector3 projectionLine1 = GLKVector3Normalize(GLKVector3Make(endLine1.x, endLine1.y, 0));
    GLKQuaternion rotation1 = [SRMath createFromVector0:initLine vector1:projectionLine1];
    
    
    GLKMatrix4 modelViewMatrix1 = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(rotation1));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix1;
    [self.delegate drawAxis];
    
    GLKQuaternion freeLine = [self.delegate deviceAttitude];

    GLKVector3 endLine2 = GLKQuaternionRotateVector3(freeLine, initLine);
    GLKVector3 projectionLine2 = GLKVector3Normalize(GLKVector3Make(endLine2.x, endLine2.y, 0));
    GLKQuaternion rotation2 = [SRMath createFromVector0:initLine vector1:projectionLine2];
    
    
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(rotation2));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix2;
    [self.delegate drawAxis];
    
    GLKQuaternion theta = [SRMath createFromVector0:projectionLine1 vector1:projectionLine2];
    self.freeAngle = GLKQuaternionAngle(theta) * 180 / M_PI;
}

- (void)drawFinalResultWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    // 基本原理就是坐标变换，原来的世界坐标系不变，手机坐标变，要改成手机坐标系不变，世界在变
    GLKQuaternion delta = GLKQuaternionInvert(_currentPlain);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(delta));
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_plain));
    
    
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    
    
    // draw axis
    
    GLKVector3 initLine = GLKVector3Make(0, 1, 0);
    GLKVector3 endLine1 = GLKQuaternionRotateVector3(_firstLine, initLine);
    GLKVector3 projectionLine1 = GLKVector3Normalize(GLKVector3Make(endLine1.x, endLine1.y, 0));
    GLKQuaternion rotation1 = [SRMath createFromVector0:initLine vector1:projectionLine1];
    
    
    GLKMatrix4 modelViewMatrix1 = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(rotation1));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix1;
    [self.delegate drawAxis];
    
    
    GLKVector3 endLine2 = GLKQuaternionRotateVector3(_secondLine, initLine);
    GLKVector3 projectionLine2 = GLKVector3Normalize(GLKVector3Make(endLine2.x, endLine2.y, 0));
    GLKQuaternion rotation2 = [SRMath createFromVector0:initLine vector1:projectionLine2];
    
    
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(rotation2));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix2;
    [self.delegate drawAxis];
    
    GLKQuaternion theta = [SRMath createFromVector0:projectionLine1 vector1:projectionLine2];
    self.measureAngle = GLKQuaternionAngle(theta) * 180 / M_PI;
}
@end
