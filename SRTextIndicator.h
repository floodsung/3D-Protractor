//
//  SRTextIndicator.h
//  3D Protractor
//
//  Created by Rotek on 13-1-17.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRTextIndicator : NSObject

- (id)initWithView:(UIView *)aView;
- (void)showIndicatorWithString:(NSString *)string withCompletionHandler:(void(^)(BOOL finished))block;
- (void)showDelayIndicatorWithString:(NSString *)string;
- (void)showStayIndicatorWithString:(NSString *)string;
- (void)hideStayIndicator;
@end
