//
//  SRTextIndicator.m
//  3D Protractor
//
//  Created by Rotek on 13-1-17.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRTextIndicator.h"
#import <QuartzCore/QuartzCore.h>

#define TEXT_INDICATOR_WIDTH_IPHONE  220
#define TEXT_INDICATOR_HEIGHT_IPHONE 90
#define TEXT_INDICATOR_CORNER_RADIUS_IPHONE  10.0f
#define TEXT_INDICATOR_FONT_IPHONE  17.0f

#define TEXT_INDICATOR_WIDTH_IPAD  300
#define TEXT_INDICATOR_HEIGHT_IPAD 130
#define TEXT_INDICATOR_CORNER_RADIUS_IPAD  15.0f
#define TEXT_INDICATOR_FONT_IPAD  25.0f

#define TEXT_INDICATOR_ALPHA   0.7f


@interface SRTextIndicator ()
@property (nonatomic,strong) UILabel *indicator;
@property (nonatomic,strong) UIView *view;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation SRTextIndicator
@synthesize indicator = _indicator;
@synthesize activityIndicator = _activityIndicator;

- (id)initWithView:(UIView *)aView
{
    if (self = [super init]) {
        
        // Setup view
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            self.view = [[UIView alloc] initWithFrame:CGRectMake(aView.frame.size.width / 2 - TEXT_INDICATOR_WIDTH_IPHONE / 2, aView.frame.size.height / 2 - TEXT_INDICATOR_HEIGHT_IPHONE / 2, TEXT_INDICATOR_WIDTH_IPHONE, TEXT_INDICATOR_HEIGHT_IPHONE)];
            self.view.layer.cornerRadius = TEXT_INDICATOR_CORNER_RADIUS_IPHONE;
        } else {
            self.view = [[UIView alloc] initWithFrame:CGRectMake(aView.frame.size.width / 2 - TEXT_INDICATOR_WIDTH_IPAD / 2, aView.frame.size.height / 2 - TEXT_INDICATOR_HEIGHT_IPAD / 2, TEXT_INDICATOR_WIDTH_IPAD, TEXT_INDICATOR_HEIGHT_IPAD)];
            self.view.layer.cornerRadius = TEXT_INDICATOR_CORNER_RADIUS_IPAD;
        }
        
        self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:TEXT_INDICATOR_ALPHA];
        self.view.alpha = 0;
        [aView addSubview:self.view];
        
        // Setup text label
        self.indicator = [[UILabel alloc] init];
        self.indicator.backgroundColor = [UIColor clearColor];
        self.indicator.textColor = [UIColor whiteColor];
        self.indicator.numberOfLines = 4;
        self.indicator.textAlignment = UITextAlignmentCenter;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            self.indicator.font = [UIFont systemFontOfSize:TEXT_INDICATOR_FONT_IPHONE];
            
            self.indicator.frame = CGRectMake(5, 0, TEXT_INDICATOR_WIDTH_IPHONE - 10, TEXT_INDICATOR_HEIGHT_IPHONE);
        } else {
            self.indicator.font = [UIFont systemFontOfSize:TEXT_INDICATOR_FONT_IPAD];
            
            self.indicator.frame = CGRectMake(5, 0, TEXT_INDICATOR_WIDTH_IPAD - 10, TEXT_INDICATOR_HEIGHT_IPAD);
        }
        
        [self.view addSubview:self.indicator];
        
        // Setup activityIndicator
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            
            self.activityIndicator.frame = CGRectMake((TEXT_INDICATOR_WIDTH_IPHONE - 37)/2 , TEXT_INDICATOR_HEIGHT_IPHONE - 45, 37, 37);
        } else {            
            self.activityIndicator.frame = CGRectMake((TEXT_INDICATOR_WIDTH_IPAD - 37)/2 , TEXT_INDICATOR_HEIGHT_IPAD - 45, 37, 37);
        }
        self.activityIndicator.hidden = YES;
        [self.view addSubview:self.activityIndicator];
        
    }
    
    return self;
}

- (void)showIndicatorWithString:(NSString *)string withCompletionHandler:(void(^)(BOOL))block
{
    self.indicator.text = string;
    self.activityIndicator.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
            self.view.alpha = 0;
        } completion:block];
    }];
}

- (void)showDelayIndicatorWithString:(NSString *)string
{
    self.indicator.text = string;
    self.activityIndicator.hidden = YES;

    [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:1.3 options:0 animations:^{
            self.view.alpha = 0;
        } completion:nil];
    }];
}

- (void)showStayIndicatorWithString:(NSString *)string
{
    self.indicator.text = string;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 1;
    }];
}

- (void)hideStayIndicator
{
    
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0;
        
    }];
}


@end
