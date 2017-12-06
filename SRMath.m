//
//  SRMath.m
//  3D Protractor
//
//  Created by Rotek on 12-12-25.
//  Copyright (c) 2012年 Rotek. All rights reserved.
//

#import "SRMath.h"

@implementation SRMath

+ (double)changePrecision:(int)precision WithNumber:(double)number
{
    /* example: number = 3.4684;
     * buffer1 = 3468;
     * buffer2 = 8 > 5;
     * buffer3 = 346 + 1 = 347;
     * buffer4 = 3.47;
     */
    double buffer0 = fabs(number);
    int buffer1 = (int)(buffer0 * pow(10, precision +1));
    int buffer2 = buffer1 % 10;
    int buffer3 = buffer1 / 10;

    
    if (buffer2 >= 5) {
        buffer3 += 1;
    }
    
    double buffer4 = (double)buffer3 / pow(10, precision);
    return number >= 0 ? buffer4 : buffer4 * -1;
    
    
}

+ (GLKQuaternion)GLKQuaternion:(GLKQuaternion)q1 rotateWithQuaternion:(GLKQuaternion)q2
{
    GLKQuaternion q;
    q.w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
    q.x = q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y;
    q.y = q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z;
    q.z = q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x;
    
    q = GLKQuaternionNormalize(q);
    return q;
    
}



+ (GLKQuaternion)createFromVector0:(GLKVector3)v0 vector1:(GLKVector3)v1
{
    GLKVector3 sum = GLKVector3Add(v0, v1);
    if ((sum.x == 0) && (sum.y == 0) && (sum.z == 0)) {
        return GLKQuaternionMakeWithAngleAndVector3Axis(M_PI, GLKVector3Make(1, 0, 0));
    }
    
    GLKVector3 c = GLKVector3CrossProduct(v0, v1);
    float d = GLKVector3DotProduct(v0, v1);
    float s = sqrtf((1+d)*2);
    
    return GLKQuaternionMake(c.x/s, c.y/s, c.z/s, s/2.0f);
}

+ (GLKVector3)verticalLineOfPlain:(GLKQuaternion)aPlain
{
    // Step 1: Calculate quaternions of two imaginary lines on the plain in order to calculate the vertical line of the plain. 先想象平面上的两条相互垂直的线，通过计算两线各自的方位，进而通过叉乘计算垂直于平面的线的方位
    
    // First line
    GLKMatrix4 firstLine = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), -1, 0, 0);
    firstLine = GLKMatrix4Multiply(firstLine, GLKMatrix4MakeWithQuaternion(aPlain));
    GLKQuaternion firstLineAttitude = GLKQuaternionMakeWithMatrix4(firstLine);
    
    // Second line
    GLKMatrix4 secondLine = GLKMatrix4Rotate(firstLine, GLKMathDegreesToRadians(90), 0, 0, 1);
    GLKQuaternion secondLineAttitude = GLKQuaternionMakeWithMatrix4(secondLine);
    
    // Calculate two line vector3 计算两线的空间向量
    GLKVector3 v0 = GLKVector3Make(0, 1, 0);
    GLKVector3 v1 = GLKQuaternionRotateVector3(firstLineAttitude, v0);
    GLKVector3 v2 = GLKQuaternionRotateVector3(secondLineAttitude, v0);
    
    
    // Calculate the cross product
    GLKVector3 cross = GLKVector3Normalize(GLKVector3CrossProduct(v1, v2));
    return cross;
}

+ (float)dihedralAngleBetweenPlain1:(GLKQuaternion)plain1 plain2:(GLKQuaternion)plain2
{
    // Step 2: get two plain's vertical line
    GLKVector3 verticalLine1 = [SRMath verticalLineOfPlain:plain1];
    GLKVector3 verticalLine2 = [SRMath verticalLineOfPlain:plain2];
    GLKVector3 minusVector = GLKVector3Subtract(verticalLine1, verticalLine2);
    
    // 这里顺便计算二面角
    GLKQuaternion delta = [SRMath createFromVector0:verticalLine1 vector1:verticalLine2];
    return GLKQuaternionAngle(delta) * 180 / M_PI * (minusVector.y < 0 ? 1 : -1);

}

/////////////////////////////////////////////////////////////////
// This function returns a value between target and current. Call
// this function repeatedly to asymptotically return values closer
// to target: "ease in" to the target value.
GLfloat SceneScalarFastLowPassFilter(
                                     NSTimeInterval elapsed,    // seconds elapsed since last call
                                     GLfloat target,            // target value to approach
                                     GLfloat current)           // current value
{  // Constant 50.0 is an arbitrarily "large" factor
    return current + (50.0 * elapsed * (target - current));
}


/////////////////////////////////////////////////////////////////
// This function returns a value between target and current. Call
// this function repeatedly to asymptotically return values closer
// to target: "ease in" to the target value.
GLfloat SceneScalarSlowLowPassFilter(
                                     NSTimeInterval elapsed,    // seconds elapsed since last call
                                     GLfloat target,            // target value to approach
                                     GLfloat current)           // current value
{  // Constant 4.0 is an arbitrarily "small" factor
    return current + (4.0 * elapsed * (target - current));
}


/////////////////////////////////////////////////////////////////
// This function returns a vector between target and current.
// Call repeatedly to asymptotically return vectors closer
// to target: "ease in" to the target value.
GLKVector3 SceneVector3FastLowPassFilter(
                                         NSTimeInterval elapsed,    // seconds elapsed since last call
                                         GLKVector3 target,         // target value to approach
                                         GLKVector3 current)        // current value
{
    return GLKVector3Make(
                          SceneScalarFastLowPassFilter(elapsed, target.x, current.x),
                          SceneScalarFastLowPassFilter(elapsed, target.y, current.y),
                          SceneScalarFastLowPassFilter(elapsed, target.z, current.z));
}


/////////////////////////////////////////////////////////////////
// This function returns a vector between target and current.
// Call repeatedly to asymptotically return vectors closer
// to target: "ease in" to the target value.
GLKVector3 SceneVector3SlowLowPassFilter(
                                         NSTimeInterval elapsed,    // seconds elapsed since last call
                                         GLKVector3 target,         // target value to approach
                                         GLKVector3 current)        // current value
{
    return GLKVector3Make(
                          SceneScalarSlowLowPassFilter(elapsed, target.x, current.x),
                          SceneScalarSlowLowPassFilter(elapsed, target.y, current.y),
                          SceneScalarSlowLowPassFilter(elapsed, target.z, current.z));
}

GLKQuaternion SceneQuaternionFastLowPassFilter( NSTimeInterval elapsed,GLKQuaternion target, GLKQuaternion current)
{
    return GLKQuaternionMake(SceneScalarFastLowPassFilter(elapsed, target.x, current.x),
                             SceneScalarFastLowPassFilter(elapsed, target.y, current.y),
                             SceneScalarFastLowPassFilter(elapsed, target.z, current.z),
                             SceneScalarFastLowPassFilter(elapsed, target.w, current.w));
}

GLKQuaternion SceneQuaternionSlowLowPassFilter( NSTimeInterval elapsed,GLKQuaternion target, GLKQuaternion current)
{
    return GLKQuaternionMake(
                             SceneScalarSlowLowPassFilter(elapsed, target.x, current.x),
                             SceneScalarSlowLowPassFilter(elapsed, target.y, current.y),
                             SceneScalarSlowLowPassFilter(elapsed, target.z, current.z),
                             SceneScalarSlowLowPassFilter(elapsed, target.w, current.w));
}



@end
