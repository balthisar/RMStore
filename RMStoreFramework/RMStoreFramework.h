//
//  RMStoreFramework.h
//  RMStoreFramework
//
//  Created by Bruno Virlet on 5/15/19.
//  Copyright © 2019 Robot Media. All rights reserved.
//

#include <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Foundation/Foundation.h>
#endif

//! Project version number for RMStoreFramework.
FOUNDATION_EXPORT double RMStoreFrameworkVersionNumber;

//! Project version string for RMStoreFramework.
FOUNDATION_EXPORT const unsigned char RMStoreFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <RMStoreFramework/PublicHeader.h>

#import <RMStoreFramework/RMAppReceipt.h>
#import <RMStoreFramework/RMStoreAppReceiptVerifier.h>
#import <RMStoreFramework/RMStoreKeychainPersistence.h>
#import <RMStoreFramework/RMStoreTransaction.h>
#import <RMStoreFramework/RMStoreUserDefaultsPersistence.h>
#import <RMStoreFramework/RMStore.h>
