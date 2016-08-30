//
//  RechargeVC.h
//  DrawChartTest
//
//  Created by FrankLiu on 16/7/7.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
@import StoreKit;

enum{
    IAP0p20=20,
    IAP1p100,
    IAP4p600,
    IAP9p1000,
    IAP24p6000,
}buyCoinsTag;

//代理
@interface RechargeVC : UIViewController <SKPaymentTransactionObserver,SKProductsRequestDelegate >

{
    int buyType;
}

-(void)RequestProductData;

-(void)buy:(int)type;

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

-(void)completeTransaction: (SKPaymentTransaction *)transaction;

-(void)failedTransaction: (SKPaymentTransaction *)transaction;

-(void)paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;

-(void)paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;

-(void)restoreTransaction: (SKPaymentTransaction *)transaction;

-(void)provideContent:(NSString *)product;

-(void)recordTransaction:(NSString *)product;

@end
