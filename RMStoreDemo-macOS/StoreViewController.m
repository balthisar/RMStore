//
//  StoreViewController.m
//  RMStoreDemo (macOS)
//
//  Created by Jim Derry on 12/12/19.
//

#import "StoreViewController.h"
#import <RMStoreFramework/RMStoreFramework.h>

@interface StoreViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (strong) NSMutableArray *products;
@property (assign) BOOL productsRequestFinished;

@end


@implementation StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.products = [NSMutableArray arrayWithArray:@[@"com.balthisar.RMStoreDemoMac.nonconsumable",
                                                     @"com.balthisar.RMStoreDemoMac.consumable",
                                                     @"com.balthisar.RMStoreDemoMac.subrenewing",
                                                     @"com.balthisar.RMStoreDemoMac.sub52",
                                                     @"com.balthisar.RMStoreDemoMac.subnonrenewing",
                                                     @"com.balthisar.RMStoreDemoMac.fake"]];
    
    RMStore *store = [RMStore defaultStore];
    
    [store requestProducts:[NSSet setWithArray:self.products]
                   success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        dispatch_async(dispatch_get_main_queue(), ^{
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
            for (NSString *invalidProduct in invalidProductIdentifiers)
            {
                [self.products removeObject:invalidProduct];
            }
            self.productsRequestFinished = YES;
            [self.tableView reloadData];
        });
    }
                   failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{

                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"Unable to fetch product information", nil)];
                [alert setInformativeText:error.localizedDescription];
                [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
                [alert runModal];
            });
        }];
}


#pragma mark - Table view data source


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.productsRequestFinished ? _products.count : 0;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:self.products[row]];
    if ([tableColumn.identifier isEqualToString:@"item"])
    {
        return product.localizedTitle;
    }

    return [RMStore localizedPriceOfProduct:product];
}


#pragma mark - Table view delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *table = notification.object;

    if ( ![RMStore canMakePayments] || table.selectedRow < 0 ) return;
        
    NSString *productID = self.products[table.selectedRow];
    
    [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction)
    {
        NSLog(@"%@", @"addPayment successful.");

    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{

            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"Payment Transaction Failed", nil)];
            [alert setInformativeText:error.localizedDescription];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
            [alert runModal];
        });
    }];
}

@end
