//
//  GlowPointView.m
//  DrawChartTest
//
//  Created by FrankLiu on 16/4/26.
//  Copyright © 2016年 FrankLiu. All rights reserved.
//

#import "GlowPointView.h"
#import "UIView+SetRect.h"

@interface GlowPointView ()

@property (nonatomic, strong) UIColor *m_color;

@end

@implementation GlowPointView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.m_color = [UIColor cyanColor];
        
        [self buildSubViews];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color {

    if (self = [super initWithFrame:frame]) {
        
        self.m_color = color;
        [self buildSubViews];
    }
    
    return self;
}

- (void)buildSubViews {

    CALayer *pointLayer = [CALayer layer];
    
    pointLayer.backgroundColor = self.m_color.CGColor;
    pointLayer.frame           = CGRectMake(0, 0, 5, 5);
    pointLayer.position        = self.middlePoint;
    pointLayer.cornerRadius    = 2.5f;
    
    [self.layer addSublayer:pointLayer];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path          = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, 5, 5) cornerRadius:2.5f].CGPath;
    circleLayer.frame        = CGRectMake(0, 0, 5, 5);
    circleLayer.fillColor    = [UIColor clearColor].CGColor;
//    circleLayer.strokeStart  = 0;
//    circleLayer.strokeEnd    = 1;
    circleLayer.strokeColor  = self.m_color.CGColor;
    circleLayer.lineWidth    = 0.5f;
    circleLayer.position     = self.middlePoint;
    circleLayer.cornerRadius = 2.5f;
    
    [self.layer addSublayer:circleLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.fromValue   = @1;
    animation.toValue     = @2;
//    animation.duration    = 1;
    animation.repeatCount = 1000000;
    
//    [circleLayer addAnimation:animation forKey:nil];
    
    circleLayer.transform = CATransform3DScale(CATransform3DIdentity, 3, 3, 1);
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    alphaAnimation.fromValue   = @1;
    alphaAnimation.toValue     = @0;
//    alphaAnimation.duration    = 1;
    alphaAnimation.repeatCount = 1000000;
    
//    [circleLayer addAnimation:alphaAnimation forKey:nil];
    
    circleLayer.opacity = 0;
    
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
//
    groupAnimation.animations  = @[animation,alphaAnimation];
    groupAnimation.duration    = 1.f;
    groupAnimation.repeatCount = 1000000;
    
    [circleLayer addAnimation:groupAnimation forKey:nil];
    
}

@end
