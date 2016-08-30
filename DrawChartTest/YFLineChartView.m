//
//  YFLineChartView.m
//  DrawChartTest
//
//  Created by FrankLiu on 16/4/13.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#if !__has_feature(objc_arc)
#error "This source file must be compiled with ARC enabled!"
#endif

#import "YFLineChartView.h"
#import "YFLineChartContentView.h"
#import "YFLineChartCommon.h"

#define MARGIN_TOP       (30)
#define MARGIN_BOTTOM    (20)

@interface YFLineChartView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel                *m_titleLabel;
@property (nonatomic, strong) UILabel                *m_XTitleLabel;
@property (nonatomic, strong) UILabel                *m_YTitleLabel;
@property (nonatomic, strong) YFLineChartContentView *m_contentView;

@end

@implementation YFLineChartView

-(id)initWithFrame:(CGRect)frame dataSource:(NSArray*)dataSource title:(NSString *)title xTitle:(NSString*)xTitle yTitle:(NSString*)yTitle xCount:(NSInteger)xCount yCount:(NSInteger)yCount isNeedGrid:(BOOL)needGrid{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        if (title) {
            _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, MARGIN_TOP)];
            _m_titleLabel.text = title;
            _m_titleLabel.textAlignment = NSTextAlignmentCenter;
            _m_titleLabel.textColor = [UIColor blackColor];
            _m_titleLabel.font = [UIFont systemFontOfSize:13];
            [self addSubview:_m_titleLabel];
            
        }
        
        if(xTitle){
            _m_XTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-MARGIN_BOTTOM, frame.size.width, MARGIN_BOTTOM)];
            _m_XTitleLabel.text = xTitle;
            _m_XTitleLabel.textAlignment = NSTextAlignmentCenter;
            _m_XTitleLabel.textColor = [UIColor blackColor];
            _m_XTitleLabel.font = [UIFont systemFontOfSize:9];
            [self addSubview:_m_XTitleLabel];
        }
        
        _m_contentView = [[YFLineChartContentView alloc] initWithFrame:CGRectMake(0, MARGIN_TOP, frame.size.width, frame.size.height-MARGIN_TOP-MARGIN_BOTTOM)
                                                            dataSource:dataSource
                                                                xCount:xCount
                                                                yCount:yCount
                                                            isNeedGrid:needGrid
                                                                  type:kIMPStrategyType];
        [_m_contentView setNeedsDisplay];
        _m_contentView.layer.masksToBounds = YES;
        [self addSubview:_m_contentView];
        
        
    }
    return self;
    
}


-(void)refreshData:(NSArray *)dataSource{
    
    [_m_contentView refreshData:dataSource];
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    
    return YES;
}


@end
