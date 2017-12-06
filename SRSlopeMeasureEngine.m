//
//  SRSlopeMeasureEngine.m
//  3D Protractor
//
//  Created by Rotek on 13-1-9.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRSlopeMeasureEngine.h"
#import "SRMath.h"
@interface SRSlopeMeasureEngine ()
{
    GLKVector3 _cross;
    float _rotateAngle;
    GLKQuaternion _circleRotation;
    GLKQuaternion _currentCircleRotation;
    GLKQuaternion _targetCircleRotation;
    GLKQuaternion _axisRotation;
    GLKQuaternion _currentAxisRotation;
    GLKQuaternion _targetAxisRotation;
    
}
@property (nonatomic,assign,readwrite) float freeSlope;
@property (nonatomic,assign,readwrite) float measureSlope;

@end

@implementation SRSlopeMeasureEngine
@synthesize freeSlope = _freeSlope;
@synthesize measureSlope = _measureSlope;
@synthesize delegate = _delegate;

- (void)storeSlope
{
    self.measureSlope = self.freeSlope;
    
    _currentAxisRotation = _axisRotation;
    _currentCircleRotation = _circleRotation;
    
    // Calculation of final position
    GLKMatrix4 targetCircleRotationMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 0, -1, 0);
    targetCircleRotationMatrix = GLKMatrix4Rotate(targetCircleRotationMatrix, GLKMathDegreesToRadians(90 - self.measureSlope), -1, 0, 0);
    _targetCircleRotation = GLKQuaternionMakeWithMatrix4(targetCircleRotationMatrix);
    
    GLKMatrix4 targetAxisRotationMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.measureSlope), 0, 0, 1);
    _targetAxisRotation = GLKQuaternionMakeWithMatrix4(targetAxisRotationMatrix);
    
    
}

- (void)clearSlope
{
    self.measureSlope = 0;
}

- (void)drawFreeSlopeWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    // Step 1: gain the attitude at the current time
    GLKQuaternion currentAttitude = [self.delegate deviceAttitude];
    
    // Step 2: draw plain(circle)
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-90), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(currentAttitude));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    //[self.delegate drawAxis];
    [self.delegate drawPlain];
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    
    // Store circle rotation
    _circleRotation = GLKQuaternionMakeWithMatrix4(modelViewMatrix);
    
    
    modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-90), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(currentAttitude));
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(90), 0, 0, 1);
    //aBasicEffect.transform.modelviewMatrix = modelViewMatrix;
    //[self.delegate drawAxis];
     

    // draw vertical axis and calculation
    GLKQuaternion delta = GLKQuaternionMakeWithMatrix4(modelViewMatrix);
    GLKVector3 v0 = GLKVector3Make(0, 1, 0);
    GLKVector3 v1 = GLKQuaternionRotateVector3(_circleRotation, v0);
    GLKVector3 v2 = GLKQuaternionRotateVector3(delta, v0);
    // calculate the cross product
    _cross = GLKVector3Normalize(GLKVector3CrossProduct(v1, v2));
    GLKQuaternion verticalDelta = [SRMath createFromVector0:v0 vector1:_cross];
    modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(verticalDelta));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawAxis];
    
    // Store axis rotation
    _axisRotation = GLKQuaternionMakeWithMatrix4(modelViewMatrix);
    
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(180), 1, 0, 0);
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawAxis];
    
    // Calculation
    
    GLKVector3 relativeGravity = GLKVector3Make(0, -1, 0);
    GLKQuaternion theta = [SRMath createFromVector0:relativeGravity vector1:_cross];

    float tempAngle = GLKQuaternionAngle(theta);
    float angle = fabsf( 180 - GLKMathRadiansToDegrees(tempAngle));
    self.freeSlope = angle > 90 ? 180 - angle : angle;
    
    // Calculate rotate angle to projection view
    GLKVector3 projectionCross = GLKVector3Normalize(GLKVector3Make(_cross.x, _cross.y, 0));
    GLKQuaternion rotation = [SRMath createFromVector0:_cross vector1:projectionCross];
    _rotateAngle = GLKQuaternionAngle(rotation);
    
    
}

- (void)drawMeasureSlopeWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    _currentCircleRotation = SceneQuaternionSlowLowPassFilter([self.delegate timeSinceLastDraw], _targetCircleRotation, _currentCircleRotation);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_currentCircleRotation));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    [self.delegate drawPlain];
    
    _currentAxisRotation = SceneQuaternionSlowLowPassFilter([self.delegate timeSinceLastDraw], _targetAxisRotation, _currentAxisRotation);
    
    modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_currentAxisRotation));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawAxis];
    
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(180), 1, 0, 0);
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawAxis];

}

@end
