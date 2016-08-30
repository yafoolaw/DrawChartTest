//
//  YFLineChartModel.h
//  DrawChartTest
//
//  Created by FrankLiu on 16/4/13.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YFLineChartModel : NSObject

@property (nonatomic, strong) NSString *m_valueX;
@property (nonatomic ,strong) NSArray  *m_valuesY;

- (instancetype)initWithX: (NSString*)valueX Y: (NSArray*)valuesY;

@end
