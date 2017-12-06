//
//  SRCameraAngleTuturialViewController.m
//  3D Protractor
//
//  Created by Rotek on 2/24/13.
//  Copyright (c) 2013 Rotek. All rights reserved.
//

#import "SRCameraAngleTuturialViewController.h"
#import "SRCameraAngleTuturialView.h"
@interface SRCameraAngleTuturialViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong) SRCameraAngleTuturialView *view0;
@property (nonatomic,strong) SRCameraAngleTuturialView *view1;
@property (nonatomic,strong) SRCameraAngleTuturialView *view2;
@property (nonatomic,strong) SRCameraAngleTuturialView *view3;
@property (nonatomic,strong) SRCameraAngleTuturialView *view4;



@end

@implementation SRCameraAngleTuturialViewController
@synthesize pageControl = _pageControl;
@synthesize scrollView = _scrollView;
@synthesize view0 = _view0;
@synthesize view1 = _view1;
@synthesize view2 = _view2;
@synthesize view3 = _view3;
@synthesize view4 = _view4;


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    // Setup scrollView
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 5, self.view.frame.size.height);
    } else {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 540, 620)];
        self.scrollView.contentSize = CGSizeMake(540 * 5, 620);
    }
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    
    // Setup pageControl
    
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height - 50, self.view.frame.size.width, 36)];
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.contentMode = UIViewContentModeCenter;
    self.pageControl.numberOfPages = 5;
    self.pageControl.currentPage = 0;
    self.pageControl.userInteractionEnabled = NO;
    [self.view addSubview:self.pageControl];
    
    // Setup views
    self.view0 = [[SRCameraAngleTuturialView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view0.imageView.image = [UIImage imageNamed:@"CameraTuturial1"];
    self.view0.textLabel.text = NSLocalizedString(@"There is an iPad on the desk,we want to measure the angle in iPad screen,which is 45°.", @"there is an iPad on the desk,we want to measure the angle in iPad screen,which is 45°");
    
    self.view1 = [[SRCameraAngleTuturialView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view1.imageView.image = [UIImage imageNamed:@"CameraTuturial2"];
    self.view1.textLabel.text = NSLocalizedString(@"Step 1: Put iPhone on the desk to confirm the surface where the angle is to be measured.", @"step 1: Put iPhone on the desk to confirm the surface where the angle is to be measured.");
    
    self.view2 = [[SRCameraAngleTuturialView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * 2, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view2.imageView.image = [UIImage imageNamed:@"CameraTuturial3"];
    self.view2.textLabel.text = NSLocalizedString(@"Step 2: Take up iPhone,press Confirm button to take a photo. Make sure the vertex of angle is at the center of photo.", @"step 2: Take up iPhone,press Confirm button to take a photo. Make sure the vertex of angle is at the center of photo.");
    
    self.view3 = [[SRCameraAngleTuturialView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * 3, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view3.imageView.image = [UIImage imageNamed:@"CameraTuturial4"];
    self.view3.textLabel.text = NSLocalizedString(@"Step 3: Rotate iPhone and confirm first line of the angle.", @"step 3: Rotate iPhone and confirm first line of the angle.");
    
    self.view4 = [[SRCameraAngleTuturialView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * 4, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.view4.imageView.image = [UIImage imageNamed:@"CameraTuturial5"];
    self.view4.textLabel.text = NSLocalizedString(@"Step 4: Rotate iPhone and confirm second line of the angle, then you get the real angle.", @"step 4: Rotate iPhone and confirm second line of the angle, then you get the real angle.");
    
    [self.scrollView addSubview:self.view0];
    [self.scrollView addSubview:self.view1];
    [self.scrollView addSubview:self.view2];
    [self.scrollView addSubview:self.view3];
    [self.scrollView addSubview:self.view4];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Scroll View delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    self.pageControl.currentPage = page;
    
    
}

@end
