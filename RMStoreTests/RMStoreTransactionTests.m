//
//  RMStoreTransactionTests.m
//  RMStore
//
//  Created by Hermes on 10/17/13.
//  Copyright (c) 2013 Robot Media. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RMStoreTransaction.h"
#import <OCMock/OCMock.h>

@interface RMStoreTransactionTests : XCTestCase

@end

@implementation RMStoreTransactionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)testInitWithPaymentTransaction
{
    SKPaymentTransaction *paymentTransaction = [self mockPaymentTransactionOfProductIdentifer:@"test"];

    RMStoreTransaction *transaction = [[RMStoreTransaction alloc] initWithPaymentTransaction:paymentTransaction];

    SKPayment *payment = paymentTransaction.payment;
    XCTAssertNotNil(transaction, @"");
    XCTAssertEqualObjects(transaction.productIdentifier, payment.productIdentifier, @"");
    XCTAssertEqualObjects(transaction.transactionDate, paymentTransaction.transactionDate, @"");
    XCTAssertEqualObjects(transaction.transactionIdentifier, paymentTransaction.transactionIdentifier, @"");
    
    XCTAssertFalse(transaction.consumed, @"");
}

#pragma mark - NSCoding

- (void)testCoding
{
    RMStoreTransaction *transaction = [[RMStoreTransaction alloc] init];
    transaction.productIdentifier = @"test";
    transaction.transactionDate = [NSDate date];
    transaction.transactionIdentifier = @"transaction";
    
    transaction.consumed = YES;

    NSError *err = nil;

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:transaction requiringSecureCoding:YES error:&err];

    RMStoreTransaction *decodedTransaction = [NSKeyedUnarchiver unarchivedObjectOfClass:[RMStoreTransaction class] fromData:data error:&err];
    
    XCTAssertNotNil(decodedTransaction, @"");
    XCTAssertEqualObjects(decodedTransaction.productIdentifier, transaction.productIdentifier, @"");
    XCTAssertEqualObjects(decodedTransaction.transactionDate, transaction.transactionDate, @"");
    XCTAssertEqualObjects(decodedTransaction.transactionIdentifier, transaction.transactionIdentifier, @"");
    
    XCTAssertEqual(decodedTransaction.consumed, transaction.consumed, @"");
}

#pragma mark - Private

- (SKPaymentTransaction*)mockPaymentTransactionOfProductIdentifer:(NSString*)productIdentifier
{
    id transaction = [OCMockObject mockForClass:[SKPaymentTransaction class]];
    [[[transaction stub] andReturn:[NSDate date]] transactionDate];
    [[[transaction stub] andReturn:@"transaction"] transactionIdentifier];

    id payment = [OCMockObject mockForClass:[SKPayment class]];
    [[[payment stub] andReturn:productIdentifier] productIdentifier];
    [[[transaction stub] andReturn:payment] payment];
    return transaction;
}

@end
