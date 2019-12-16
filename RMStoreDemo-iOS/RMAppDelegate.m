//
//  RMAppDelegate.m
//  RMStoreDemo
//
//  Created by Hermes Pique on 7/30/13.
//  Copyright (c) 2013 Robot Media SL (http://www.robotmedia.net)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RMAppDelegate.h"
#import "RMStoreViewController.h"
#import "RMPurchasesViewController.h"
#import "RMStore.h"
#import "RMStoreAppReceiptVerifier.h"
#if TARGET_OS_MACCATALYST
#    import "RMStoreUserDefaultsPersistence.h"
#else
#    import "RMStoreKeychainPersistence.h"
#endif

@implementation RMAppDelegate {
    id<RMStoreReceiptVerifier> _receiptVerifier;
    
    /* Catalyst won't work with Keychain Persistence unless we enable Keychain
     * sharing in the Signing & Capabilities section of the target, which we
     * would do, but won't, because it means PRODUCT_BUNDLE_IDENTIFIER won't
     * pick up our sample product ID's, which currently work with *every*
     * sample target. We'll persist things in User Defaults on Catalyst,
     * instead.
     */
#if TARGET_OS_MACCATALYST
    RMStoreUserDefaultsPersistence *_persistence;
#else
    RMStoreKeychainPersistence *_persistence;
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureStore];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *storeVC = [[RMStoreViewController alloc] initWithNibName:@"RMStoreViewController" bundle:nil];
    UINavigationController *vc1 = [[UINavigationController alloc] initWithRootViewController:storeVC];
    
    UIViewController *purchasesVC = [[RMPurchasesViewController alloc] initWithNibName:@"RMPurchasesViewController" bundle:nil];
    UINavigationController *vc2 = [[UINavigationController alloc] initWithRootViewController:purchasesVC];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[vc1, vc2];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)configureStore
{
    _receiptVerifier = [[RMStoreAppReceiptVerifier alloc] init];
    [RMStore defaultStore].receiptVerifier = _receiptVerifier;
    
#if TARGET_OS_MACCATALYST
    _persistence = [[RMStoreUserDefaultsPersistence alloc] init];
#else
    _persistence = [[RMStoreKeychainPersistence alloc] init];
#endif
    [RMStore defaultStore].transactionPersistor = _persistence;
}

@end
