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
@property( strong, readwrite, nonatomic) RMStoreKeychainPersistence *persistence;

@end

@implementation AppDelegate

- (instancetype)init
{
    if ( (self = [super init]) )
    {
        self.verifier = [[RMStoreAppReceiptVerifier alloc] init];
        [RMStore defaultStore].receiptVerifier = self.verifier;

        self.persistence = [[RMStoreKeychainPersistence alloc] init];
        [RMStore defaultStore].transactionPersistor = self.persistence;
    }
    
    return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[RMStore defaultStore] refreshReceiptOnSuccess:^{
        NSLog(@"%@", @"Success");
    } failure:^(NSError *error) {
        NSLog(@"%@", @"Lack of Success");
    }];
}

@end
