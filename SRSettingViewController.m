//
//  SRSettingViewController.m
//  3D Protractor
//
//  Created by Rotek on 13-1-15.
//  Copyright (c) 2013年 Rotek. All rights reserved.
//

#import "SRSettingViewController.h"
#import "SRSettingSelectionCell.h"
#import "SRTuturialViewController.h"
#import "SRAboutViewController.h"
#ifdef LITE_VERSION
#import "SRInAppPurchaseViewController.h"
#endif
#import "SRAppID.h"


@interface SRSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation SRSettingViewController
@synthesize tableView = _tableView;
@synthesize delegate = _delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1 Configure view
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    // 3 Setup tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 540, 620) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.tableView.frame = CGRectMake(0, 44, 320, self.view.frame.size.height - 44);
    } else {
        self.tableView.frame = CGRectMake(0, 44, 540, 620);
    }
    //tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self.tableView reloadData];
}

- (void)back:(UIBarButtonItem *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
#ifdef LITE_VERSION
        return 4;
#else
        return 2;
#endif
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SRSettingSelectionCell *cell = [[SRSettingSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SRSettingSelectionCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Tuturial", @"tuturial");
                    
                    cell.selectionSwitch.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 1:
                {
                    cell.textLabel.text = NSLocalizedString(@"Text Indicator", @"text indicator");
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell.selectionSwitch addTarget:self action:@selector(changeTextIndicator:) forControlEvents:UIControlEventValueChanged];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     NSNumber *value = [defaults objectForKey:@"Text indicator is off"];
                    if ([value boolValue]) {
                        cell.selectionSwitch.on = NO;
                    } else cell.selectionSwitch.on = YES;
                    cell.textLabel.font = [UIFont systemFontOfSize:0];
                    //NSLog(@"font is %@",cell.textLabel.font);
                    
                    break;
                }
                case 2:
                {
                    cell.textLabel.text = NSLocalizedString(@"Buy Full Version", @"buy full version");
                    cell.selectionSwitch.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 3:
                {
                    cell.textLabel.text = NSLocalizedString(@"In App Purchase", @"In App Purchase");
                    cell.selectionSwitch.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Rate", @"rate");
                    cell.selectionSwitch.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"Feedback", @"feedback");
                    cell.selectionSwitch.hidden = YES;
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"About", @"about");
                    cell.selectionSwitch.hidden = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    // Tuturial
                    SRTuturialViewController *tuturialViewController = [[SRTuturialViewController alloc] init];
                    [self.navigationController pushViewController:tuturialViewController animated:YES];
                    
                }
                    break;
                case 2:
                {
                    // Buy full version
                    NSLog(@"Buy full version");
                    NSString *path = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",APP_ID_FULL_VERSION];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
                    [self.tableView reloadData];
                }
                    break;
#ifdef LITE_VERSION
                case 3:
                {
                    
                    SRInAppPurchaseViewController *inAppPurchaseViewController = [[SRInAppPurchaseViewController alloc] init];
                    [self.navigationController pushViewController:inAppPurchaseViewController animated:YES];
                    break;
                }
#endif
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    // Rate
#ifdef LITE_VERSION
                    NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",APP_ID_LITE_VERSION];
#else
                    NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",APP_ID_FULL_VERSION];
#endif
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                    [self.tableView reloadData];
                }
                    break;
                case 1:
                {
                    // Feedback
                    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                        picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    }
                    
                    picker.mailComposeDelegate = self;
                    [picker setToRecipients:[NSArray arrayWithObjects:@"songrotek@qq.com", nil]];
                    [picker setSubject:NSLocalizedString(@"Feedback", @"feedback")];
                    
                    [self presentModalViewController:picker animated:YES];
                    [self.tableView reloadData];
                }
                    break;
                case 2:
                {
                    // About
                    SRAboutViewController *aboutViewController = [[SRAboutViewController alloc] init];
                    aboutViewController.navigationController.title = NSLocalizedString(@"About", @"about");
                    [self.navigationController pushViewController:aboutViewController animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)changeTextIndicator:(UISwitch *)aSwitch
{
    NSLog(@"change!");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *textIndicatorIsOff = [NSNumber numberWithBool:!aSwitch.isOn];
    [defaults setObject:textIndicatorIsOff forKey:@"Text indicator is off"];
    [defaults synchronize];
    [self.delegate changeTextIndicatorStatus];
}

#pragma mark - mail compose view controller delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
@end
