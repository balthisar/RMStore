//
//  RMStoreViewController.m
//  RMStore
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

#import "RMStoreViewController.h"
#import "RMStore.h"

@implementation RMStoreViewController {
    NSArray *_products;
    BOOL _productsRequestFinished;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) )
    {
        self.title = NSLocalizedString(@"Store", @"");
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* An array of product names as registered on the App Store. One of this
     * sample list is deliberately not registered, so that we can deal with
     * a negative response from the server appropriately.
     */
    _products = @[@"com.balthisar.RMStoreDemoMac.nonconsumable",
                  @"com.balthisar.RMStoreDemoMac.consumable",
                  @"com.balthisar.RMStoreDemoMac.subrenewing",
                  @"com.balthisar.RMStoreDemoMac.sub52",
                  @"com.balthisar.RMStoreDemoMac.subnonrenewing",
                  @"com.balthisar.RMStoreDemoMac.fake"];

    
    /* This will actually begin the fetching process from the App Store.
     */
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:_products] success:^(NSArray *products, NSArray *invalidProductIdentifiers)
    {
        NSMutableArray *new_products = [NSMutableArray arrayWithArray:self->_products];
        [new_products removeObjectsInArray:invalidProductIdentifiers];
        self->_products = new_products;
        
        dispatch_async(dispatch_get_main_queue(), ^{
           self->_productsRequestFinished = YES;
           [self.tableView reloadData];
        });
    } failure:^(NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Products Request Failed", @"")
                                                                               message:error.localizedDescription
                                                                        preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {}];
            
            [alertView addAction:okButton];
            [self presentViewController:alertView animated:YES completion:nil];
        });
    }];
}


#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _productsRequestFinished ? _products.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSString *productID = _products[indexPath.row];
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = [RMStore localizedPriceOfProduct:product];
    return cell;
}


#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![RMStore canMakePayments]) return;
    
    NSString *productID = _products[indexPath.row];

    [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction)
    {
        NSLog(@"%@", @"addPayment successful.");
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Payment Transaction Failed", @"")
                                                                               message:error.localizedDescription
                                                                        preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {}];
            
            [alertView addAction:okButton];
            [self presentViewController:alertView animated:YES completion:nil];
        });
    }];
}

@end
