//
//  SRAngleMeasureEngine.m
//  3D Protractor
//
//  Created by Rotek on 13-1-9.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRAngleMeasureEngine.h"
#import "SRMath.h"
@interface SRAngleMeasureEngine ()
{
    GLKQuaternion _firstLine;
    GLKQuaternion _secondLine;
    GLKQuaternion _freeLine;
    GLKVector3 _cross; // is to calculate the quaternion from the plain parallel to the screen  to plain of the two line
    
    GLKVector3 _currentFirstLineVector;
    GLKVector3 _currentSecondLineVector;
    GLKVector3 _currentCircleVector;
}
@property (nonatomic,assign,readwrite) float freeAngle;
@property (nonatomic,assign,readwrite) float measureAngle;
@end

@implementation SRAngleMeasureEngine
@synthesize freeAngle = _freeAngle;
@synthesize measureAngle = _measureAngle;
@synthesize delegate = _delegate;

- (void)storeFirstLine
{
    NSLog(@"store first line");
    _firstLine = [self.delegate deviceAttitude];
}

- (void)storeSecondLine
{
    NSLog(@"store second line");
    _secondLine = [self.delegate deviceAttitude];
    _currentCircleVector = _cross;
    
    GLKVector3 start = GLKVector3Make(0, 1, 0);
    _currentFirstLineVector = GLKQuaternionRotateVector3(_firstLine, start);
    _currentSecondLineVector = GLKQuaternionRotateVector3(_secondLine, start);
    
}

- (void)clearStore
{
    NSLog(@"clear store");
    _firstLine = GLKQuaternionMake(0, 0, 0, 0);
    _secondLine = GLKQuaternionMake(0, 0, 0, 0);
    
}

- (void)drawFreeRotationWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    
    _freeLine = [self.delegate deviceAttitude];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_freeLine));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    
    // Draw
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    [self.delegate drawAxis];
}

- (void)drawFirstLineAndFreeRotationWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    // Draw free line ->axis
    _freeLine = [self.delegate deviceAttitude];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_freeLine));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.delegate drawAxis];

    // Draw first line ->axis
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_firstLine));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.delegate drawAxis];
    
    [self drawCircleAndDegreeWithBaseEffect:aBaseEffect Line1:_firstLine line2:_freeLine];
}

- (void)drawCircleAndDegreeWithBaseEffect:(GLKBaseEffect *)aBaseEffect
                                    Line1:(GLKQuaternion)line1
                                    line2:(GLKQuaternion)line2
{
    // Draw circle and degree which is on the plain of the free and first line
    // Step 1: use (0,1,0) to calculate the vector3
    GLKVector3 start = GLKVector3Make(0, 1, 0);
    GLKVector3 end0 = GLKQuaternionRotateVector3(line1, start);
    GLKVector3 end1 = GLKQuaternionRotateVector3(line2, start);
    
    // Step 2: calculate quaternion from end0 to end1
    GLKQuaternion theta = [SRMath createFromVector0:end1 vector1:end0];
    
    // Judge the angle clockwise or counterclockwise,clockwise is positive
    // Since theta is calculated from end1 to end0,so below do the if statement in negative way.
    GLKVector3 relativeEnd = GLKQuaternionRotateVector3(theta, start);
    if (relativeEnd.x >= 0) {
         self.freeAngle = -GLKQuaternionAngle(theta) * 180.0 / M_PI;
    } else {
         self.freeAngle = GLKQuaternionAngle(theta) * 180.0 / M_PI;
    }
   
    
    // Step 3:
    // 使用向量叉积计算垂线
    GLKVector3 cross = GLKVector3CrossProduct(end0, end1);
    _cross = GLKVector3Normalize(cross);
    GLKVector3 initCross = GLKVector3Make(0, 0, 1);
    GLKQuaternion delta = [SRMath createFromVector0:initCross vector1:_cross];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,-0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(delta));
    
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawCircle];
    [self.delegate drawDegree];
}

- (void)drawFinalAngleMeasureWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    // get the final measure angle
    if (self.measureAngle != self.freeAngle) {
        self.measureAngle = self.freeAngle;
    }
    
    
    GLKVector3 start = GLKVector3Make(0, 0, 1);
    _currentCircleVector = SceneVector3SlowLowPassFilter([self.delegate timeSinceLastDraw], start, _currentCircleVector);
    GLKQuaternion circleDelta = [SRMath createFromVector0:start vector1:_currentCircleVector];
    
    start = GLKVector3Make(0, 1, 0);
    _currentFirstLineVector = SceneVector3SlowLowPassFilter([self.delegate timeSinceLastDraw], start, _currentFirstLineVector);
    GLKQuaternion firstLineDelta = [SRMath createFromVector0:start vector1:_currentFirstLineVector];
    
    GLKVector3 end = GLKVector3Make(sinf(GLKMathDegreesToRadians(self.measureAngle)), cosf(GLKMathDegreesToRadians(self.measureAngle)), 0);
    _currentSecondLineVector = SceneVector3SlowLowPassFilter([self.delegate timeSinceLastDraw], end, _currentSecondLineVector);
    GLKQuaternion secondLineDelta = [SRMath createFromVector0:start vector1:_currentSecondLineVector];

    // Draw first line
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(firstLineDelta));
    //modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(fDelta));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.delegate drawAxis];
    
    // Draw second line
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(secondLineDelta));
    //modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(fDelta));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.delegate drawAxis];
    
    // Draw circle and degree
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(circleDelta));
    //modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(fDelta));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    
}

@end
