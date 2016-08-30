//
//  YFLineChartContentView.m
//  DrawChartTest
//
//  Created by FrankLiu on 16/4/13.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import "YFLineChartContentView.h"
#import "YFLineChartModel.h"
#import "UIView+SetRect.h"
#import "YFLineChartCommon.h"
#import "CGContextObject.h"
#import "CGContextObjectConfig.h"
#import "NSString+HexColors.h"
#import "OnceLinearEquation.h"
#import "NSArray+ReversedArray.h"
#import "UIFont+Fonts.h"
#import "NumberFormatter.h"
#import "GlowPointView.h"

@interface YFLineChartContentView ()<UIGestureRecognizerDelegate>

/**
 *  contextObject对象
 */
@property (nonatomic, strong) CGContextObject     *m_contextObject;

// 数据源
@property (nonatomic, strong) NSArray             *m_dataSource;

// X滚动距离
@property (nonatomic        ) CGFloat             m_XContentScroll;

// X轴显示标签总数
@property (nonatomic        ) NSInteger           m_XLabelCount;

// 当前Y轴刻度总数
@property (nonatomic        ) NSInteger           m_YLabelCount;

// 左边距
@property (nonatomic        ) CGFloat             m_marginLeft;

// 右边距
@property (nonatomic        ) CGFloat             m_marginRight;

// 顶边距
@property (nonatomic        ) CGFloat             m_marginTop;

// 底边距
@property (nonatomic        ) CGFloat             m_marginBottom;

// X平均宽度
@property (nonatomic        ) CGFloat             m_XPerStepWidth;

// Y平均高度
@property (nonatomic        ) CGFloat             m_YPerStepHeight;

// Y最大值
@property (nonatomic        ) double              m_maxY;

// Y最小值
@property (nonatomic        ) double              m_minY;

// Y距离
@property (nonatomic        ) double              m_distanceY;

// 是否需要网格
@property (nonatomic        ) BOOL                m_isNeedGrid;

// 一次线性方程
@property (nonatomic, strong) OnceLinearEquation  *m_equation;

// X轴便签数组
@property (nonatomic, strong) NSMutableArray      *m_xAxisStringArray;

// 滚动倍数
@property (nonatomic        ) int                 m_scrollStepCount;

// 策略类型
@property (nonatomic        ) EStrategyType       m_strategyType;

@property (nonatomic        ) CGPoint             m_previousTranslation;
@property (nonatomic        ) CGPoint             m_previousCrossPoint;

@property (nonatomic        ) BOOL                m_showCrossLine;
@property (nonatomic, strong) GlowPointView      *m_blueStartPoint;
@property (nonatomic, strong) GlowPointView      *m_redStartPoint;
@property (nonatomic, strong) UIBezierPath       *m_blueGradientPath;
@property (nonatomic, strong) UIBezierPath       *m_redGradientPath;

@end

@implementation YFLineChartContentView


- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(NSArray *)dataSource
                       xCount:(NSInteger)xCount
                       yCount:(NSInteger)yCount
                   isNeedGrid:(BOOL)needGrid
                         type:(EStrategyType)type {

    if (self = [super initWithFrame:frame]) {
        
        self.m_marginLeft   = 40.f;
        self.m_marginRight  = 15.f;
        self.m_marginTop    = 15.f;
        self.m_marginBottom = 30.f;
        
        self.backgroundColor    = [UIColor clearColor];
        self.m_dataSource       = dataSource;
        self.m_XLabelCount      = xCount;                  // X轴显示标签总数
        self.m_YLabelCount      = yCount;                  // 当前Y轴刻度总数
        self.m_isNeedGrid       = needGrid;
        self.m_strategyType     = type;
        self.m_xAxisStringArray = [NSMutableArray array];
        
        NSAssert(xCount % 2, @"X轴标签数应该为奇数");
        NSAssert(yCount % 2, @"Y轴便签数应该为奇数");
        
        self.m_previousTranslation = CGPointZero;
        self.m_previousCrossPoint  = CGPointZero;
        self.m_showCrossLine       = NO;
        
        self.m_blueStartPoint = [[GlowPointView alloc] initWithFrame:CGRectMake(0, 0, 5, 5) color:[UIColor blueColor]];
        [self addSubview:self.m_blueStartPoint];
        self.m_blueStartPoint.hidden = YES;
        
        self.m_redStartPoint = [[GlowPointView alloc] initWithFrame:CGRectMake(0, 0, 5, 5) color:[UIColor redColor]];
        [self addSubview:self.m_redStartPoint];
        self.m_redStartPoint.hidden = YES;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPress];
        
        [self calculateYAxisDistance];
    }
    
    return self;
}

// 计算Y轴间距
- (void)calculateYAxisDistance {

    double maxDistance = 0;
    
    // 取出最大间距值
    for (YFLineChartModel *model in self.m_dataSource) {
        
        for (NSNumber *value in model.m_valuesY) {
            
            double yValue = value.doubleValue;
            double distance = fabs(yValue - 1);
            
            if (distance > maxDistance) {
                
                maxDistance = distance;
            }
        }
    }
    
    // 加0.2倍的冗余
    maxDistance *= 1.2;
    
    MATHPoint topPoint    = MATHPointMake(self.m_marginTop,                 1 + maxDistance);
    MATHPoint bottomPoint = MATHPointMake(self.height - self.m_marginBottom,1 - maxDistance);
    
    self.m_equation = [OnceLinearEquation onceLinearEquationWithPointA:topPoint PointB:bottomPoint];
    
    self.m_distanceY = maxDistance / ((self.m_YLabelCount - 1) / 2);
    
    self.m_minY = 1 - maxDistance;
    
    self.m_YPerStepHeight = (self.height - self.m_marginBottom - self.m_marginTop) / (self.m_YLabelCount - 1);
    
    if (self.m_strategyType == kIMPStrategyType) {
        
        self.m_XPerStepWidth = (self.width - self.m_marginLeft - self.m_marginRight) / (23 - 1);
   
    } else if (self.m_strategyType == kISMStrategyType) {
    
        self.m_XPerStepWidth = (self.width - self.m_marginLeft - self.m_marginRight) / (7 - 1);
    }
}

- (void)drawRect:(CGRect)rect {
    
    self.m_contextObject = [[CGContextObject alloc] initWithCGContext:UIGraphicsGetCurrentContext()
                                                               config:[CGContextObjectConfig new]];
    [self drawCoordinateSystem];
    [self drawXAxisDescription];
    [self drawYAxisDescription];
    [self drawCurve:kIMPStrategyType];
}

#pragma mark - 绘制坐标系表格
- (void)drawCoordinateSystem {

    // 绘制实线
    {
    
        CGContextObjectConfig *config = [CGContextObjectConfig new];
        config.lineWidth              = 1.f;
        config.strokeColor            = [RGBColor colorWithUIColor:[@"#F8F8F8" hexColor]];
        
        CGFloat currentOffsetX = 0;
        
        if (self.m_isNeedGrid) {
            
            while (currentOffsetX <= self.width - self.m_marginLeft - self.m_marginRight) {
                
                [self.m_contextObject contextConfig:config drawStrokeBlock:^(CGContextObject *contextObject) {
                    
                    [contextObject moveToStartPoint:CGPointMake(currentOffsetX + self.m_marginLeft, self.m_marginTop)];
                    [contextObject addLineToPoint:CGPointMake(currentOffsetX + self.m_marginLeft, self.height - self.m_marginBottom)];
                }];
                
                if (self.m_strategyType == kIMPStrategyType) {
                    
                    currentOffsetX += (self.width - self.m_marginLeft - self.m_marginRight) / (23 - 1);
                    
                } else if (self.m_strategyType == kISMStrategyType) {
                
                
                    currentOffsetX += (self.width - self.m_marginLeft - self.m_marginRight) / (7 - 1);
                }
                
                
            }
            
        } else {
            
            [self.m_contextObject contextConfig:config drawStrokeBlock:^(CGContextObject *contextObject) {
                
                [contextObject moveToStartPoint:CGPointMake(self.m_marginLeft, self.m_marginTop)];
                [contextObject addLineToPoint:CGPointMake(self.m_marginLeft, self.height - self.m_marginBottom)];
                
                [contextObject moveToStartPoint:CGPointMake(self.width - self.m_marginRight, self.m_marginTop)];
                [contextObject addLineToPoint:CGPointMake(self.width - self.m_marginRight, self.height - self.m_marginBottom)];
            }];
        }
    }
    
    // 绘制虚线
    {
    
        CGFloat lengths[] = {2, 2};
        CGContextObjectConfig *config = [CGContextObjectConfig new];
        config.lineWidth              = 0.5f;
        config.lengths                = lengths;
        config.phase                  = 0;
        config.count                  = 2;
        config.strokeColor            = [RGBColor colorWithUIColor:[@"#999999" hexColor]];
        
        if (self.m_isNeedGrid) {
            
            NSInteger dashLineCount = self.m_YLabelCount - 1;
            CGFloat tmpDownGap      = (self.height - self.m_marginBottom - self.m_marginTop) / (CGFloat)(dashLineCount);
            
            for (int i = 0; i <= dashLineCount; i++) {
                
                [self.m_contextObject contextConfig:config drawStrokeBlock:^(CGContextObject *contextObject) {
                    
                    [contextObject moveToStartPoint:CGPointMake(self.m_marginLeft,             self.m_marginTop + tmpDownGap * i)];
                    [contextObject addLineToPoint:CGPointMake(self.width - self.m_marginRight, self.m_marginTop + tmpDownGap * i)];
                }];
            }
            
        } else {
            
            [self.m_contextObject contextConfig:config drawStrokeBlock:^(CGContextObject *contextObject) {
                
                [contextObject moveToStartPoint:CGPointMake(self.m_marginLeft,             self.m_marginTop)];
                [contextObject addLineToPoint:CGPointMake(self.width - self.m_marginRight, self.m_marginTop)];
                
                [contextObject moveToStartPoint:CGPointMake(self.m_marginLeft,             self.height - self.m_marginBottom)];
                [contextObject addLineToPoint:CGPointMake(self.width - self.m_marginRight, self.height - self.m_marginBottom)];
            }];
        }
    }
}

#pragma mark - 绘制横坐标标签(日期)
- (void)drawXAxisDescription {
    
    int arrayCount = (int)self.m_dataSource.count;
    
    if (self.m_strategyType == kIMPStrategyType) {
        
        if (arrayCount >= 23) {
            
            NSMutableArray *stringArray = [NSMutableArray array];
            
            [stringArray addObject:self.m_dataSource[arrayCount - 1 - self.m_scrollStepCount]];
            [stringArray addObject:self.m_dataSource[arrayCount - 8 - self.m_scrollStepCount]];
            [stringArray addObject:self.m_dataSource[arrayCount - 13 - self.m_scrollStepCount]];
            [stringArray addObject:self.m_dataSource[arrayCount - 18 - self.m_scrollStepCount]];
            [stringArray addObject:self.m_dataSource[arrayCount - 23 - self.m_scrollStepCount]];
            
            self.m_xAxisStringArray = [[stringArray reversedArray] mutableCopy];
        
        } else if (arrayCount >= 16) {
        
            [self.m_xAxisStringArray addObject:self.m_dataSource[0]];
            [self.m_xAxisStringArray addObject:self.m_dataSource[5]];
            [self.m_xAxisStringArray addObject:self.m_dataSource[10]];
            [self.m_xAxisStringArray addObject:self.m_dataSource[15]];
        
        } else if (arrayCount >= 11) {
        
            [self.m_xAxisStringArray addObject:self.m_dataSource[0]];
            [self.m_xAxisStringArray addObject:self.m_dataSource[5]];
            [self.m_xAxisStringArray addObject:self.m_dataSource[10]];
        
        } else if (arrayCount >= 6) {
        
            [self.m_xAxisStringArray addObject:self.m_dataSource[0]];
            [self.m_xAxisStringArray addObject:self.m_dataSource[5]];
        
        } else {
        
           [self.m_xAxisStringArray addObject:self.m_dataSource[0]]; 
        }
        
    } else if (self.m_strategyType == kISMStrategyType) {
    
        
    }
    
    NSMutableDictionary *attributeDic = [NSMutableDictionary new];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    attributeDic[NSForegroundColorAttributeName] = [@"#777777" hexColor];
    attributeDic[NSFontAttributeName]            = [UIFont HeitiSCWithFontSize:8];
    attributeDic[NSParagraphStyleAttributeName]  = paragraphStyle;
    
    for (int i = 0; i < self.m_xAxisStringArray.count; ++i) {
        
        YFLineChartModel *model = self.m_xAxisStringArray[i];
        
        switch (i) {
                
            case 0:
            case 1:
            case 2:
            case 3:
                
                [self.m_contextObject drawString:model.m_valueX
                                         atPoint:CGPointMake(self.m_marginLeft - 10 + i * 5 * self.m_XPerStepWidth , self.height - self.m_marginBottom + 10)
                                  withAttributes:attributeDic];
                
                break;
                
            case 4:
                
                [self.m_contextObject drawString:model.m_valueX
                                         atPoint:CGPointMake(self.m_marginLeft - 10 + (23 - 1) * self.m_XPerStepWidth, self.height - self.m_marginBottom + 10)
                                  withAttributes:attributeDic];
                
                break;
                
                
            default:
                break;
        }
    }
}

#pragma mark - 绘制纵坐标标签(净值)
- (void)drawYAxisDescription {
    
    NSMutableDictionary *attributeDic = [NSMutableDictionary new];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    attributeDic[NSForegroundColorAttributeName] = [@"#777777" hexColor];
    attributeDic[NSFontAttributeName]            = [UIFont HeitiSCWithFontSize:8];
    attributeDic[NSParagraphStyleAttributeName]  = paragraphStyle;
    
    for (int i = 0; i < self.m_YLabelCount; ++i) {
        
        double value = (self.m_minY + i * self.m_distanceY);
        
        CGRect cubeRect = CGRectMake(5, self.height - self.m_marginBottom - 6 - i * self.m_YPerStepHeight, self.m_marginLeft - 5, 20);
        
        [self.m_contextObject drawString:[NSString stringWithFormat:@"%.4f",value] inRect:cubeRect withAttributes:attributeDic];
    }
}

#pragma mark - 绘制曲线
- (void)drawCurve:(EStrategyType)type {
    
    NSArray *reverseArray = [self.m_dataSource reversedArray];

    if (type == kIMPStrategyType) {
        
        int arrayCount = (int)reverseArray.count;
        
        if (arrayCount >= 23) {
            
            self.m_redGradientPath  = [UIBezierPath bezierPath];
            self.m_blueGradientPath = [UIBezierPath bezierPath];
            
            NSMutableArray *previousPointArray = [NSMutableArray array];
            
            int count = 0;
            int first = 0;
            
            for (int i = 0; i < arrayCount; ++i) {
                
                YFLineChartModel *model = reverseArray[i];
                
                // 曲线共用的X坐标
                double x = self.m_marginLeft + (22 - i) * self.m_XPerStepWidth + self.m_XContentScroll;
                
                if (x < self.m_marginLeft - self.m_XPerStepWidth || x > self.m_marginLeft + 22 * self.m_XPerStepWidth) {
                    
                    if (x > self.m_marginLeft + 22 * self.m_XPerStepWidth) {
                        
                        [previousPointArray removeAllObjects];
                        
                        for (int j = 0; j < model.m_valuesY.count; ++j) {
                            
                            double yValue = [model.m_valuesY[j] doubleValue];
                            
                            // 取出Y的高度
                            double y = [self.m_equation xValueWhenYEqual:yValue];
                            
                            NSMutableDictionary *currentPointDic  = [NSMutableDictionary dictionary];
                            
                            [currentPointDic setObject:[NSNumber numberWithDouble:x] forKey:@"x"];
                            [currentPointDic setObject:[NSNumber numberWithDouble:y] forKey:@"y"];
                            
                            [previousPointArray addObject:currentPointDic];
                            
                            self.m_blueStartPoint.hidden = YES;
                            self.m_redStartPoint.hidden  = YES;
                            
                        }
                        
                    }
                    
                    continue;
                    
                } else {
                    
                    for (int j = 0; j < model.m_valuesY.count; ++j) {
                        
                        double yValue = [model.m_valuesY[j] doubleValue];
                        
                        // 取出Y的高度
                        double y = [self.m_equation xValueWhenYEqual:yValue];
                        
                        // 两点连线需要前一个点,所以,需要存储前一个点,存储从i=0开始,后面的更新就好
                        if (i == 0) {
                            
                            NSMutableDictionary *currentPointDic  = [NSMutableDictionary dictionary];
                            
                            [currentPointDic setObject:[NSNumber numberWithDouble:x] forKey:@"x"];
                            [currentPointDic setObject:[NSNumber numberWithDouble:y] forKey:@"y"];
                            
                            [previousPointArray addObject:currentPointDic];
                            
                            if (j == 0) {
                                
                                [self.m_redGradientPath moveToPoint:CGPointMake(x , self.height - self.m_marginBottom)];
                                
                                [self.m_redGradientPath addLineToPoint:CGPointMake(x, y)];
                                
                            } else {
                                
                                
                                
                                [self.m_blueGradientPath moveToPoint:CGPointMake(x , self.height - self.m_marginBottom)];
                                
                                [self.m_blueGradientPath addLineToPoint:CGPointMake(x, y)];
                            }
                            
                        } else {
                            
                            NSMutableDictionary *previousDic = [previousPointArray objectAtIndex:j];
                            
                            double previousX = [previousDic[@"x"] doubleValue];
                            double previousY = [previousDic[@"y"] doubleValue];
                            
                            [previousDic setObject:[NSNumber numberWithDouble:x] forKey:@"x"];
                            [previousDic setObject:[NSNumber numberWithDouble:y] forKey:@"y"];
                            
                            CGPoint startPoint = CGPointMake(previousX, previousY);
                            CGPoint endPoint   = CGPointMake(x, y);
                            
                            MATHPoint pointA = MATHPointMake(previousX, previousY);
                            MATHPoint pointB = MATHPointMake(x, y);
                            
                            OnceLinearEquation *equation = [OnceLinearEquation onceLinearEquationWithPointA:pointA PointB:pointB];
                            
                            double zeroY = [equation yValueWhenXEqual:self.m_marginLeft];
                            double lastY = [equation yValueWhenXEqual:self.m_marginLeft + 22 * self.m_XPerStepWidth];
                            
                            // 当向右滑动,最左边的点,addLineToPoint时,应该用Y轴上的点,否则连线斜率不对
                            if (x >= self.m_marginLeft - self.m_XPerStepWidth && x < self.m_marginLeft) {
                                
                                endPoint = CGPointMake(self.m_marginLeft, zeroY);
                            }
                            
                            if (x > self.m_marginLeft + 21 * self.m_XPerStepWidth && x <= self.m_marginLeft + 22 * self.m_XPerStepWidth ) {
                                
                                startPoint = CGPointMake(self.m_marginLeft + 22 * self.m_XPerStepWidth, lastY);
                                
                                if (j == 0) {
                                    
                                    [self.m_redGradientPath moveToPoint:CGPointMake(self.m_marginLeft + 22 * self.m_XPerStepWidth , self.height - self.m_marginBottom)];
                                    
                                    [self.m_redGradientPath addLineToPoint:startPoint];
                                    
                                } else {
                                    
                                    
                                    
                                    [self.m_blueGradientPath moveToPoint:CGPointMake(self.m_marginLeft + 22 * self.m_XPerStepWidth , self.height - self.m_marginBottom)];
                                    
                                    [self.m_blueGradientPath addLineToPoint:startPoint];
                                }
                                
                            }
                            
                            CGContextObjectConfig *config = [CGContextObjectConfig new];
                            config.lineWidth              = 1.f;
                            
                            if (j == 0) {
                                
                                config.strokeColor = [RGBColor colorWithUIColor:[@"#FD762D" hexColor]];
                            
                            } else {
                            
                                config.strokeColor = [RGBColor colorWithUIColor:[@"#56A4E9" hexColor]];
                            }
                            
                            [self.m_contextObject contextConfig:config drawStrokeBlock:^(CGContextObject *contextObject) {
                                
                                [contextObject moveToStartPoint:startPoint];
                                [contextObject addLineToPoint:endPoint];
                            }];
                            
                            // 用double类型来比较会出错,转成string类型
                            NSString *lastYStr    = [NSString stringWithFormat:@"%.5f",lastY];
                            NSString *previousStr = [NSString stringWithFormat:@"%.5f",previousY];
                            NSString *zeroYStr    = [NSString stringWithFormat:@"%.5f",zeroY];
                            NSString *yStr        = [NSString stringWithFormat:@"%.5f",y];
                            
                            if (i == 1) {
                                
                                if ([lastYStr isEqualToString:previousStr]) {
                                    
                                    if (j == 0) {
                                        
//                                        [YFLineChartCommon drawPoint:self.m_contextObject.context point:startPoint color:[UIColor redColor]];
                                        self.m_redStartPoint.center = startPoint;
                                        self.m_redStartPoint.hidden = NO;
                                        
                                    } else {
                                        
                                        //                                    [YFLineChartCommon drawPoint:self.m_contextObject.context point:startPoint color:[UIColor blueColor]];
                                        self.m_blueStartPoint.center = startPoint;
                                        self.m_blueStartPoint.hidden = NO;
                                    }
                                    
                                } else {
                                    
                                    self.m_blueStartPoint.hidden = YES;
                                    self.m_redStartPoint.hidden  = YES;
                                }
                                
                                
                                
                            } else if (i == arrayCount - 1 && [yStr isEqualToString:zeroYStr]) {
                            
                                if (j == 0) {
                                    
                                    [YFLineChartCommon drawPoint:self.m_contextObject.context point:endPoint color:[UIColor redColor]];
                                    
                                } else {
                                    
                                    [YFLineChartCommon drawPoint:self.m_contextObject.context point:endPoint color:[UIColor blueColor]];
                                }
                            }
                            
                            if (j == 0) {
                                
                                [self.m_redGradientPath addLineToPoint:endPoint];
                                
                            } else {
                                
                                
                                
                                [self.m_blueGradientPath addLineToPoint:endPoint];
                            }
                            
                            if (j == 0) {
                                
                                count++;
                                
                            }
                            
                            if (count >= 23 && first < 2 ) {
                                
                                first++;
                                
                                //画渐变
                                UIColor *lineStartColor = nil;
                                UIColor *lineEndColor   = nil;
                                
                                if (j == 0) {
                                    
                                    lineStartColor = [UIColor colorWithRed:248/255.f green:169/255.f blue:127/255.f alpha:0.35];
                                    lineEndColor   = [UIColor clearColor];
                                    
                                    [self.m_redGradientPath addLineToPoint:CGPointMake(endPoint.x , self.height - self.m_marginBottom)];
                                    [self.m_redGradientPath closePath];
                                    
                                    [self drawLinerGradient:self.m_contextObject.context path:self.m_redGradientPath.CGPath startColor:[lineStartColor CGColor] endColor:[lineEndColor CGColor]];
                                    
                                    
                                } else {
                                    
                                    
                                    
                                    lineStartColor = [UIColor colorWithRed:161/255.f green:205/255.f blue:243/255.f alpha:0.35];
                                    lineEndColor   = [UIColor clearColor];
                                    
                                    
                                    [self.m_blueGradientPath addLineToPoint:CGPointMake(endPoint.x , self.height - self.m_marginBottom)];
                                    [self.m_blueGradientPath closePath];
                                    
                                    [self drawLinerGradient:self.m_contextObject.context path:self.m_blueGradientPath.CGPath startColor:[lineStartColor CGColor] endColor:[lineEndColor CGColor]];
                                    
                                }
                                
                                
                            }
                            
                            if (_m_showCrossLine) {
                                
                                CGFloat crossX = self.m_previousCrossPoint.x;
                                
                                if (crossX >= x && crossX <= previousX && crossX > self.m_marginLeft && crossX < self.width - self.m_marginRight) {
                                    
                                    if (j == 0) {
                                        
                                        double crossY = [equation yValueWhenXEqual:crossX];
                                        [self drawCrossLine:CGPointMake(crossX, crossY)];
                                    }
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
            self.m_redGradientPath  = nil;
            self.m_blueGradientPath = nil;
            
        } else {
            
            
        }
        
    } else if (type == kISMStrategyType) {
        
        
    }
}

#pragma mark - 绘制十字线
- (void)drawCrossLine:(CGPoint)point {

    CGFloat lengths[] = {2, 2};
    CGContextObjectConfig *config = [CGContextObjectConfig new];
    config.lineWidth              = 0.5f;
    config.lengths                = lengths;
    config.phase                  = 0;
    config.count                  = 2;
    config.strokeColor            = [RGBColor colorWithUIColor:[UIColor redColor]];
    
    [self.m_contextObject contextConfig:config drawStrokeBlock:^(CGContextObject *contextObject) {
        
        [contextObject moveToStartPoint:CGPointMake(self.m_marginLeft,             point.y)];
        [contextObject addLineToPoint:CGPointMake(self.width - self.m_marginRight, point.y)];
        
        [contextObject moveToStartPoint:CGPointMake(point.x,             self.m_marginTop)];
        [contextObject addLineToPoint:CGPointMake(point.x, self.height - self.m_marginBottom)];
    }];
}

- (void)drawLinerGradient: (CGContextRef)context path: (CGPathRef)path startColor: (CGColorRef)startColor endColor: (CGColorRef)endColor {

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat location[] = {0.0, 1.0};
    
    NSArray *colorsArray = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorsArray, location);
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    
    // 具体方向可根据需求
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint   = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

-(void)refreshData:(NSArray *)dataSource{
    self.m_dataSource  = dataSource;
    
    [self setNeedsLayout];
}

- (void)handlePan:(UIPanGestureRecognizer*)pan {

    switch (pan.state) {
            
        case UIGestureRecognizerStateChanged: {
        
            CGPoint translation = [pan translationInView:self];
            
            CGFloat translationX = translation.x;
            
            CGFloat diff         = translationX - self.m_previousTranslation.x;
            
            self.m_XContentScroll += diff;
            
            self.m_previousTranslation = translation;
            
            if (self.m_XContentScroll < 0) {
                
                self.m_XContentScroll = 0;
            }
            
            if (self.m_XContentScroll > (self.m_XPerStepWidth * (self.m_dataSource.count - 1) - self.width + self.m_marginLeft + self.m_marginRight)) {
                
                self.m_XContentScroll = self.m_XPerStepWidth * (self.m_dataSource.count - 1) - self.width + self.m_marginLeft + self.m_marginRight;
            }
            
            int times = [[NumberFormatter normalStyleWithValue:self.m_XContentScroll / self.m_XPerStepWidth
                                         maximumFractionDigits:0
                                         minimumFractionDigits:0
                                                  roundingMode:NSNumberFormatterRoundHalfUp] intValue];
            
            self.m_scrollStepCount = times;
            
            [self setNeedsDisplay];
            
        }
            
            break;
            
        case UIGestureRecognizerStateEnded: {
        
            int times = [[NumberFormatter normalStyleWithValue:self.m_XContentScroll / self.m_XPerStepWidth
                                         maximumFractionDigits:0
                                         minimumFractionDigits:0
                                                  roundingMode:NSNumberFormatterRoundHalfUp] intValue];
            
            self.m_scrollStepCount = times;
            
            self.m_XContentScroll = times * self.m_XPerStepWidth;
            
            [self setNeedsDisplay];
            
            self.m_previousTranslation = CGPointZero;
        }
            break;
            
        default:
            break;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)longPress {

    switch (longPress.state) {
            
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
        
            self.m_previousCrossPoint = [longPress locationInView:self];
            
            self.m_showCrossLine = YES;
            [self setNeedsDisplay];
        }
            
            break;
            
        case UIGestureRecognizerStateEnded: {
        
            self.m_showCrossLine      = NO;
            self.m_previousCrossPoint = CGPointZero;
            [self setNeedsDisplay];
        }
            break;
            
        default:
            break;
    }
}

@end
