//
//  YFLineChartCommon.m
//  DrawChartTest
//
//  Created by FrankLiu on 16/4/13.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import "YFLineChartCommon.h"
#import <CoreText/CoreText.h>

@implementation YFLineChartCommon

+ (void)drawPoint:(CGContextRef)context point:(CGPoint)point color:(UIColor *)color {

    CGContextSetShouldAntialias(context, YES); // 抗锯齿
    CGColorSpaceRef pointColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, pointColorSpace);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, point.x, point.y);
    CGContextAddArc(context, point.x, point.y, 2, 0, 360, 0);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    CGColorSpaceRelease(pointColorSpace);
}

+ (void)drawLine:(CGContextRef)context
      startPoint:(CGPoint)startPoint
        endPoint:(CGPoint)endPoint
       lineColor:(UIColor *)color {

    CGContextSetShouldAntialias(context, YES); // 抗锯齿
    CGColorSpaceRef lineColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, lineColorSpace);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    CGColorSpaceRelease(lineColorSpace);
}

+ (void)drawText:(CGContextRef)context
            text:(NSString *)text
           point:(CGPoint)point
           color:(UIColor *)color
            font:(UIFont *)font
   textAlignment:(NSTextAlignment)textAlignment {

    [color set];
    
//    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
//    paragraph.alignment     = textAlignment;
//    paragraph.lineBreakMode = NSLineBreakByClipping;
//
//    NSDictionary *dic = @{
//                          NSFontAttributeName           : font,
//                          NSParagraphStyleAttributeName : paragraph
//                          
//                          };
//    CGSize titleSize = [text sizeWithAttributes:dic];
//    CGRect titleRect = CGRectMake(point.x, point.y, titleSize.width, titleSize.height);
//    [text drawInRect:titleRect withAttributes:dic];
    
    CGSize title1Size = [text sizeWithFont:font];
    CGRect titleRect1 = CGRectMake(point.x,
                                   point.y,
                                   title1Size.width,
                                   title1Size.height);
    [text drawInRect:titleRect1 withFont:font lineBreakMode:NSLineBreakByClipping alignment:textAlignment];
}

+ (void)drawText:(CGContextRef)context
            text:(NSString *)text
           color:(UIColor *)color
        fontSize:(CGFloat)fontSize {

    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    CGContextSelectFont(context, font.fontName.UTF8String, fontSize, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGAffineTransform transform = CGAffineTransformMake(1.0, 0, 0, -1.0, 0, 0);
    CGContextSetTextMatrix(context, transform);
    const char * ctext = text.UTF8String;
    CGContextShowTextAtPoint(context, 10, 100, ctext, strlen(ctext));
}

+ (CGPoint)centerPointByPointA:(CGPoint)pointA pointB:(CGPoint)pointB {

    return CGPointMake((pointA.x + pointB.x) / 2, (pointA.y + pointB.y) / 2);
}

@end
