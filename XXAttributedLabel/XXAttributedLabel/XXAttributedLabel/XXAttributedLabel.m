//
//  XXAttributedLabel.m
//  XXAttributedLabel
//
//  Created by solehe on 2020/2/29.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <objc/runtime.h>
#import "XXAttributedLabel.h"
#import "XXAttributedLabelSelectView.h"
#import "M80AttributedLabelURL.h"

@interface XXAttributedLabel ()

// 选择视图
@property (nonatomic, strong) XXAttributedLabelSelectView *selectView;

// 触摸定时器，用于判断长按和点击
@property (nonatomic, strong) NSTimer *touchTimer;

// 是否是长按链接
@property (nonatomic, assign) BOOL isLongPressedLink;

@end


@implementation XXAttributedLabel

- (XXAttributedLabelSelectView *)selectView
{
    if (!_selectView)
    {
        _selectView = [[XXAttributedLabelSelectView alloc] initWithFrame:self.bounds];
        [_selectView setBackgroundColor:[UIColor clearColor]];
        [_selectView setClipsToBounds:NO];
        [_selectView setLabel:self];
    }
    return _selectView;
}

- (UIColor *)selectedBackgroundColor
{
    if (!_selectedBackgroundColor)
    {
        _selectedBackgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2];
    }
    return _selectedBackgroundColor;
}

- (UIColor *)selectedAnchorColor
{
    if (!_selectedAnchorColor)
    {
        _selectedAnchorColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.6];
    }
    return _selectedAnchorColor;
}

- (NSString *)selectedText
{
    NSRange range = self.selectView.selecedRange;
    NSUInteger len = range.location + range.length;
    if (len <= self.attributedText.string.length)
    {
        return [self.attributedText.string substringWithRange:self.selectView.selecedRange];
    }
    return nil;
}

- (CGFloat)activeDuration
{
    return MAX(_activeDuration, 0.5f);
}

#pragma mark - 点击事件相应
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    // 是否在选中状态
    if (self.enableSelected && (!self.selectView.selecting || !self.longPressedLinkBlock))
    {
     
        //计时器，手指点中0.5秒后启动选中效果
        self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                        selector:@selector(longPressed)
                                                         userInfo:nil
                                                          repeats:NO];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isLongPressedLink && !self.selectView.selecting)
    {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isLongPressedLink && !self.selectView.selecting)
    {
        [super touchesCancelled:touches withEvent:event];
    }
    
    [self deallocTouches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isLongPressedLink && !self.selectView.selecting)
    {
        [super touchesEnded:touches withEvent:event];
    }
    
    [self deallocTouches];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.selectView.selecting)
    {
        return self.selectView;
    }
    else if (CGRectContainsPoint(self.bounds, point))
    {
        return self;
    }
    
    return nil;
}

#pragma mark -

// 触发长按操作
- (void)longPressed
{
    M80AttributedLabelURL *link = [self valueForKeyPath:@"touchedLink"];
    if (link)
    {
        [self setIsLongPressedLink:YES];
        
        __weak typeof(self) weakSelf = self;
        self.longPressedLinkBlock(link.linkData, ^{
            [weakSelf setValue:nil forKeyPath:@"touchedLink"];
            [weakSelf setNeedsDisplay];
        });
    }
    else
    {
        [self.selectView setSelecting:YES];
    }
}

// 结束触摸操作
- (void)deallocTouches
{
    [self setIsLongPressedLink:NO];
    [self.touchTimer invalidate];
    [self setTouchTimer:nil];
}

#pragma mark -

- (BOOL)isResponseLongPressGresture {
    return YES;
}

@end
