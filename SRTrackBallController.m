//
//  SRTrackBallController.m
//  3D Protractor
//
//  Created by Rotek on 13-1-8.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRTrackBallController.h"
#import "SRMath.h"
@interface SRTrackBallController ()
{
    float _trackballRadius;
    GLKVector2 _centerPoint;
    GLKVector2 _fingerStart;
    GLKQuaternion _orientation;
    GLKQuaternion _previousOrientation;
}
@property (nonatomic,assign) BOOL isEnable;
@end

@implementation SRTrackBallController
@synthesize view = _view;
@synthesize isEnable = _isEnable;

- (id)initWithView:(UIView *)aView trackBallRadius:(float)aRadius
{
    if (self = [super init]) {
        self.view = aView;
        _trackballRadius = aRadius;
        
        // Add pan gesture
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        [self.view addGestureRecognizer:panGesture];
        
        // Initial instance variable
        _centerPoint = GLKVector2Make(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        _orientation = GLKQuaternionMakeWithMatrix4(GLKMatrix4MakeRotation(0, 1, 1, 1));
        _previousOrientation = _orientation;
        
        self.isEnable = NO;
        
    }
    return self;
}

- (void)startTrackBallUpdate
{
    self.isEnable = YES;
}

- (void)stopTrackBallUpdate
{
    self.isEnable = NO;
}

- (void)resetTrackBall
{
    _orientation = GLKQuaternionMakeWithMatrix4(GLKMatrix4MakeRotation(0, 1, 1, 1));
    _previousOrientation = _orientation;
}

- (GLKQuaternion)trackBallOrientation
{
    return _orientation;
}

- (void)rotate:(UIPanGestureRecognizer *)sender
{
    NSLog(@"gesture work");
    if (self.isEnable) {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            CGPoint location = [sender locationInView:self.view];
            _fingerStart = GLKVector2Make(location.x, location.y);
            _previousOrientation = _orientation;
        }
        else if (sender.state == UIGestureRecognizerStateChanged)
        {
            
            CGPoint locationValue = [sender locationInView:self.view];
            
            GLKVector2 location = GLKVector2Make(locationValue.x, locationValue.y);
            
            GLKVector3 start = [self mapToSphere:_fingerStart];
            GLKVector3 end = [self mapToSphere:location];
            NSLog(@"end x = %f,y = %f,z = %f",end.x,end.y,end.z);
            
            GLKMatrix4 rotationMatrix = GLKMatrix4MakeWithQuaternion(_previousOrientation);
            start = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(rotationMatrix, NULL), start);
            end = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(rotationMatrix, NULL), end);
            
            GLKQuaternion delta = [SRMath createFromVector0:start vector1:end];
            _orientation = [SRMath GLKQuaternion:_previousOrientation rotateWithQuaternion:delta];
        }

    }
}

- (GLKVector3)mapToSphere:(GLKVector2)touchPoint
{
    GLKVector2 p = GLKVector2Make(touchPoint.x - _centerPoint.x, _centerPoint.y - touchPoint.y);
    
    float radius = _trackballRadius;
    float safeRadius = radius - 1;
    float length = GLKVector2Length(p);
    if (length > safeRadius) {
        float theta = atan2f(p.y, p.x);
        p.x = safeRadius * cosf(theta);
        p.y = safeRadius * sinf(theta);
        length = safeRadius;
    }
    
    float z = sqrtf(fabsf(radius *radius - length * length));
    GLKVector3 mapped = GLKVector3Make(p.x, p.y, z);
    return GLKVector3DivideScalar(mapped, radius);
}

@end
