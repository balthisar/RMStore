# RMStore

A lightweight iOS and macOS library for In-App Purchases.

RMStore adds blocks and notifications to StoreKit, plus receipt verification,
content downloads, and transaction persistence]. All in one class without 
external dependencies. Purchasing a product is as simple as:

```objective-c
[[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
    NSLog(@"Purchased!");
} failure:^(SKPaymentTransaction *transaction, NSError *error) {
    NSLog(@"Something went wrong");
}];
```

## Important Maintenance Note

The original repository by Hermes Pique ("Robot Media") is no longer being
maintained. I'm not a CocoaPods user, and so the the CocoaPods instructions
probably won't work for you. If you'd like to contribute a fix, I'll be happy
to accept a PR.

The intent of this fork is to:

- Add/fix support macOS.
- Add/fix support for macOS Catalyst.
- Integrate many of the fixes and improvements made by the community.
- Provide an XCFramework.

I've applied some fixes and improvements from the fork network and the original
repository PR list. Because many of these have changed the API, these readme
instructions may be out of date. As always, though, headers are canon.


## Installation

Using [CocoaPods](http://cocoapods.org/), which probably doesn't work with
this fork:

```ruby
pod 'RMStore', '~> 0.9'
```

Carthage works. Add the following to your Cartfile:

```ruby
github "balthisar/RMStore" "branch-of-your-choice"
```

Note that during the cleanup process for this repo, the master branch probably
reflects the original repository. I'd choose a different branch if you're
trying to use my fork.

Of course, you can install manually, too.

Have a look at the sample projects in the Xcode project for file locations,
etc.


## StoreKit with blocks

RMStore adds blocks to all asynchronous StoreKit operations.


### Requesting products

```objective-c
NSSet *products = [NSSet setWithArray:@[@"fabulousIdol", @"rootBeer", @"rubberChicken"]];
[[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
    NSLog(@"Products loaded");
} failure:^(NSError *error) {
    NSLog(@"Something went wrong");
}];
```

### Add payment

```objective-c
[[RMStore defaultStore] addPayment:@"waxLips" success:^(SKPaymentTransaction *transaction) {
    NSLog(@"Product purchased");
} failure:^(SKPaymentTransaction *transaction, NSError *error) {
    NSLog(@"Something went wrong");
}];
```

### Restore transactions

```objective-c
[[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
    NSLog(@"Transactions restored");
} failure:^(NSError *error) {
    NSLog(@"Something went wrong");
}];
```

### Refresh receipt

```objective-c
[[RMStore defaultStore] refreshReceiptOnSuccess:^{
    NSLog(@"Receipt refreshed");
} failure:^(NSError *error) {
    NSLog(@"Something went wrong");
}];
```

## Notifications

RMStore sends notifications of StoreKit related events and extends
`NSNotification` to provide relevant information. To receive them, implement
the desired methods of the `RMStoreObserver` protocol and add the observer
to `RMStore`.


### Adding and removing the observer

```objective-c
[[RMStore defaultStore] addStoreObserver:self];
...
[[RMStore defaultStore] removeStoreObserver:self];
```

### Products request notifications

```objective-c
- (void)storeProductsRequestFailed:(NSNotification*)notification
{
    NSError *error = notification.rm_storeError;
}

- (void)storeProductsRequestFinished:(NSNotification*)notification
{
    NSArray *products = notification.rm_products;
    NSArray *invalidProductIdentifiers = notification.rm_invalidProductIdentififers;
}
```

### Payment transaction notifications

Payment transaction notifications are sent after a payment has been requested
or for each restored transaction.

```objective-c
- (void)storePaymentTransactionFinished:(NSNotification*)notification
{
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
}

- (void)storePaymentTransactionFailed:(NSNotification*)notification
{
    NSError *error = notification.rm_storeError;
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
}

- (void)storePaymentTransactionDeferred:(NSNotification*)notification
{
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
}
```

### Restore transactions notifications

```objective-c
- (void)storeRestoreTransactionsFailed:(NSNotification*)notification;
{
    NSError *error = notification.rm_storeError;
}

- (void)storeRestoreTransactionsFinished:(NSNotification*)notification
{
	NSArray *transactions = notification.rm_transactions;
}
```

### Download notifications

For Apple-hosted and self-hosted downloads:

```objective-c
- (void)storeDownloadFailed:(NSNotification*)notification
{
    SKDownload *download = notification.rm_storeDownload; // Apple-hosted only
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    NSError *error = notification.rm_storeError;
}

- (void)storeDownloadFinished:(NSNotification*)notification;
{
    SKDownload *download = notification.rm_storeDownload; // Apple-hosted only
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
}

- (void)storeDownloadUpdated:(NSNotification*)notification
{
    SKDownload *download = notification.rm_storeDownload; // Apple-hosted only
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    float progress = notification.rm_downloadProgress;
}
```

Only for Apple-hosted downloads:

```objective-c
- (void)storeDownloadCanceled:(NSNotification*)notification
{
	SKDownload *download = notification.rm_storeDownload;
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
}

- (void)storeDownloadPaused:(NSNotification*)notification
{
	SKDownload *download = notification.rm_storeDownload;
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
}
```

### Refresh receipt notifications

```objective-c
- (void)storeRefreshReceiptFailed:(NSNotification*)notification;
{
    NSError *error = notification.rm_storeError;
}

- (void)storeRefreshReceiptFinished:(NSNotification*)notification { }
```

## Receipt verification

RMStore doesn't perform receipt verification by default but provides reference
implementations. You can implement your own custom verification or use the
reference verifiers provided by the library.

Both options are outlined below. For more info, check out the
[wiki](https://github.com/robotmedia/RMStore/wiki/Receipt-verification).


### Reference verifiers

RMStore provides receipt verification via `RMStoreAppReceiptVerifier`. To use
it, add the corresponding files from `RMStore/Optional/` into your project and
set the verifier delegate (`receiptVerifier`) at startup. For example:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _receiptVerifier = [[RMStoreAppReceiptVerifier alloc] init];
    [RMStore defaultStore].receiptVerifier = _receiptVerifier;
    // Your code
    return YES;
}
```

If security is a concern you might want to avoid using an open source
verification logic, and provide your own custom verifier instead.


### Custom verifier

RMStore delegates receipt verification, enabling you to provide your own
implementation using  the `RMStoreReceiptVerifier` protocol:

```objective-c
- (void)verifyTransaction:(SKPaymentTransaction*)transaction
                           success:(void (^)())successBlock
                           failure:(void (^)(NSError *error))failureBlock;
```

Call `successBlock` if the receipt passes verification, and `failureBlock` if it
doesn't. If verification couldn't be completed (e.g., due to connection issues),
then `error` must be of code `RMStoreErrorCodeUnableToCompleteVerification` to
prevent RMStore from finishing the transaction.

You will also need to set the `receiptVerifier` delegate at startup, as
indicated above.


## Downloading content

RMStore automatically downloads Apple-hosted content and provides a delegate
for a self-hosted content.


### Apple-hosted content

Downloadable content hosted by Apple (`SKDownload`) will be automatically
downloaded when purchasing o restoring a product. RMStore will notify observers
of the download progress by calling `storeDownloadUpdate:` and finally
`storeDownloadFinished:`. Additionally, RMStore notifies when downloads are
paused, cancelled or have failed.

RMStore will notify that a transaction finished or failed only after all of its
downloads have been processed. If you use blocks, they will called afterwards
as well. The same applies to restoring transactions.


### Self-hosted content

RMStore delegates the downloading of self-hosted content via the optional
`contentDownloader` delegate. You can provide your own implementation using
the `RMStoreContentDownloader` protocol:

```objective-c
- (void)downloadContentForTransaction:(SKPaymentTransaction*)transaction
                              success:(void (^)())successBlock
                             progress:(void (^)(float progress))progressBlock
                              failure:(void (^)(NSError *error))failureBlock;
```

Call `successBlock` if the download is successful, `failureBlock` if it isn't
and `progressBlock` to notify the download progress. RMStore will consider that
a transaction has finished or failed only after the content downloader delegate
has successfully or unsuccessfully downloaded its content.


##Transaction persistence

RMStore delegates transaction persistence and provides two optional reference
implementations for storing transactions in the Keychain or in `NSUserDefaults`.
You can implement your transaction, use the reference implementations provided
by the library or, in the case of non-consumables and auto-renewable
subscriptions, get the transactions directly from the receipt.

For more info, check out the [wiki](https://github.com/robotmedia/RMStore/wiki/Transaction-persistence).


## Accepting Store Payments

iOS 11 added support for users to purchase in-app purchases through the
App Store directly. RMStore supports this functionality by implementing the
below `SKPaymentTransactionObserver` delegate method.

```objective-c
(BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product;
```


### RMStoreStorePaymentAcceptor

RMStore uses `RMStoreStorePaymentAcceptor` to determine whether or not the
store payment should be added to the payment queue (accepted). If you
**don't** provide a `RMStoreStorePaymentAcceptor`, any store payment received
by RMStore will **not** be added to the payment queue (accepted) and will be
stored, allwoing it to be added to the payment queue later.

If you provide your own `RMStoreStorePaymentAcceptor` and return `NO` from
`acceptStorePayment:`, the store payment will also be stored by RMStore.
If you return `YES`, the system will add the store payment to the payment queue.

```objective-c
@protocol RMStoreStorePaymentAcceptor

- (BOOL)acceptStorePayment:(SKPayment*)payment fromQueue:(SKPaymentQueue*)queue forProduct:(SKProduct*)product;

@end
```

### Accepting Stored Payments

When your app is ready to add the stored store payments to the payment queue,
use the `acceptStoredStorePayments` method on RMStore.

```objective-c
[[RMStore defaultStore] acceptStoredStorePayments];
```


## Requirements

RMStore requires iOS 9.0+ or macOS 10.12+ and ARC.


## Roadmap

This fork of RMStore has an uncertain future. I'm mostly maintaining it for my
own needs (Objective-C on macOS), but I'm happy to implement fixes for iOS as
well as new IAP features.


## License

Copyright 2013-2016 [Robot Media SL](http://www.robotmedia.net)
Copyright 2013-2019 by additional contributors. See git contributors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
