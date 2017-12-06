//  3D Protractor
//
//  Created by Rotek on 13-1-15.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
@protocol SRSettingViewControllerProtocol <NSObject>

- (void)changeTextIndicatorStatus;

@end

@interface SRSettingViewController : UIViewController<MFMailComposeViewControllerDelegate>
@property (nonatomic,weak) id<SRSettingViewControllerProtocol>delegate;
@end
