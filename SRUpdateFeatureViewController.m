//
//  SRUpdateFeatureViewController.m
//  3D Protractor
//
//  Created by Rotek on 2/24/13.
//  Copyright (c) 2013 Rotek. All rights reserved.
//

#import "SRUpdateFeatureViewController.h"
#import "SRTuturialView.h"
#import "SRCameraAngleTuturialViewController.h"
@interface SRUpdateFeatureViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong) SRTuturialView *view0;
@end

@implementation SRUpdateFeatureViewController
@synthesize pageControl = _pageControl;
@synthesize scrollView = _scrollView;
@synthesize view0 = _view0;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Setup scrollView
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height);
    } else {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 540, 620)];
        self.scrollView.contentSize = CGSizeMake(540 * 2, 620);
    }
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    
    // Setup pageControl
    
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height - 50, self.view.frame.size.width, 36)];
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.contentMode = UIViewContentModeCenter;
    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
    self.pageControl.userInteractionEnabled = NO;
    [self.view addSubview:self.pageControl];

    
    self.view0 = [[SRTuturialView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view0.imageView.image = [UIImage imageNamed:@"Tuturial5"];
    self.view0.textLabel.text = NSLocalizedString(@"Camera Angle Mode: use camera to measure real angles in the front view.", @"Camera Angle Mode: use camera to measure real angles in the front view.");
    self.view0.versionLabel.text = NSLocalizedString(@"New Feature!", @"new feature!");
    [self.scrollView addSubview:self.view0];
    
    // Add detail button to tuturial 5
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        detailButton.frame = CGRectMake(self.view0.frame.size.width - 60, 60, 50, 50);
    } else {
        detailButton.frame = CGRectMake(self.view0.frame.size.width - 110,110, 80, 80);
    }
    
    [detailButton setImage:[UIImage imageNamed:@"SettingButton"] forState:UIControlStateNormal];
    [detailButton setImage:[UIImage imageNamed:@"SettingButtonD"] forState:UIControlStateHighlighted];
    [detailButton addTarget:self action:@selector(showCameraAngleTuturial:) forControlEvents:UIControlEventTouchUpInside];
    [self.view0 addSubview:detailButton];
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
