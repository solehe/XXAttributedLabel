//
//  XXAttributedLabelDrawView.m
//  WeTalk
//
//  Created by solehe on 2020/3/3.
//  Copyright © 2020 王金悍. All rights reserved.
//

#import "XXAttributedLabelTouchView.h"

@implementation XXAttributedLabelTouchView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(touchView:begain:)])
    {
        [self.delegate touchView:self begain:[self convertTouchsToPoint:touches]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(touchView:moved:)])
    {
        [self.delegate touchView:self moved:[self convertTouchsToPoint:touches]];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(touchView:cancelled:)])
    {
        [self.delegate touchView:self cancelled:[self convertTouchsToPoint:touches]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(touchView:ended:)])
    {
        [self.delegate touchView:self ended:[self convertTouchsToPoint:touches]];
    }
}

#pragma mark -

- (CGPoint)convertTouchsToPoint:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:self];
}

@end
