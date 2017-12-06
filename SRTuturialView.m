//
//  SRTuturialView.m
//  3D Protractor
//
//  Created by Rotek on 13-1-19.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRTuturialView.h"
#import <QuartzCore/QuartzCore.h>
#define IMAGE_LENGTH_RATE  0.5
#define TEXT_LENGTH_RATE 0.8

@implementation SRTuturialView
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;
@synthesize versionLabel = _versionLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // Configure view
        self.backgroundColor = [UIColor clearColor];
        
        // Setup imageview
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width * (1 - IMAGE_LENGTH_RATE) / 2, frame.size.height / frame.size.width * frame.size.width * (1 - IMAGE_LENGTH_RATE) / 2, frame.size.width * IMAGE_LENGTH_RATE, frame.size.width * IMAGE_LENGTH_RATE)];
        self.imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageView];
        
        // Setup versionLabel
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
            self.versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * (1 - TEXT_LENGTH_RATE) / 2,self.imageView.frame.origin.y -  0.2 * self.imageView.frame.size.width, frame.size.width * TEXT_LENGTH_RATE, 20)];
            self.versionLabel.font = [UIFont boldSystemFontOfSize:15];
        } else {
            self.versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * (1 - TEXT_LENGTH_RATE) / 2,self.imageView.frame.origin.y -  0.2 * self.imageView.frame.size.width, frame.size.width * TEXT_LENGTH_RATE, 30)];
            self.versionLabel.font = [UIFont boldSystemFontOfSize:20];
            
        }
        
        self.versionLabel.backgroundColor = [UIColor clearColor];
        self.versionLabel.textColor = [UIColor whiteColor];
        self.versionLabel.textAlignment = UITextAlignmentCenter;
        self.versionLabel.numberOfLines = 1;
        self.versionLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.versionLabel.layer.shadowOffset = CGSizeMake(0, 1);
        self.versionLabel.layer.shadowRadius = 3;
        self.versionLabel.layer.masksToBounds = NO;
        self.versionLabel.layer.shadowOpacity = 1;

        [self addSubview:self.versionLabel];
        
        // Setup textlabel
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
            self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * (1 - TEXT_LENGTH_RATE) / 2, self.imageView.frame.origin.y + 1.2 * self.imageView.frame.size.height, frame.size.width * TEXT_LENGTH_RATE, 80)];
            self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        } else {
            self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * (1 - TEXT_LENGTH_RATE) / 2, self.imageView.frame.origin.y + 1.2 * self.imageView.frame.size.height, frame.size.width * TEXT_LENGTH_RATE, 100)];
            self.textLabel.font = [UIFont boldSystemFontOfSize:20];
        }
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.numberOfLines = 4;
        self.textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.textLabel.layer.shadowOffset = CGSizeMake(0, 1);
        self.textLabel.layer.shadowRadius = 3;
        self.textLabel.layer.masksToBounds = NO;
        self.textLabel.layer.shadowOpacity = 1;
        
        [self addSubview:self.textLabel];
        

        
        
    }
    return self;
}


@end
