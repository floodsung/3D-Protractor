//
//  SRAboutViewController.m
//  3D Protractor
//
//  Created by Rotek on 13-1-20.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRAboutViewController.h"
#import <QuartzCore/QuartzCore.h>
#define ICON_LENGTH_RATE  0.3

@interface SRAboutViewController ()

@end

@implementation SRAboutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)  {
        self.view.frame = CGRectMake(0, 0, 540, 620);
    }
    self.title = NSLocalizedString(@"About", @"about");
    // Add imageView

    
   
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * (1 - ICON_LENGTH_RATE) / 2, self.view.frame.size.width * (1 - ICON_LENGTH_RATE) / 2, self.view.frame.size.width * ICON_LENGTH_RATE, self.view.frame.size.width * ICON_LENGTH_RATE)];

    imageView.image = [UIImage imageNamed:@"Icon"];
    [self.view addSubview:imageView];
    
    float bufferLength = self.view.frame.size.width * (1 - ICON_LENGTH_RATE) / 2 + self.view.frame.size.width * ICON_LENGTH_RATE;
    // Add label
    // 1 Add ProductName
    UILabel *productLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bufferLength + 0.05 * self.view.frame.size.width, self.view.frame.size.width, 20)];
    productLabel.backgroundColor = [UIColor clearColor];
    productLabel.textColor = [UIColor whiteColor];
    productLabel.textAlignment = UITextAlignmentCenter;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        productLabel.font = [UIFont boldSystemFontOfSize:20];
    } else {
        productLabel.font = [UIFont boldSystemFontOfSize:25];
    }
    productLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    productLabel.layer.shadowOffset = CGSizeMake(0, 1);
    productLabel.layer.shadowRadius = 3;
    productLabel.layer.masksToBounds = NO;
    productLabel.layer.shadowOpacity = 1;

    productLabel.text = NSLocalizedString(@"3D Protractor", @"3D protractor");
    [self.view addSubview:productLabel];
    
    // 2 add Version
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bufferLength + 0.13 * self.view.frame.size.width, self.view.frame.size.width * 0.8, 20)];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.textColor = [UIColor whiteColor];
    versionLabel.textAlignment = UITextAlignmentRight;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        versionLabel.font = [UIFont boldSystemFontOfSize:17];
    } else {
        versionLabel.font = [UIFont boldSystemFontOfSize:22];
    }
    versionLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    versionLabel.layer.shadowOffset = CGSizeMake(0, 1);
    versionLabel.layer.shadowRadius = 3;
    versionLabel.layer.masksToBounds = NO;
    versionLabel.layer.shadowOpacity = 1;
    
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    versionLabel.text = [NSString stringWithFormat:@"V %@",versionString];
    [self.view addSubview:versionLabel];
    
    // 3 add category
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bufferLength + 0.20 * self.view.frame.size.width, self.view.frame.size.width * 0.5, 120)];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.textColor = [UIColor whiteColor];
    categoryLabel.textAlignment = UITextAlignmentRight;
    categoryLabel.numberOfLines = 4;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        categoryLabel.font = [UIFont boldSystemFontOfSize:15];
    } else {
        categoryLabel.font = [UIFont boldSystemFontOfSize:22];
    }
    categoryLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    categoryLabel.layer.shadowOffset = CGSizeMake(0, 1);
    categoryLabel.layer.shadowRadius = 3;
    categoryLabel.layer.masksToBounds = NO;
    categoryLabel.layer.shadowOpacity = 1;
    categoryLabel.text = NSLocalizedString(@"Programming:\nGraphic Design:\nTesting/Suggestion:\n", @"programming");
    [self.view addSubview:categoryLabel];
    
    // 4 add names
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.5, bufferLength + 0.20 * self.view.frame.size.width, self.view.frame.size.width * 0.5, 120)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = UITextAlignmentLeft;
    nameLabel.numberOfLines = 4;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        nameLabel.font = [UIFont systemFontOfSize:15];
    } else {
        nameLabel.font = [UIFont systemFontOfSize:22];
    }
    nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    nameLabel.layer.shadowOffset = CGSizeMake(0, 1);
    nameLabel.layer.shadowRadius = 3;
    nameLabel.layer.masksToBounds = NO;
    nameLabel.layer.shadowOpacity = 1;
    nameLabel.text = NSLocalizedString(@" Rotek Song\n Rotek Song\n LittleCool,Shenglei\n", @"rotek song");
    [self.view addSubview:nameLabel];
    

    // 5 add SinaWeibo
    UIButton *sinaWeiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sinaWeiboButton setBackgroundImage:[UIImage imageNamed:@"sinaWeibo"] forState:UIControlStateNormal];
    sinaWeiboButton.frame = CGRectMake(self.view.frame.size.width - 50, 55, 40, 40);
    [sinaWeiboButton addTarget:self action:@selector(showSinaWeibo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sinaWeiboButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSinaWeibo
{
    NSURL *url = [NSURL URLWithString:@"http://weibo.cn/songrotek"];
    [[UIApplication sharedApplication] openURL:url];
}

@end
