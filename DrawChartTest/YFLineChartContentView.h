//
//  YFLineChartContentView.h
//  DrawChartTest
//
//  Created by FrankLiu on 16/4/13.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    
    kIMPStrategyType,
    kISMStrategyType,
    
} EStrategyType;

@interface YFLineChartContentView : UIView

/*
 *  构造函数，必须使用
 */
-(id)initWithFrame:(CGRect)frame
        dataSource:(NSArray *)dataSource
            xCount:(NSInteger)xCount
            yCount:(NSInteger)yCount
        isNeedGrid:(BOOL)needGrid
              type:(EStrategyType)type;

/*
 *  刷新数据源
 */
-(void)refreshData:(NSArray*)dataSource;

@end
