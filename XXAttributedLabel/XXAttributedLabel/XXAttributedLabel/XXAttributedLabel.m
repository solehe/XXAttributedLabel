//
//  XXAttributedLabel.m
//  XXAttributedLabel
//
//  Created by solehe on 2020/2/29.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <objc/runtime.h>
#import "XXAttributedLabel.h"
#import "XXAttributedLabelDrawView.h"
#import "M80AttributedLabelURL.h"

@interface XXAttributedLabel ()

// 选择视图
@property (nonatomic, strong) XXAttributedLabelDrawView *drawView;

// 触摸定时器，用于判断长按和点击
@property (nonatomic, strong) NSTimer *touchTimer;

// 是否是长按链接
@property (nonatomic, assign) BOOL isLongPressedLink;


@end


@implementation XXAttributedLabel

- (XXAttributedLabelDrawView *)drawView
{
    if (!_drawView)
    {
        _drawView = [[XXAttributedLabelDrawView alloc] initWithFrame:self.bounds];
        [_drawView setBackgroundColor:[UIColor clearColor]];
        [_drawView setClipsToBounds:NO];
        [_drawView setLabel:self];
    }
    return _drawView;
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

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self.drawView setBounds:self.bounds];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    [self.drawView setBounds:self.bounds];
}

- (NSString *)selectedText
{
    NSRange range = self.drawView.selecedRange;
    NSUInteger len = range.location + range.length;
    if (len <= self.attributedText.string.length)
    {
        return [self.attributedText.string substringWithRange:self.drawView.selecedRange];
    }
    return nil;
}

- (CGFloat)activeDuration
{
    return MAX(_activeDuration, 0.5f);
}

- (void)setSelecting:(BOOL)selecting
{
    if (_selecting != selecting && _enableSelected)
    {
        _selecting = selecting;
        [self.drawView setSelecting:selecting];
        
        if (self.selectingListenBlock)
        {
            self.selectingListenBlock(selecting);
        }
    }
}

- (void)setIsDisplayingMagnify:(BOOL)isDisplayingMagnify
{
    if (_isDisplayingMagnify != isDisplayingMagnify)
    {
        _isDisplayingMagnify = isDisplayingMagnify;
        
        if (self.magnifyDisplayBlock)
        {
            self.magnifyDisplayBlock(isDisplayingMagnify);
        }
    }
}


#pragma mark -  绘制

- (void)drawRect:(CGRect)rect
{
    if (self.drawView.selecting)
    {
        [self setValue:nil forKeyPath:@"touchedLink"];
    }
    
    [super drawRect:rect];
}

#pragma mark - 点击事件相应
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    // 是否在选中状态
    if (self.enableSelected && (!self.drawView.selecting || !self.longPressedLinkBlock))
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
    if (!self.isLongPressedLink && !self.drawView.selecting)
    {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isLongPressedLink && !self.drawView.selecting)
    {
        [super touchesEnded:touches withEvent:event];
    }
    
    [self deallocTouches];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.drawView.selecting)
    {
        return self.drawView;
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
    if (link && !NSEqualRanges(link.range, NSMakeRange(0, self.text.length)))
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
        [self.drawView setSelecting:YES];
        [self setNeedsDisplay];
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
