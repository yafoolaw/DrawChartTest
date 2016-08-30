//
//  YFLineChartModel.m
//  DrawChartTest
//
//  Created by FrankLiu on 16/4/13.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import "YFLineChartModel.h"

@implementation YFLineChartModel

- (instancetype)initWithX: (NSString*)valueX Y: (NSArray*)valuesY {

    if (self = [super init]) {
        
        self.m_valueX  = valueX;
        self.m_valuesY = valuesY;
    }
    
    return self;
}

@end
