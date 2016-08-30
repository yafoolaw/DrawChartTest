//
//  YFLineChartCommon.h
//  DrawChartTest
//
//  Created by FrankLiu on 16/4/13.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YFLineChartCommon : NSObject

+ (void)drawPoint:(CGContextRef)context point:(CGPoint)point color:(UIColor*)color;

+ (void)drawLine: (CGContextRef)context
      startPoint: (CGPoint)startPoint
        endPoint: (CGPoint)endPoint
       lineColor: (UIColor*)color;

+ (void)drawText: (CGContextRef)context
            text: (NSString*)text
           point: (CGPoint)point
           color: (UIColor*)color
            font: (UIFont*)font
   textAlignment: (NSTextAlignment)textAlignment;

+ (void)drawText: (CGContextRef)context
            text: (NSString*)text
           color: (UIColor*)color
        fontSize: (CGFloat)fontSize;

+ (CGPoint)centerPointByPointA: (CGPoint)pointA pointB: (CGPoint)pointB;

@end
