//
//  XXAttributedLabelMagnifyView.m
//  XXAttributedLabel
//
//  Created by solehe on 2020/3/1.
//  Copyright © 2020 solehe. All rights reserved.
//

#import "XXAttributedLabelMagnifyView.h"
#import "XXAttributedLabel.h"

@interface XXAttributedLabelTriangleView : UIView

@end

@implementation XXAttributedLabelTriangleView

- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw a triangle
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width/2, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextClosePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width/2, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextClosePath(context);
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextFillPath(context);
}

@end

#pragma mark - XXAttributedLabelMagnifyLayer

@interface XXAttributedLabelMagnifyLayer : CALayer

// 需要放大的视图
@property (nonatomic, weak) UIView *view;
// 需要放大的点
@property (nonatomic, assign) CGPoint magnifyPoint;

@end

@implementation XXAttributedLabelMagnifyLayer

- (void)drawInContext:(CGContextRef)ctx
{
    //绘制放大镜效果
    CGContextTranslateCTM(ctx, CGRectGetWidth(self.frame)/2+16, CGRectGetHeight(self.frame)/2+16);
    CGContextScaleCTM(ctx, 1.4, 1.4);
    CGContextTranslateCTM(ctx, -self.magnifyPoint.x, -self.magnifyPoint.y);
    [self.view.layer renderInContext:ctx];
}

@end


#pragma mark - XXAttributedLabelMagnifyView

@interface XXAttributedLabelMagnifyView ()

// 放大层
@property (nonatomic, strong) XXAttributedLabelMagnifyLayer *magnifyLayer;
// 三角形
@property (nonatomic, strong) XXAttributedLabelTriangleView *triangleView;

@end

@implementation XXAttributedLabelMagnifyView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initView];
    }
    return self;
}

- (void)initView
{
    // 放大层
    self.magnifyLayer = [[XXAttributedLabelMagnifyLayer alloc] init];
    [self.magnifyLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-10)];
    [self.magnifyLayer setContentsScale:[UIScreen mainScreen].scale];
    [self.magnifyLayer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.magnifyLayer setBorderWidth:0.5f];
    [self.magnifyLayer setCornerRadius:3.f];
    [self.magnifyLayer setMasksToBounds:YES];
    [self.layer addSublayer:self.magnifyLayer];
    
    // 底部三角箭头
    self.triangleView = [[XXAttributedLabelTriangleView alloc] init];
    [self.triangleView setFrame:CGRectMake(CGRectGetWidth(self.bounds)/2-10, CGRectGetHeight(self.frame)-10, 20, 10)];
    [self.triangleView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.triangleView];
}

- (void)setView:(UIView *)view
{
    _view = view;
    [self.magnifyLayer setView:view];
}

// 更新放大位置
- (void)refreshCenter:(CGPoint)center magnifyPoint:(CGPoint)magnifyPoint
{
    // 放大镜展示位置
    [self setCenter:CGPointMake(center.x, center.y-46)];
    
    // 放大镜放大位置
    _magnifyPoint = magnifyPoint;
    
    // 重绘
    [self.magnifyLayer setMagnifyPoint:magnifyPoint];
    [self.magnifyLayer setNeedsDisplay];
}

@end
