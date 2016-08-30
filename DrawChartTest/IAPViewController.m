//
//  IAPViewController.m
//  DrawChartTest
//
//  Created by FrankLiu on 16/7/6.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import "IAPViewController.h"
#import "UIView+SetRect.h"
#import "WxHxD.h"
#import "IAPTableViewCell.h"
#import "IAPHelper.h"
#import "DrawChartProduct.h"

@interface IAPViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView    *m_tableView;
@property (nonatomic, strong) NSMutableArray *m_productArray;
@property (nonatomic, strong) IAPHelper      *m_iapHelper;

@end

@implementation IAPViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.m_iapHelper = [IAPHelper new];
    
    self.m_tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.m_tableView];
    
    self.m_tableView.delegate   = self;
    self.m_tableView.dataSource = self;
    
    [self.m_tableView registerClass:[IAPTableViewCell class] forCellReuseIdentifier:IAPCellIdentifier];
    
    [self loadData];
}

- (void)loadData {

    if ([self.m_iapHelper canMakePayments]) {
        
        DrawChartProduct *product1 = [DrawChartProduct new];
        
        product1.m_buyType = kCoin1;
        product1.m_productTip = @"1元=1000金币";
        
        DrawChartProduct *product2 = [DrawChartProduct new];
        
        product2.m_buyType = kCoin2;
        product2.m_productTip = @"7天试用";
        
        DrawChartProduct *product3 = [DrawChartProduct new];
        
        product3.m_buyType = kTemp1;
        product3.m_productTip = @"8元=10000金币";
        
        DrawChartProduct *product4 = [DrawChartProduct new];
        
        product4.m_buyType = kFreeVIP;
        product4.m_productTip = @"免费会员";
        
        DrawChartProduct *product5 = [DrawChartProduct new];
        
        product5.m_buyType = kLevel101;
        product5.m_productTip = @"杂志会员";
        
        DrawChartProduct *product6 = [DrawChartProduct new];
        
        product6.m_buyType = kVIP1;
        product6.m_productTip = @"杂志会员2";
        
        DrawChartProduct *product7 = [DrawChartProduct new];
        
        product7.m_buyType = kVIP2;
        product7.m_productTip = @"第101关";
        
        self.m_productArray = [NSMutableArray arrayWithObjects:product1,product2,product3,product4,product5,product6,product7, nil];
        [self.m_tableView reloadData];
        
    } else {
        
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您的手机没有打开程序内付费购买"
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
        
        [alerView show];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.m_productArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    IAPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IAPCellIdentifier];
    
    DrawChartProduct *product = self.m_productArray[indexPath.row];
    
    cell.textLabel.text = product.m_productTip;
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    DrawChartProduct *product = self.m_productArray[indexPath.row];
    
    self.m_iapHelper.m_buyType = product.m_buyType;
    
    [self.m_iapHelper requestProducts];
}

@end
