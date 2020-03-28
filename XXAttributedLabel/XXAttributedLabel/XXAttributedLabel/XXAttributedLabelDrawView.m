//
//  XXAttributedLabelDrawView.m
//  XXAttributedLabel
//
//  Created by solehe on 2020/2/29.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <CoreText/CoreText.h>

#import "M80AttributedLabel+M80.h"
#import "XXAttributedLabelMagnifyView.h"
#import "XXAttributedLabelTouchView.h"
#import "XXAttributedLabelDrawView.h"
#import "XXAttributedLabel.h"

// 拖拽位置枚举
typedef NS_ENUM(NSInteger, XXDragLocation) {
    XXDragLocationNone,    //拖拽无效
    XXDragLocationStart,   //拖拽左侧
    XXDragLocationEnd      //拖拽右侧
};


@interface XXAttributedLabelDrawView ()
<
    XXAttributedLabelTouchViewDelegate
>

// 开始绘制行
@property (nonatomic, assign) CFIndex startAtLine;
// 开始绘制位置
@property (nonatomic, assign) CFIndex startAtIndex;
// 结束绘制行
@property (nonatomic, assign) CFIndex endAtLine;
// 结束绘制位置
@property (nonatomic, assign) CFIndex endAtIndex;

// 选中区域扩展
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

// 锚点开始位置
@property (nonatomic, assign) CGRect startAnchorRect;
// 锚点结束位置
@property (nonatomic, assign) CGRect endAnchorRect;

// 拖拽位置
@property (nonatomic, assign) XXDragLocation dragLocation;

// 触摸视图
@property (nonatomic, strong) XXAttributedLabelTouchView *touchView;

// 放大镜视图
@property (nonatomic, strong) XXAttributedLabelMagnifyView *magnifyView;

@end

@implementation XXAttributedLabelDrawView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    // 扩大选中范围
    frame = [self increaseFrame:frame];
    
    if (self = [super initWithFrame:frame])
    {
        
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    // 扩大选中范围
    CGRect frame = [self increaseFrame:bounds];;
    // 重置自身大小
    [self setFrame:frame];
}

- (XXAttributedLabelTouchView *)touchView
{
    if (!_touchView)
    {
        _touchView = [[XXAttributedLabelTouchView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_touchView setBackgroundColor:[UIColor clearColor]];
        [_touchView setDelegate:self];
    }
    return _touchView;
}

- (XXAttributedLabelMagnifyView *)magnifyView
{
    if (!_magnifyView)
    {
        _magnifyView = [[XXAttributedLabelMagnifyView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        [_magnifyView setBackgroundColor:[UIColor clearColor]];
        [_magnifyView setUserInteractionEnabled:NO];
        [_magnifyView setView:self.label];
    }
    return _magnifyView;
}

- (UIEdgeInsets)edgeInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(_edgeInsets, UIEdgeInsetsZero))
    {
        _edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return _edgeInsets;
}

- (NSRange)selecedRange {
    
    CFArrayRef lines = CTFrameGetLines(self.label.textFrameRef);
    
    // 计算开始行第一个字符位置
    __block CFIndex begainLineIndex = 0;
    CTLineRef startLine = CFArrayGetValueAtIndex(lines, self.startAtLine);
    CTLineEnumerateCaretOffsets(startLine, ^(double offset, CFIndex charIndex, bool leadingEdge, bool * _Nonnull stop) {
        begainLineIndex = charIndex;
        *stop = YES;
    });
    
    // 开始位置
    CFIndex startIndex = begainLineIndex + self.startAtIndex;
    
    // 计算结束行第一个字符位置
    __block CFIndex endLineIndex = 0;
    CTLineRef endLine = CFArrayGetValueAtIndex(lines, self.endAtLine);
    CTLineEnumerateCaretOffsets(endLine, ^(double offset, CFIndex charIndex, bool leadingEdge, bool * _Nonnull stop) {
        endLineIndex = charIndex;
        *stop = YES;
    });
    
    // 结束位置
    CFIndex endIndex = endLineIndex + self.endAtIndex;
    
    // 返回选中位置
    return NSMakeRange(startIndex, endIndex-startIndex);
}

#pragma mark - setter方法

- (void)setSelecting:(BOOL)selecting {
    
    if (_selecting != selecting) {
        
        _selecting = selecting;
        
        if (selecting)
        {
            [self show];
        }
        else
        {
            [self hidden];
        }
    }
}


#pragma mark -

- (void)drawRect:(CGRect)rect {
    
    // 处于选择状态
    if (self.selecting && self.startAtLine <= self.endAtLine)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CFArrayRef lines = CTFrameGetLines(self.label.textFrameRef);
        CFIndex numberOfLines = CFArrayGetCount(lines);
        
        // 获取行数
        CGPoint lineOrigins[numberOfLines];
        CTFrameGetLineOrigins(self.label.textFrameRef, CFRangeMake(0, 0), lineOrigins);
        
        // 开始绘制
        if (self.startAtIndex < self.endAtIndex || self.startAtLine < self.endAtLine)
        {
            // 竖直方向上的开始坐标
            CGFloat yOffset = self.edgeInsets.top;
            
            // 分行绘制
            for (CFIndex i=0; i<=self.endAtLine; i++)
            {
                CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                
                // 获取所在行的宽度
                CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
                CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
                
                // 获取行高和y坐标开始位置
                CGFloat lineHeight = (ascent + descent + self.label.lineSpacing);
                
                // 绘制
                if (i >= self.startAtLine) {
                    [self drawContext:context line:line index:i yOffset:yOffset lineHeight:lineHeight];
                }
                
                // 更新下一行起点位置
                yOffset += lineHeight;
            }
        }
    }
    else
    {
        NSLog(@"未知类型");
    }
}

- (void)drawContext:(CGContextRef)context line:(CTLineRef)line index:(CFIndex)index yOffset:(CGFloat)yOffset lineHeight:(CGFloat)lineHeight {
    
    // 计算当前行第一个字符位置
    __block CFIndex begainIndex = 0;
    CTLineEnumerateCaretOffsets(line, ^(double offset, CFIndex charIndex, bool leadingEdge, bool * _Nonnull stop) {
        begainIndex = charIndex;
        *stop = YES;
    });
    
    // 获取X坐标
    CFIndex startAtIndex = (index==self.startAtLine)?self.startAtIndex:0;
    CFIndex endAtIndex = (index==self.endAtLine)?self.endAtIndex:[self getLineMaxIndex:index];
    CGFloat xOffset1 = CTLineGetOffsetForStringIndex(line, startAtIndex+begainIndex, nil) + self.edgeInsets.left;
    CGFloat xOffset2 = CTLineGetOffsetForStringIndex(line, endAtIndex+begainIndex, nil) + self.edgeInsets.left;
    
    // 绘制
    CGContextSetFillColorWithColor(context, self.label.selectedBackgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(xOffset1, yOffset, xOffset2-xOffset1, lineHeight));
    
    // 绘制开始锚点
    if (index == self.startAtLine)
    {
        self.startAnchorRect = CGRectMake(xOffset1-1, yOffset, 2, lineHeight);
        CGContextSetFillColorWithColor(context, self.label.selectedAnchorColor.CGColor);
        CGContextFillRect(context, self.startAnchorRect);
        CGContextAddArc(context, xOffset1, yOffset-3, 3, 0, M_PI * 2, NO);
        CGContextFillPath(context);
    }
    
    // 绘制结束锚点
    if (index == self.endAtLine)
    {
        self.endAnchorRect = CGRectMake(xOffset2-1, yOffset, 2, lineHeight);
        CGContextSetFillColorWithColor(context, self.label.selectedAnchorColor.CGColor);
        CGContextFillRect(context, self.endAnchorRect);
        CGContextAddArc(context, xOffset2, yOffset+lineHeight+3, 3, 0, M_PI * 2, NO);
        CGContextFillPath(context);
    }
    
    // 更新放大镜位置
    if (self.dragLocation == XXDragLocationStart)
    {
        CGFloat x = CGRectGetMidX(self.startAnchorRect);
        CGFloat y = CGRectGetMidY(self.startAnchorRect);
        [self moveMagnifyView:CGPointMake(x, y)];
    }
    else if (self.dragLocation == XXDragLocationEnd)
    {
        CGFloat x = CGRectGetMidX(self.endAnchorRect);
        CGFloat y = CGRectGetMidY(self.endAnchorRect);
        [self moveMagnifyView:CGPointMake(x, y)];
    }
}

#pragma mark - 点击事件相应

- (void)touchView:(XXAttributedLabelTouchView *)touchView begain:(CGPoint)point
{
    // 是否在选中状态
    if (self.selecting)
    {
        CGPoint drawPoint = [touchView convertPoint:point toView:self];
        
        if ([self isContainsPoint:drawPoint])
        {
            [self begainTouchPoint:drawPoint];
        }
        else
        {
            [self setSelecting:NO];
        }
    }
}

- (void)touchView:(XXAttributedLabelTouchView *)touchView moved:(CGPoint)point
{
    // 是否在选中状态
    if (self.selecting && self.dragLocation != XXDragLocationNone)
    {
        CGPoint drawPoint = [touchView convertPoint:point toView:self];
        [self moveTouchPoint:drawPoint];
    }
}

- (void)touchView:(XXAttributedLabelTouchView *)touchView cancelled:(CGPoint)point
{
    // 隐藏放大镜
    [self hiddenMagnifyView];
}

- (void)touchView:(XXAttributedLabelTouchView *)touchView ended:(CGPoint)point
{
    // 隐藏放大镜
    [self hiddenMagnifyView];
}


#pragma mark -

// 当前触摸点是否在控件内
- (BOOL)isContainsPoint:(CGPoint)point
{
    if (CGRectContainsPoint(self.bounds, point))
    {
        return YES;
    }
    
    return NO;
}

// 计算是否选中锚点及位置
- (void)begainTouchPoint:(CGPoint)point {
    
    // 适当扩大初次选择区域
    CGRect startAnchorRect = [self increaseRect:self.startAnchorRect];
    CGRect endAnchorRect = [self increaseRect:self.endAnchorRect];
    
    // 判断选中位置对应类型
    if (CGRectContainsPoint(startAnchorRect, point))
    {
        [self setDragLocation:XXDragLocationStart];
    }
    else if (CGRectContainsPoint(endAnchorRect, point))
    {
        [self setDragLocation:XXDragLocationEnd];
    }
    else {
        [self setDragLocation:XXDragLocationNone];
    }
}

// 移动选中锚点
- (void)moveTouchPoint:(CGPoint)point {
    
    CFArrayRef lines = CTFrameGetLines(self.label.textFrameRef);
    CFIndex numberOfLines = CFArrayGetCount(lines);
    
    CGFloat yOffset = self.edgeInsets.top;
    
    // 查找点击所在的位置
    for (CFIndex i=0; i<numberOfLines; i++)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        // 获取所在行的宽度
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        // 获取行高和y坐标开始位置
        CGFloat lineHeight = (ascent + descent + self.label.lineSpacing);
        
        if (point.y >= yOffset && point.y <= yOffset+lineHeight)
        {
            // 更新选中区域
            [self refreshSelect:line lineIndex:i point:point];
            
            // 展示放大镜
            if (!self.magnifyView.superview)
            {
                [self.touchView addSubview:self.magnifyView];
                [self.label setIsDisplayingMagnify:YES];
            }
            
            break;
        }
        
        yOffset += lineHeight;
    }
}

// 更新选中位置
- (void)refreshSelect:(CTLineRef)line lineIndex:(CFIndex)lineIndex point:(CGPoint)point {
    
    // 计算当前行第一个字符位置
    __block CFIndex begainIndex = 0;
    CTLineEnumerateCaretOffsets(line, ^(double offset, CFIndex charIndex, bool leadingEdge, bool * _Nonnull stop) {
        begainIndex = charIndex;
        *stop = YES;
    });
    
    CFIndex position = CTLineGetStringIndexForPosition(line, point) - begainIndex;
    
    if (self.dragLocation == XXDragLocationStart &&
        (lineIndex != self.endAtLine || (lineIndex == self.endAtLine && position != self.endAtIndex)))
    {
        // 开始位置不能移到最后位置
        CFIndex maxCount = [self getLineMaxIndex:lineIndex];
        if (maxCount == position)
        {
            position -= 1;
        }
        
        // 设置开始位置
        [self setStartAtLine:lineIndex];
        [self setStartAtIndex:position];
        
        if (lineIndex > self.endAtLine || (lineIndex == self.endAtLine && position > self.endAtIndex)) {
            [self exchangeLocation];
        }
        
        [self setNeedsDisplay];
    }
    else if (self.dragLocation == XXDragLocationEnd &&
             (lineIndex != self.startAtLine || (lineIndex == self.startAtLine && position != self.startAtIndex)))
    {
        // 结束位置不能移到最后最前
        position = MAX(1, position);
        
        // 设置结束位置
        [self setEndAtLine:lineIndex];
        [self setEndAtIndex:position];
        
        if (lineIndex < self.startAtLine || (lineIndex == self.startAtLine && position < self.startAtIndex)) {
            [self exchangeLocation];
        }
        
        [self setNeedsDisplay];
    }
}

// 交换开始和结束位置
- (void)exchangeLocation {
    
    // 交换位置类型
    if (self.dragLocation == XXDragLocationEnd)
    {
        [self setDragLocation:XXDragLocationStart];
    }
    else if (self.dragLocation == XXDragLocationStart)
    {
        [self setDragLocation:XXDragLocationEnd];
    }
    
    // 交换坐标
    CFIndex tmpLine = self.startAtLine;
    CFIndex tmpIndex = self.startAtIndex;
    self.startAtLine = self.endAtLine;
    self.startAtIndex = self.endAtIndex;
    self.endAtLine = tmpLine;
    self.endAtIndex = tmpIndex;
}

// 扩大范围
- (CGRect)increaseRect:(CGRect)rect {
    CGRect increaseRect = rect;
    increaseRect.origin.x -= 10;
    increaseRect.origin.y -= 10;
    increaseRect.size.width += 20;
    increaseRect.size.height += 20;
    return increaseRect;
}

// 扩大自身尺寸
- (CGRect)increaseFrame:(CGRect)frame
{
    // 扩大选中范围
    CGFloat x = frame.origin.x - self.edgeInsets.left;
    CGFloat y = frame.origin.y - self.edgeInsets.top;
    CGFloat width = frame.size.width + self.edgeInsets.left + self.edgeInsets.right;
    CGFloat height = frame.size.height + self.edgeInsets.top + self.edgeInsets.bottom;
    
    return CGRectMake(x , y, width, height);
}

// 获取指定行最大个数
- (CFIndex)getLineMaxIndex:(CFIndex)index
{
    CFArrayRef lines = CTFrameGetLines(self.label.textFrameRef);
    CFIndex numberOfLines = CFArrayGetCount(lines);
    if (numberOfLines <= 0)
    {
        return 0;
    }
    
    CGFloat yOffset = self.edgeInsets.top;
    
    // 查找点击所在的位置
    for (CFIndex i=0; i<numberOfLines; i++)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        // 获取所在行的宽度
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        // 获取行高和y坐标开始位置
        CGFloat lineHeight = (ascent + descent + self.label.lineSpacing);
        
        if (index == i)
        {
            CGPoint point = CGPointMake(CGRectGetWidth(self.bounds), yOffset);
            
            // 计算当前行第一个字符位置
            __block CFIndex begainIndex = 0;
            CTLineEnumerateCaretOffsets(line, ^(double offset, CFIndex charIndex, bool leadingEdge, bool * _Nonnull stop) {
                begainIndex = charIndex;
                *stop = YES;
            });
            
            return CTLineGetStringIndexForPosition(line, point) - begainIndex;
        }
        
        yOffset += lineHeight;
    }
    
    return 0;
}

#pragma mark -

// 展示选中视图
- (void)show {
    
    // 重置选中状态
    [self.label setSelecting:YES];
    
    // 添加到label
    [self.label addSubview:self];
    
    // 添加触控视图
    [self.window addSubview:self.touchView];
    
    // 设置开始位置
    [self setStartAtLine:0];
    [self setStartAtIndex:0];
    
    // 设置结束位置
    CFArrayRef lines = CTFrameGetLines(self.label.textFrameRef);
    CFIndex numberOfLines = CFArrayGetCount(lines);
    [self setEndAtLine:numberOfLines-1];
    
    CFIndex position = [self getLineMaxIndex:self.endAtLine];
    [self setEndAtIndex:position];
    
    // 重绘
    [self setNeedsDisplay];
}

// 隐藏选中视图
- (void)hidden {
    
    // 重置选中状态
    [self.label setSelecting:NO];
    
    // 重置拖拽类型
    [self setDragLocation:XXDragLocationNone];
    
    // 设置开始位置
    [self setStartAtLine:0];
    [self setStartAtIndex:0];
    
    // 设置结束位置
    [self setEndAtLine:0];
    [self setEndAtIndex:0];
    
    // 重绘
    [self setNeedsDisplay];
    
    // 从label中移除
    [self removeFromSuperview];
    
    // 移除触控视图
    [self.touchView removeFromSuperview];
}

#pragma mark -

// 移动放大镜
- (void)moveMagnifyView:(CGPoint)point
{
    CGPoint center = [self convertPoint:point toView:self.window];
    [self.magnifyView refreshCenter:center magnifyPoint:point];
}

// 隐藏放大镜
- (void)hiddenMagnifyView
{
    [self.magnifyView removeFromSuperview];
    [self.label setIsDisplayingMagnify:NO];
}

#pragma mark -

- (BOOL)isResponseLongPressGresture {
    return YES;
}

@end
