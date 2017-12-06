//
//  SRIAPHelper.h
//  HeadHit
//
//  Created by Rotek on 3/4/13.
//  Copyright (c) 2013 Rotek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperTransactionFinishedNotification;
UIKIT_EXTERN NSString *const IAPHelperTransactionErrorNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);

@interface SRIAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
