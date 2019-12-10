//
//  AppDelegate.m
//  RMStoreDemoMac
//
//  Created by Jim Derry on 11/4/19.
//  Copyright © 2019 Robot Media. All rights reserved.
//

#import "AppDelegate.h"
#import <RMStoreFramework/RMStoreFramework.h>

@interface AppDelegate ()

@property (strong, readwrite, nonatomic) RMStoreAppReceiptVerifier *verifier;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.verifier = [[RMStoreAppReceiptVerifier alloc] init];
    [RMStore defaultStore].receiptVerifier = self.verifier;
    [self doStoreStuff];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}


#pragma mark - Actions

- (IBAction)doBuySomething:(id)sender
{
    [[RMStore defaultStore] addPayment:@"com.balthisar.RMStoreDemoMac.consumable" success:^(SKPaymentTransaction *transaction)
    {
        NSLog(@"%@", @"Success with addPayment.");
    } failure:^(SKPaymentTransaction *transaction, NSError *error)
    {
        NSLog(@"%@", @"Payment Transaction Failed");
        NSLog(@"Reason: %@", error.localizedDescription);

    }];
}


#pragma mark - Private


- (void)doStoreStuff
{
    NSArray *_products = @[@"com.balthisar.RMStoreDemoMac.nonconsumable",
                           @"com.balthisar.RMStoreDemoMac.consumable",
                           @"com.balthisar.RMStoreDemoMac.subrenewing",
                           @"com.balthisar.RMStoreDemoMac.sub52",
                           @"com.balthisar.RMStoreDemoMac.subnonrenewing",
                           @"com.balthisar.RMStoreDemoMac.fake"];
    
    NSSet *mySet = [NSSet setWithArray:_products];
    RMStore *store = [RMStore defaultStore];
    [store requestProducts:mySet success:^(NSArray *products, NSArray *invalidProductIdentifiers)
     {
        NSLog(@"%@", @"Success\n-------");
        for ( SKProduct *product in products )
        {
            NSLog(@"   productIdentifier: %@", product.productIdentifier);
            NSLog(@"      localizedTitle: %@", product.localizedTitle);
            NSLog(@"localizedDescription: %@", product.localizedDescription);
            NSLog(@"      contentVersion: %@", product.contentVersion);
            NSLog(@"               price: %@", product.price);
            NSLog(@"         priceLocale: %@\n---", product.priceLocale.localeIdentifier);
        }
        NSLog(@"%@", @"However, these ID's are invalid:");
        NSLog(@"%@", invalidProductIdentifiers);
    } failure:^(NSError *error) {
        NSLog(@"Error = %@", error);
        }];
}


@end
