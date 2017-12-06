//
//  SRSettingSelectionCell.m
//  3D Protractor
//
//  Created by Rotek on 13-1-16.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRSettingSelectionCell.h"

@implementation SRSettingSelectionCell
@synthesize selectionSwitch = _selectionSwitch;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            self.selectionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(320 - 79 - 20 , 8, 79, self.frame.size.height - 27 - 8)];
        } else {
            self.selectionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(540 - 79 - 40 , 8, 79, self.frame.size.height - 27 - 8)];
        }
        
        [self addSubview:self.selectionSwitch];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
