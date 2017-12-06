//
//  SRLinePlainAngleMeasureEngine.m
//  3D Protractor
//
//  Created by Rotek on 13-1-11.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRLinePlainAngleMeasureEngine.h"
#import "SRMath.h"
#import "SRAngleMeasureEngine.h"
@interface SRLinePlainAngleMeasureEngine ()
{
    GLKQuaternion _lineAttitude;
    GLKQuaternion _plainAttitude;
    
    GLKQuaternion _currentLineRotation;
    GLKQuaternion _currentPlainRotation;
    GLKQuaternion _currentCircleRotation;
    
    GLKQuaternion _targetLineRotation;
    GLKQuaternion _targetPlainRotation;
    GLKQuaternion _targetCircleRotation;
}
@property (nonatomic,assign,readwrite) float freeAngle;
@property (nonatomic,assign,readwrite) float measureAngle;

@end

@implementation SRLinePlainAngleMeasureEngine
@synthesize freeAngle = _freeAngle;
@synthesize measureAngle = _measureAngle;
@synthesize delegate = _delegate;

- (void)storePlain
{
    _plainAttitude = [self.delegate deviceAttitude];
}

- (void)storeLine
{
    _lineAttitude = [self.delegate deviceAttitude];
    
    // Store measure angle
    self.measureAngle = self.freeAngle;
    
    // Calculate target rotation
    GLKMatrix4 targetPlainRotationMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 0, -1, 0);
    targetPlainRotationMatrix = GLKMatrix4Rotate(targetPlainRotationMatrix, GLKMathDegreesToRadians(90), -1, 0, 0);
    _targetPlainRotation = GLKQuaternionMakeWithMatrix4(targetPlainRotationMatrix);
    
    GLKMatrix4 targetLineRotationMatrix = GLKMatrix4Rotate(targetPlainRotationMatrix, GLKMathDegreesToRadians(self.measureAngle), 1, 0, 0);
    _targetLineRotation = GLKQuaternionMakeWithMatrix4(targetLineRotationMatrix);
    
    GLKMatrix4 targetCircleRotationMatrix = GLKMatrix4MakeRotation(0, 1, 1, 1);
    _targetCircleRotation = GLKQuaternionMakeWithMatrix4(targetCircleRotationMatrix);

}



- (void)clearLineAndPlain
{
    _lineAttitude = GLKQuaternionMake(0, 0, 0, 0);
    _plainAttitude = GLKQuaternionMake(0, 0, 0, 0);
}

- (void)drawFreeRotationPlainWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    GLKQuaternion currentAttitude = [self.delegate deviceAttitude];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(90), -1, 0, 0);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(currentAttitude));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    // Draw
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    [self.delegate drawAnotherChip];
}

- (void)drawPlainAndFreeRotationLineWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    // Draw plain
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(90), -1, 0, 0);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_plainAttitude));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    // Draw
    [self.delegate drawAnotherChip];
    // Store current plain rotation
    _currentPlainRotation = GLKQuaternionMakeWithMatrix4(modelViewMatrix);
    
    
    // Draw free Line
    GLKQuaternion currentAttitude = [self.delegate deviceAttitude];
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(90), -1, 0, 0);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(currentAttitude));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;

    [self.delegate drawAxis];
    
    // Store current line rotation
    _currentLineRotation = GLKQuaternionMakeWithMatrix4(modelViewMatrix);
    
    GLKQuaternion lineRotation = GLKQuaternionMakeWithMatrix4(modelViewMatrix);
    
    // Draw circle
    GLKVector3 verticalLineOfPlain = [SRMath verticalLineOfPlain:_plainAttitude];
    
    GLKVector3 start = GLKVector3Make(0, 1, 0);
    GLKVector3 line = GLKQuaternionRotateVector3(lineRotation, start);
    
    GLKVector3 cross = GLKVector3Normalize(GLKVector3CrossProduct(verticalLineOfPlain, line));
    
    GLKVector3 initCross = GLKVector3Make(0, 0, 1);
    GLKQuaternion circleRotation = [SRMath createFromVector0:initCross vector1:cross];
    
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,-0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(circleRotation));
    
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    
    // Store current circle rotation
    _currentCircleRotation = GLKQuaternionMakeWithMatrix4(modelViewMatrix);
    
    // Calculate the free angle
    GLKQuaternion delta = [SRMath createFromVector0:verticalLineOfPlain vector1:line];
    self.freeAngle = 90 - GLKQuaternionAngle(delta) * 180.0 / M_PI;

    
}

- (void)drawFinalAngleMeasureWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    // Draw plain
    _currentPlainRotation = SceneQuaternionSlowLowPassFilter([self.delegate timeSinceLastDraw], _targetPlainRotation, _currentPlainRotation);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_currentPlainRotation));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.delegate drawAnotherChip];
    
    // Draw line
    _currentLineRotation = SceneQuaternionSlowLowPassFilter([self.delegate timeSinceLastDraw], _targetLineRotation, _currentLineRotation);
    modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_currentLineRotation));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.delegate drawAxis];
    
    // Draw circle
    
    _currentCircleRotation = SceneQuaternionSlowLowPassFilter([self.delegate timeSinceLastDraw], _targetCircleRotation, _currentCircleRotation);
    
    modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_currentCircleRotation));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;

    [self.delegate drawCircle];
    [self.delegate drawDegree];
    
}
@end
