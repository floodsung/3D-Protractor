//
//  ViewController.m
//  3D Protractor
//
//  Created by Rotek on 12-12-24.
//  Copyright (c) 2012年 Rotek. All rights reserved.
//

#import "ViewController.h"
#import "SRViewController.h"
#import "SRTuturialViewController.h"
#import "SRCameraEngine.h"
#import "SRAppID.h"

@interface ViewController ()<SRViewControllerProtocol>
@property (nonatomic,strong) SRViewController *GLKViewController;
@property (nonatomic,strong) SRTuturialViewController *tuturialViewController;
@property (nonatomic,strong) UIView *coverView;
@property (nonatomic,strong) UIView *cameraView;
@property (nonatomic,strong) UIImageView *stillImageView;
@end

@implementation ViewController
@synthesize GLKViewController = _GLKViewController;
@synthesize motionManager = _motionManager;
@synthesize tuturialViewController = _tuturialViewController;
@synthesize coverView = _coverView;
@synthesize cameraView = _cameraView;
@synthesize stillImageView = _stillImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Hide Status bar
	[UIApplication sharedApplication].statusBarHidden = YES;
    
    // Configure and add GLKViewController's view
    self.GLKViewController = [[SRViewController alloc] init];
    self.GLKViewController.motionManager = self.motionManager;
    self.GLKViewController.viewControllerDelegate = self;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"metal"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    //self.view.backgroundColor = [UIColor colorWithPatternImage:imageView.image];
    
    [self.view addSubview:imageView];
    
    // Add Camera view
    self.cameraView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.cameraView];
    [SRCameraEngine embedPreviewInView:self.cameraView];
    
    // Add Still imageView
    self.stillImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.stillImageView];
    self.stillImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.stillImageView.hidden = YES;
    
    [self.view addSubview:self.GLKViewController.view];
    
    
    // Setup Tuturial if first launch the app
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
#ifdef LITE_VERSION
    
    NSNumber *cameraAngleModeCounter = [defaults objectForKey:@"Camera Angle Mode Counter"];
    if (cameraAngleModeCounter == nil) {
        cameraAngleModeCounter = [NSNumber numberWithInt:5];
        [defaults setObject:cameraAngleModeCounter forKey:@"Camera Angle Mode Counter"];
    }
    
    
    NSNumber *iAdFailedTimes = [defaults objectForKey:@"iAd Failed Times"];
    if (iAdFailedTimes == nil) {
        iAdFailedTimes = [NSNumber numberWithInt:0];
        [defaults setObject:iAdFailedTimes forKey:@"iAd Failed Times"];
    }
#endif
    NSNumber *everLaunch = [defaults objectForKey:@"Ever Launch"];
    if (everLaunch == nil) {
        
        
        // Setup Tuturial view
        self.tuturialViewController = [[SRTuturialViewController alloc] init];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            self.tuturialViewController.view.frame = self.view.frame;
        } else {
            self.tuturialViewController.view.frame = CGRectMake(114, 202, 540,620);

        }
        
    
        // add start button
        UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        self.tuturialViewController.scrollView.contentSize = CGSizeMake(self.tuturialViewController.scrollView.frame.size.width * 8, self.tuturialViewController.scrollView.frame.size.height);
        startButton.frame = CGRectMake(self.tuturialViewController.scrollView.frame.size.width * 7 + (self.tuturialViewController.scrollView.frame.size.width - 100) / 2, (self.tuturialViewController.scrollView.frame.size.height - 100) / 2, 100, 100);
        [startButton setImage:[UIImage imageNamed:@"StartButton"] forState:UIControlStateNormal];
        [startButton setImage:[UIImage imageNamed:@"StartButtonD"] forState:UIControlStateHighlighted];
        [self.tuturialViewController.scrollView addSubview:startButton];
        self.tuturialViewController.pageControl.numberOfPages = 8;
        
        [startButton addTarget:self action:@selector(dismissTuturial:) forControlEvents:UIControlEventTouchUpInside];
        
        // Setup coverView
        self.coverView = [[UIView alloc] initWithFrame:self.view.frame];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        imageView.image = [UIImage imageNamed:@"metal"];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.coverView addSubview:imageView];
        UIImageView *colorView = [[UIImageView alloc] initWithFrame:self.view.frame];
        colorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [self.coverView addSubview:colorView];
        
        [self.view addSubview:self.coverView];
        [self.view addSubview:self.tuturialViewController.view];
        
    }
    
    
    // Record Version
    [self recordVersion];
    // Compare Version from iTunes store, if new,show update alert.
    //[self updateVersion];
    
    
    /*
    else {
        NSNumber *everUpdate = [defaults objectForKey:@"Ever Update"];
        if ( everUpdate == nil) {
            // Setup update feature view
            self.updateFeatureViewController = [[SRUpdateFeatureViewController alloc] init];
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                self.updateFeatureViewController.view.frame = self.view.frame;
            } else {
                self.updateFeatureViewController.view.frame = CGRectMake(114, 202, 540,620);
            }
            // add start button
            UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            self.updateFeatureViewController.scrollView.contentSize = CGSizeMake(self.updateFeatureViewController.scrollView.frame.size.width * 2, self.updateFeatureViewController.scrollView.frame.size.height);
            startButton.frame = CGRectMake(self.updateFeatureViewController.scrollView.frame.size.width + (self.updateFeatureViewController.scrollView.frame.size.width - 100) / 2, (self.updateFeatureViewController.scrollView.frame.size.height - 100) / 2, 100, 100);
            [startButton setImage:[UIImage imageNamed:@"StartButton"] forState:UIControlStateNormal];
            [startButton setImage:[UIImage imageNamed:@"StartButtonD"] forState:UIControlStateHighlighted];
            [self.updateFeatureViewController.scrollView addSubview:startButton];
            self.updateFeatureViewController.pageControl.numberOfPages = 2;
            
            [startButton addTarget:self action:@selector(dismissUpdateFeature:) forControlEvents:UIControlEventTouchUpInside];
            
            // Setup coverView
            self.coverView = [[UIView alloc] initWithFrame:self.view.frame];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
            imageView.image = [UIImage imageNamed:@"metal"];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.coverView addSubview:imageView];
            UIImageView *colorView = [[UIImageView alloc] initWithFrame:self.view.frame];
            colorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            [self.coverView addSubview:colorView];
            
            [self.view addSubview:self.coverView];
            [self.view addSubview:self.updateFeatureViewController.view];

        }
    }
    
    */
}

- (void)viewDidUnload
{
    self.GLKViewController = nil;
    self.motionManager = nil;
    self.coverView = nil;
    self.tuturialViewController = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dismissTuturial:(UIButton *)sender
{
    
    // Store ever launch value
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *everLaunch = [NSNumber numberWithBool:YES];
    [defaults setObject:everLaunch forKey:@"Ever Launch"];
    [UIView animateWithDuration:1 animations:^{
        self.tuturialViewController.view.alpha = 0.0f;
        self.coverView.alpha = 0.0f;
    }];
}

/*
- (void)dismissUpdateFeature:(UIButton *)sender
{
    // Store ever launch value
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *everUpdate = [NSNumber numberWithBool:YES];
    [defaults setObject:everUpdate forKey:@"Ever Update"];
    [UIView animateWithDuration:1 animations:^{
        self.updateFeatureViewController.view.alpha = 0.0f;
        self.coverView.alpha = 0.0f;
    }];

}
 */


- (void)recordVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [defaults objectForKey:@"Version"];
    if (version == nil) {
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        [defaults setObject:version forKey:@"Version"];
        [defaults synchronize];
    }
}

#pragma mark SRViewController delegate
- (void)startCameraView
{
    self.cameraView.hidden = NO;
    [SRCameraEngine startRunning];
    
}

- (void)stopCameraView
{
    self.cameraView.hidden = NO;
    [SRCameraEngine stopRunning];
}

- (void)hideCameraView
{
    self.cameraView.hidden = YES;
    [SRCameraEngine stopRunning];
    [self hideStillImage];
}

- (void)showStillImage
{
    [SRCameraEngine captureStillImageWithCompletionHandler:^(BOOL success) {
        self.stillImageView.image = [SRCameraEngine image];
        self.stillImageView.hidden = NO;
    }];
}

- (void)showStoredImage
{
    if (self.stillImageView.image != nil) {
        self.stillImageView.hidden = NO;

    }
}


- (void)hideStillImage
{
    self.stillImageView.hidden = YES;
}




@end
