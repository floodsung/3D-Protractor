//
//  SRInAppPurchaseViewController.m
//  3D Protractor
//
//  Created by Rotek on 3/14/13.
//  Copyright (c) 2013 Rotek. All rights reserved.
//

#import "SRInAppPurchaseViewController.h"
#import "SRProtractorIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "SRProductInfo.h"
@interface SRInAppPurchaseViewController (){
    NSArray *_products;
}
@property (nonatomic,strong) NSArray *productsInfo;
@property (nonatomic,strong) UIAlertView *alertView;


@end

@implementation SRInAppPurchaseViewController
@synthesize productsInfo = _productsInfo;
@synthesize alertView = _alertView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"In App Purchase", @"In App Purchase");
    
    
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 540, 620) style:UITableViewStyleGrouped];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.tableView.frame = CGRectMake(0, 44, 320, self.view.frame.size.height - 44);
    } else {
        self.tableView.frame = CGRectMake(0, 44, 540, 620);
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Restore", @"Restore") style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];
    
    
    SRProductInfo *product1 = [[SRProductInfo alloc] init];
    product1.productName = NSLocalizedString(@"Camera Angle Mode", @"camera angle mode");
    product1.productIdentifier = @"com.manmanlai.protractorFree.CameraAngleMode";
    
    SRProductInfo *product2 = [[SRProductInfo alloc] init];
    product2.productName = NSLocalizedString(@"Slope Angle Mode", @"Slope Angle Mode");
    product2.productIdentifier = @"com.manmanlai.protractorFree.SlopeAngleMode";
    
    SRProductInfo *product3 = [[SRProductInfo alloc] init];
    product3.productName = NSLocalizedString(@"Dihedral Angle Mode", @"Dihedral Angle Mode");
    product3.productIdentifier = @"com.manmanlai.protractorFree.DihedralAngleMode";
    
    SRProductInfo *product4 = [[SRProductInfo alloc] init];
    product4.productName = NSLocalizedString(@"Line-Plane Angle Mode", @"Line-Plane Angle Mode");
    product4.productIdentifier = @"com.manmanlai.protractorFree.LinePlaneAngleMode";
    
    self.productsInfo = [NSArray arrayWithObjects:product1,product2,product3,product4, nil];
    
    
    [self.tableView reloadData];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.productsInfo = nil;
}

- (void)setupAlertView
{
    self.alertView = [[UIAlertView alloc] init];
    self.alertView.title = NSLocalizedString(@"Connect to App Store...", @"Connect to App Store...");
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setCenter:CGPointMake(140, 65)];
    [self.alertView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [self.alertView show];
}

- (void)restoreTapped:(id)sender
{
    [self setupAlertView];
    [[SRProtractorIAPHelper sharedInstance] restoreCompletedTransactions];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFinished:) name:IAPHelperTransactionFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionError:) name:IAPHelperTransactionErrorNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification
{
    NSString *productIdentifier = notification.object;

    [self.productsInfo enumerateObjectsUsingBlock:^(SRProductInfo *product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];

}

- (void)transactionFinished:(NSNotification *)notification
{
    [self.alertView dismissWithClickedButtonIndex:nil animated:NO];
}

- (void)transactionError:(NSNotification *)notification
{
    UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase Error", @"Purchase Error") message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [failedAlert show];
    
    [self.alertView dismissWithClickedButtonIndex:nil animated:NO];


    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _productsInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    SRProductInfo *productInfo = [self.productsInfo objectAtIndex:indexPath.row];
    cell.textLabel.text = productInfo.productName;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([[SRProtractorIAPHelper sharedInstance] productPurchased:productInfo.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buyButton setBackgroundImage:[UIImage imageNamed:@"purchaseButton.png"] forState:UIControlStateNormal];
        buyButton.frame = CGRectMake(0, 0, 60, 25);
        [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [buyButton setTitle:@"$0.99" forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }
    
    return cell;
}



- (void)buyButtonTapped:(id)sender
{
    
    UIButton *buyButton = (UIButton *)sender;
    SRProductInfo *productInfo = [self.productsInfo objectAtIndex:buyButton.tag];
    
    NSLog(@"Buying %@...",productInfo.productIdentifier);
    
    [self setupAlertView];
    
    if (_products == nil) {
        [[SRProtractorIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                _products = products;
                for (SKProduct *product in products) {
                    if ([product.productIdentifier isEqualToString:productInfo.productIdentifier]) {
                        [[SRProtractorIAPHelper sharedInstance] buyProduct:product];
                    }
                }
                
            } else {
                [self transactionError:nil];
            }
        }];
    } else {
        for (SKProduct *product in _products) {
            if ([product.productIdentifier isEqualToString:productInfo.productIdentifier]) {
                [[SRProtractorIAPHelper sharedInstance] buyProduct:product];
            }
        }
    }

}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"The Ad would be removed as long as you purchase any one of the products above!", @"The Ad would be removed as long as you purchase any one of the products above!");
}
@end
