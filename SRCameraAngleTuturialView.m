//
//  SRCameraAngleTuturialView.m
//  3D Protractor
//
//  Created by Rotek on 2/24/13.
//  Copyright (c) 2013 Rotek. All rights reserved.
//

#import "SRCameraAngleTuturialView.h"
#import <QuartzCore/QuartzCore.h>
#define IMAGE_LENGTH_RATE  0.6
#define TEXT_LENGTH_RATE 0.8

@implementation SRCameraAngleTuturialView
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // Configure view
        self.backgroundColor = [UIColor clearColor];
        
        // Setup imageview
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - frame.size.height * IMAGE_LENGTH_RATE / 1.5) / 2,frame.size.height / 1.5 * (1 - IMAGE_LENGTH_RATE) / 2, frame.size.height * IMAGE_LENGTH_RATE / 1.5,frame.size.height * IMAGE_LENGTH_RATE)];
        self.imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageView];
        self.imageView.layer.cornerRadius = 10;
        self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.imageView.layer.shadowOffset = CGSizeMake(0, 1);
        self.imageView.layer.shadowRadius = 5;
        //self.imageView.layer.masksToBounds = NO;
        self.imageView.layer.shadowOpacity = 1;
        
        
        // Setup textlabel
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
            self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * (1 - TEXT_LENGTH_RATE) / 2, self.imageView.frame.origin.y + 1.03 * self.imageView.frame.size.height, frame.size.width * TEXT_LENGTH_RATE, 80)];
            self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        } else {
            self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * (1 - TEXT_LENGTH_RATE) / 2, self.imageView.frame.origin.y + 1.03 * self.imageView.frame.size.height, frame.size.width * TEXT_LENGTH_RATE, 100)];
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
