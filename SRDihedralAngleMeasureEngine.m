//
//  SRDihedralAngleMeasureEngine.m
//  3D Protractor
//
//  Created by Rotek on 13-1-9.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRDihedralAngleMeasureEngine.h"
#import "SRMath.h"
@interface SRDihedralAngleMeasureEngine ()
{
    GLKQuaternion _firstChip;  // 这是从deviceMotion中直接获取的姿态未经变换
    GLKQuaternion _secondChip;
    GLKQuaternion _freePlain;
    
    GLKQuaternion _currentFirstChip; // 经过变换的姿态
    GLKQuaternion _currentSecondChip;
    GLKQuaternion _currentCircle;
    
    GLKQuaternion _targetFirstChip;
    GLKQuaternion _targetSecondChip;
    GLKQuaternion _targetCircle;
    
    
}
@property (nonatomic,assign,readwrite) float freeAngle;
@property (nonatomic,assign,readwrite) float measureAngle;

@end

@implementation SRDihedralAngleMeasureEngine
@synthesize freeAngle = _freeAngle;
@synthesize measureAngle = _measureAngle;
@synthesize delegate = _delegate;

- (void)storeFirstPlain
{
    _firstChip = [self.delegate deviceAttitude];
}

- (void)storeSecondPlain
{
    _secondChip = [self.delegate deviceAttitude];
    self.measureAngle = self.freeAngle;
    
    // Calculate target attitude
    
    // first chip
    
    GLKMatrix4 targetFirstChipRotationMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 0, -1, 0);
    targetFirstChipRotationMatrix = GLKMatrix4Rotate(targetFirstChipRotationMatrix, GLKMathDegreesToRadians(90), -1, 0, 0);
    _targetFirstChip = GLKQuaternionMakeWithMatrix4(targetFirstChipRotationMatrix);
    
    GLKMatrix4 targetSecondChipRotationMatrix = GLKMatrix4Rotate(targetFirstChipRotationMatrix, GLKMathDegreesToRadians(self.measureAngle), 1,0, 0);
    _targetSecondChip = GLKQuaternionMakeWithMatrix4(targetSecondChipRotationMatrix);
    
    GLKMatrix4 targetCircleRotationMatrix = GLKMatrix4MakeRotation(0, 1, 1, 1);
    _targetCircle = GLKQuaternionMakeWithMatrix4(targetCircleRotationMatrix);
}

- (void)clearPlains
{
    _firstChip =  GLKQuaternionMake(0, 0, 0, 0);
    _secondChip = GLKQuaternionMake(0, 0, 0, 0);
    self.measureAngle = 0;
}

- (void)drawFreeRotationWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    _freePlain = [self.delegate deviceAttitude];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(90), -1, 0, 0);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_freePlain));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    // Draw
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    [self.delegate drawChip];

}

- (void)drawFirstPlainAndFreeRotationWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    // Draw free plain
    _freePlain = [self.delegate deviceAttitude];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(90), -1, 0, 0);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_freePlain));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    // Draw
    [self.delegate drawAnotherChip];
    
    _currentSecondChip = GLKQuaternionMakeWithMatrix4(modelViewMatrix);
    
    // Draw first plain
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(90), -1, 0, 0);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_firstChip));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    // Draw
    [self.delegate drawChip];
    
    _currentFirstChip = GLKQuaternionMakeWithMatrix4(modelViewMatrix);
    
    // Draw cicle
    GLKVector3 intersectLine = [self intersectLineWithPlain1: _firstChip plain2:_freePlain];
    
    GLKVector3 initLine = GLKVector3Make(0, 0, 1);
    GLKQuaternion delta = [SRMath createFromVector0:initLine vector1:intersectLine];
    
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f,-0.0f, -10.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(delta));
    
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.delegate drawCircle];
    [self.delegate drawDegree];
    
    _currentCircle = GLKQuaternionMakeWithMatrix4(modelViewMatrix);


}

- (void)drawFinalAngleMeasureWithBaseEffect:(GLKBaseEffect *)aBaseEffect
{
    _currentFirstChip = SceneQuaternionSlowLowPassFilter([self.delegate timeSinceLastDraw], _targetFirstChip, _currentFirstChip);
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_currentFirstChip));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.delegate drawChip];
    
    _currentSecondChip = SceneQuaternionSlowLowPassFilter([self.delegate timeSinceLastDraw], _targetSecondChip, _currentSecondChip);
    modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_currentSecondChip));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.delegate drawAnotherChip];
    
    _currentCircle = SceneQuaternionSlowLowPassFilter([self.delegate timeSinceLastDraw], _targetCircle, _currentCircle);
    modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_currentCircle));
    aBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.delegate drawCircle];
    [self.delegate drawDegree];

}

- (float)dihedralAngleWithPlain1:(GLKQuaternion)plain1 plain2:(GLKQuaternion)plain2
{
    return 0;
}

- (GLKVector3)intersectLineWithPlain1:(GLKQuaternion)plain1 plain2:(GLKQuaternion)plain2
{
    // Step 2: get two plain's vertical line
    GLKVector3 verticalLine1 = [SRMath verticalLineOfPlain:plain1];
    GLKVector3 verticalLine2 = [SRMath verticalLineOfPlain:plain2];
    GLKVector3 intersectLine = GLKVector3Normalize(GLKVector3CrossProduct(verticalLine1, verticalLine2)) ;
    
    // 这里顺便计算二面角
    GLKQuaternion delta = [SRMath createFromVector0:verticalLine1 vector1:verticalLine2];
    self.freeAngle = GLKQuaternionAngle(delta) * 180 / M_PI;
    return intersectLine;
}


@end
