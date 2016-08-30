//
//  ViewController.m
//  DrawChartTest
//
//  Created by FrankLiu on 16/4/13.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import "ViewController.h"
#import "YFLineChartView.h"
#import "YFLineChartModel.h"
#import "UIView+SetRect.h"
#import "GlowPointView.h"
#import "IAPViewController.h"
#import "RechargeVC.h"

@interface ViewController ()

@property (nonatomic, strong) YFLineChartView *m_chartView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:1];
    //  线形图数据
    for (int i = 0 ; i < 51 ;  i++) {
        YFLineChartModel *model = [[YFLineChartModel alloc] initWithX:[NSString stringWithFormat:@"04-%d",(i+1)]
                                                                    Y:@[[NSNumber numberWithDouble:(arc4random() % 1000 + 500) / 1000.f],
                                                                        [NSNumber numberWithDouble:(arc4random() % 1000 + 500) / 1000.f]]];
        
        [dataArray addObject:model];
    }
    //    线形图
    _m_chartView = [[YFLineChartView alloc] initWithFrame:CGRectMake(20, 100, self.view.width - 40, 300)
                                               dataSource:dataArray
                                                    title:@"测试"
                                                   xTitle:@"哈哈"
                                                   yTitle:@"嘿嘿"
                                                   xCount:5
                                                   yCount:5
                                               isNeedGrid: YES];
    
    
    [self.view addSubview:_m_chartView];
    
//    GlowPointView *pointView = [[GlowPointView alloc] initWithFrame:CGRectMake(200, 450, 100, 100)];
//    [self.view addSubview:pointView];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 500, 200, 40)];
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"In App Purchase" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor cyanColor];
    btn.centerX = self.view.centerX;
}

- (void)buttonAction {

    IAPViewController *vc = [IAPViewController new];
    [self.navigationController pushViewController:vc animated:YES];
//    [self presentViewController:vc animated:YES completion:^{
//        
//    }];
    
//    RechargeVC *vc = [RechargeVC new];
//    [self.navigationController pushViewController:vc animated:YES];
}


@end
