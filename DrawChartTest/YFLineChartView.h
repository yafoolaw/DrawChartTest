//
//  YFLineChartView.h
//  DrawChartTest
//
//  Created by FrankLiu on 16/4/13.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YFLineChartView : UIView

/**
 * 初始化
 * title  : 图表名
 * xTitle : X轴名称
 * yTitle : Y轴名称
 * xCount : x显示数量
 * yCount : Y显示数量
 */
-(id)initWithFrame:(CGRect)frame dataSource:(NSArray*)dataSource title:(NSString *)title xTitle:(NSString*)xTitle yTitle:(NSString*)yTitle xCount:(NSInteger)xCount yCount:(NSInteger)yCount isNeedGrid:(BOOL)needGrid;

/*
 *刷新数据源
 */
-(void)refreshData:(NSArray*)dataSource;

@end
