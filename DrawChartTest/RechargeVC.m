//
//  RechargeVC.m
//  DrawChartTest
//
//  Created by FrankLiu on 16/7/7.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import "RechargeVC.h"

//在内购项目中创的商品单号
#define ProductID_IAP0p20    @"FrankLiu.DrawChartTest.coin1"   
#define ProductID_IAP1p100   @"FrankLiu.DrawChartTest.coin2"
#define ProductID_IAP4p600   @"FrankLiu.DrawChartTest.temp1"
#define ProductID_IAP9p1000  @"FrankLiu.DrawChartTest.freevip"
#define ProductID_IAP24p6000 @"FrankLiu.DrawChartTest.level101"
#define ProductID_IAP24p1    @"FrankLiu.DrawChartTest.vip1"
#define ProductID_IAP24p2    @"FrankLiu.DrawChartTest.vip2"

@interface RechargeVC ()

@end

@implementation RechargeVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self buy:IAP0p20];
    
}

-(void)buy:(int)type {
    buyType = type;
    if ([SKPaymentQueue canMakePayments]) {
        
        [self RequestProductData];
        NSLog(@"允许程序内付费购买");
        
    } else {
        NSLog(@"不允许程序内付费购买");
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您的手机没有打开程序内付费购买"
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
        
        [alerView show];
        
    }
}

-(void)RequestProductData {
    NSLog(@"---------请求对应的产品信息------------");
    NSArray *product = nil;
    switch (buyType) {
        case IAP0p20:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP0p20,ProductID_IAP1p100,ProductID_IAP4p600,ProductID_IAP9p1000,ProductID_IAP24p6000,ProductID_IAP24p1,ProductID_IAP24p2,nil];
            break;
        case IAP1p100:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP1p100,nil];
            break;
        case IAP4p600:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP4p600,nil];
            break;
        case IAP9p1000:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP9p1000,nil];
            break;
        case IAP24p6000:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP24p6000,nil];
            break;
            
        default:
            break;
    }
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
    
    SKReceiptRefreshRequest *receiptRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:@{
                                                                                                          SKReceiptPropertyIsExpired:@0}];
    receiptRequest.delegate = self;
//    [receiptRequest start];
    
}

//<SKProductsRequestDelegate> 请求协议
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", (int)[myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
    }
    SKPayment *payment = nil;
    switch (buyType) {
        case IAP0p20:
            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP0p20];    //支付25
            break;
        case IAP1p100:
            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP1p100];    //支付108
            break;
        case IAP4p600:
            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP4p600];    //支付618
            break;
        case IAP9p1000:
            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP9p1000];    //支付1048
            break;
        case IAP24p6000:
            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP24p6000];    //支付5898
            break;
        default:
            break;
    }
    NSLog(@"---------发送购买请求------------");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
//    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}

#pragma mark - SKRequestDelegate
//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"-------弹出错误信息----------");
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",NULL) message:[error localizedDescription]
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
    [alerView show];
    
}


-(void) requestDidFinish:(SKRequest *)request {
    NSLog(@"----------反馈信息结束--------------");
//    NSLog(@"??????????%@",((SKReceiptRefreshRequest*)request).receiptProperties);
    
}

//交易结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions) {
        
        SKPaymentTransaction *a = transaction.originalTransaction;
        
        NSLog(@"1111111%@",transaction);
        NSLog(@"2222222%@",a);
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:{//交易完成
                [self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
                
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"购买成功"
                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
                
                [alerView show];
                
            } break;
            case SKPaymentTransactionStateFailed://交易失败
            { [self failedTransaction:transaction];
                NSLog(@"-----交易失败 --------");
                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                                     message:@"购买失败，请重新尝试购买"
                                                                    delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
                
                [alerView2 show];
                
            }break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                NSLog(@"-----已经购买过该商品 --------");
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"-----商品添加进列表 --------");
                break;
            default:
                break;
        }
    }
}
- (void)completeTransaction: (SKPaymentTransaction *)transaction {
    
    NSLog(@"-----completeTransaction--------");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    
    // Remove the transaction from the payment queue.
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

//记录交易
-(void)recordTransaction:(NSString *)product{
    NSLog(@"-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)product{
    NSLog(@"-----下载--------");
}

-(void)failedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"失败");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
  
    if (queue.transactions.count) {
        
        SKPaymentTransaction *transaction = queue.transactions[0];
        
        NSLog(@"!!!!!!!%@---%@",transaction.transactionIdentifier,transaction.transactionDate);
    }

}

-(void)restoreTransaction: (SKPaymentTransaction *)transaction {
    
    NSLog(@" 交易恢复处理");
     [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

-(void)paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"-------paymentQueue----");
}

-(void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
    
}

@end
