//
//  NSArray+ReversedArray.m
//  ZiPeiYi
//
//  Created by FrankLiu on 16/2/18.
//  Copyright © 2016年 YouXianMing. All rights reserved.
//

#import "NSArray+ReversedArray.h"

@implementation NSArray (ReversedArray)

- (NSArray*)reversedArray {

    if (self == nil || self.count == 0) {
        
        return self;
    }
    
    NSMutableArray *reversedArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (int i = (int)self.count - 1; i >= 0; --i) {
        
        [reversedArray addObject:[self objectAtIndex:i]];
    }
    
    return reversedArray;
}

@end
