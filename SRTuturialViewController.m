//
//  SRTuturialViewController.m
//  3D Protractor
//
//  Created by Rotek on 13-1-18.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRTuturialViewController.h"
#import "SRTuturialView.h"
#import "SRCameraAngleTuturialViewController.h"
@interface SRTuturialViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) SRTuturialView *view00;
@property (nonatomic,strong) SRTuturialView *view0;
@property (nonatomic,strong) SRTuturialView *view1;
@property (nonatomic,strong) SRTuturialView *view2;
@property (nonatomic,strong) SRTuturialView *view3;
@property (nonatomic,strong) SRTuturialView *view4;
@property (nonatomic,strong) SRTuturialView *view5;
@end

@implementation SRTuturialViewController
@synthesize pageControl = _pageControl;
@synthesize scrollView = _scrollView;
@synthesize view00 = _view00;
@synthesize view0 = _view0;
@synthesize view1 = _view1;
@synthesize view2 = _view2;
@synthesize view3 = _view3;
@synthesize view4 = _view4;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Set title
    self.title = NSLocalizedString(@"Tuturial", @"tuturial");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *everLaunch = [defaults objectForKey:@"Ever Launch"];
    if (everLaunch) {
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    } else {
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
    }
    
    // Setup scrollView
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 7, self.view.frame.size.height);
    } else {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 540, 620)];
        self.scrollView.contentSize = CGSizeMake(540 * 7, 620);
    }
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    
    // Setup pageControl
    
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height - 50, self.view.frame.size.width, 36)];
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.contentMode = UIViewContentModeCenter;
    self.pageControl.numberOfPages = 7;
    self.pageControl.currentPage = 0;
    self.pageControl.userInteractionEnabled = NO;
    [self.view addSubview:self.pageControl];
    
    // Setup views
    self.view00 = [[SRTuturialView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view00.imageView.image = [UIImage imageNamed:@"Icon"];
    self.view00.textLabel.text = NSLocalizedString(@"Welcome using 3D Protractor!", @"welcome using 3D Protractor!");
    
    
    self.view0 = [[SRTuturialView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view0.imageView.image = [UIImage imageNamed:@"Tuturial0"];
    self.view0.textLabel.text = NSLocalizedString(@"Measure Button: use this unique button to do the measurement.", @"measure Button,use this unique button to do the measurement");
    
    self.view1 = [[SRTuturialView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * 2, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view1.imageView.image = [UIImage imageNamed:@"Tuturial1"];
    self.view1.textLabel.text = NSLocalizedString(@"Vector Angle Mode: use your device's side as the measure tool to confirm Vectors", @"vector angle mode,use your device's side as the measure tool to confirm vectors");
    
    self.view2 = [[SRTuturialView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * 3, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view2.imageView.image = [UIImage imageNamed:@"Tuturial5"];
    self.view2.textLabel.text = NSLocalizedString(@"Camera Angle Mode: use camera to measure real angles in the front view.", @"Camera Angle Mode: use camera to measure real angles in the front view.");
    // Add detail button to tuturial 5
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        detailButton.frame = CGRectMake(self.view2.frame.size.width - 60, 60, 50, 50);
    } else {
       detailButton.frame = CGRectMake(self.view2.frame.size.width - 110, 110, 80, 80);
    }
    
    [detailButton setImage:[UIImage imageNamed:@"SettingButton"] forState:UIControlStateNormal];
    [detailButton setImage:[UIImage imageNamed:@"SettingButtonD"] forState:UIControlStateHighlighted];
    [detailButton addTarget:self action:@selector(showCameraAngleTuturial:) forControlEvents:UIControlEventTouchUpInside];
    [self.view2 addSubview:detailButton];

    
    
    self.view3 = [[SRTuturialView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * 4, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view3.imageView.image = [UIImage imageNamed:@"Tuturial2"];
    self.view3.textLabel.text = NSLocalizedString(@"Slope Angle Mode: use your device's back as the measure slope.", @"slope angle mode: use your device's back as the measure slope.");
    
    
    self.view4 = [[SRTuturialView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * 5, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view4.imageView.image = [UIImage imageNamed:@"Tuturial3"];
    self.view4.textLabel.text = NSLocalizedString(@"Dihedral Angle Mode: use your device's back as the measure face.", @"dihedral Angle Mode: use your device's back as the measure face");
    
    self.view5 = [[SRTuturialView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * 6, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view5.imageView.image = [UIImage imageNamed:@"Tuturial4"];
    self.view5.textLabel.text = NSLocalizedString(@"Line Face Angle Mode: confirm a Vector and a Face,then you get the angle.", @"line plain Angle Mode: confirm a Vector and a Face,then you get the angle.");
    
    [self.scrollView addSubview:self.view00];
    [self.scrollView addSubview:self.view0];
    [self.scrollView addSubview:self.view1];
    [self.scrollView addSubview:self.view2];
    [self.scrollView addSubview:self.view3];
    [self.scrollView addSubview:self.view4];
    [self.scrollView addSubview:self.view5];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.pageControl = nil;
    self.scrollView = nil;
    self.view00 = nil;
    self.view0 = nil;
    self.view1 = nil;
    self.view2 = nil;
    self.view3 = nil;
    self.view4 = nil;
    self.view5 = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCameraAngleTuturial:(UIButton *)sender
{
    SRCameraAngleTuturialViewController *cameraAngleTuturial = [[SRCameraAngleTuturialViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cameraAngleTuturial];
    cameraAngleTuturial.title = NSLocalizedString(@"Tuturial", @"tuturial");
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    cameraAngleTuturial.navigationItem.rightBarButtonItem = doneButton;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        navController.view.frame = self.view.frame;
    } else {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        navController.view.frame = CGRectMake(0, 0, 540, 620);
    }
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navController animated:YES];
}

- (void)done:(UIButton *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UI Scroll View delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    self.pageControl.currentPage = page;
    

}

@end
