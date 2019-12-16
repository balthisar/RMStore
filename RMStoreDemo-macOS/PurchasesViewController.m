//
//  PurchasesViewController.m
//  RMStoreDemo (macOS)
//
//  Created by Jim Derry on 12/12/19.
//

#import "PurchasesViewController.h"
#import "RMStore.h"
#import "RMStoreKeychainPersistence.h"

@interface PurchasesViewController () <RMStoreObserver>

@property (weak) IBOutlet NSTableView *tableView;
@property (strong) RMStoreKeychainPersistence *persistence;
@property (strong) NSArray *productIdentifiers;

@end


@implementation PurchasesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    RMStore *store = [RMStore defaultStore];
    [store addStoreObserver:self];
    self.persistence = store.transactionPersistor;
    self.productIdentifiers = self.persistence.purchasedProductIdentifiers.allObjects;
}



- (void)dealloc
{
    [[RMStore defaultStore] removeStoreObserver:self];
}


- (IBAction)restoreAction:(id)sender
{
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", @"restoreTransactionsOnSuccess:");
            [self.tableView reloadData];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"Restore Transactions Failed", nil)];
            [alert setInformativeText:error.localizedDescription];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
            [alert runModal];
        });
    }];
}


- (IBAction)trashAction:(id)sender
{
    [self.persistence removeTransactions];
    self.productIdentifiers = self.persistence.purchasedProductIdentifiers.allObjects;
    [self.tableView reloadData];
}


#pragma mark - Table view data source


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.productIdentifiers.count;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    RMStore *store = [RMStore defaultStore];
    NSString *productID = self.productIdentifiers[row];
    SKProduct *product = [store productForIdentifier:productID];
    if ([tableColumn.identifier isEqualToString:@"item"])
    {
        return product ? product.localizedTitle : productID;
    }

    return [NSString stringWithFormat:@"%ld", (long)[self.persistence countProductOfdentifier:productID]];
}


#pragma mark - Table view delegate


- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *table = notification.object;

    if (table.selectedRow >= 0)
    {
        NSString *productID = self.productIdentifiers[table.selectedRow];
        const BOOL consumed = [self.persistence consumeProductOfIdentifier:productID];
        if (consumed)
        {
            [self.tableView reloadData];
        }
    }
}


#pragma mark - RMStoreObserver


- (void)storeProductsRequestFinished:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)storePaymentTransactionFinished:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_productIdentifiers = self->_persistence.purchasedProductIdentifiers.allObjects;
        [self.tableView reloadData];
    });
}


    

@end
