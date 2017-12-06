//
//  SRCameraEngine.m
//  3D Protractor
//
//  Created by Rotek on 2/21/13.
//  Copyright (c) 2013 Rotek. All rights reserved.
//

#import "SRCameraEngine.h"
#import <ImageIO/ImageIO.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

@interface SRCameraEngine ()

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureStillImageOutput *captureOutput;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic,strong) UIImage *image;


@end

@implementation SRCameraEngine
@synthesize captureSession = _captureSession;
@synthesize captureOutput = _captureOutput;
@synthesize preview = _preview;
@synthesize image = _image;

static SRCameraEngine *sharedInstance = nil;

- (id)init
{
    if (self = [super init]) {
        
        //self.image = [[UIImage alloc] init];
        // 1 创建会话层
        self.captureSession = [[AVCaptureSession alloc] init];
        [self.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
        
        // 2 创建、配置输入设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!captureInput) {
            NSLog(@"Error: %@",error);
        }
        [self.captureSession addInput:captureInput];
        
        // 3 创建，配置输出
        self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
        [self.captureOutput setOutputSettings:outputSettings];
        
        [self.captureSession addOutput:self.captureOutput];
        
    }
    return self;
}

- (void)embedPreviewInView:(UIView *)aView
{
    if (!self.captureSession) return;
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.preview.frame = aView.bounds;
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [aView.layer addSublayer:self.preview];
}

- (void)captureImageWithCompletionHandler:(void(^)(BOOL success))block
{
    // Get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    // Get UIImage
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments) {
            // Do something with the attachments
        }
        // Continue as appropriate
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
       self.image = [[UIImage alloc] initWithData:imageData];
        if (self.image != nil) {
            NSLog(@"get image");
        } else {
            NSLog(@"no image data");
        }
        block(YES);
    }];
}

#pragma mark Class Interface

+ (id)sharedInstance
{
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

+ (void)startRunning
{
    [[[self sharedInstance] captureSession] startRunning];
}

+ (void)stopRunning
{
    [[[self sharedInstance] captureSession] stopRunning];
}

+ (UIImage *)image
{
    return [[self sharedInstance] image];
}

+ (void)captureStillImageWithCompletionHandler:(void(^)(BOOL success))block
{
    [[self sharedInstance] captureImageWithCompletionHandler:^(BOOL success) {
        block(success);
    }];
}

+ (void)embedPreviewInView:(UIView *)aView
{
    [[self sharedInstance] embedPreviewInView:aView];
}






@end
