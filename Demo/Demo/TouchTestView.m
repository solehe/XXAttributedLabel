//
//  TouchTestView.m
//  XXAttributedLabel
//
//  Created by solehe on 2020/3/1.
//  Copyright © 2020 solehe. All rights reserved.
//

#import "TouchTestView.h"

@implementation TouchTestView

/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    NSArray *subViews = [self subviews];
    for (UIView *view in subViews)
    {
        CGPoint hitPoint = [view convertPoint:point fromView:self];
        
        UIView *hitTestView = [view hitTest:hitPoint withEvent:event];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([hitTestView respondsToSelector:@selector(isResponseLongPressGresture)])
        {
            return hitTestView;
        }
#pragma clang diagnostic pop
    }
    return self;
}
 */

//// 处理点击链接手势冲突
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//    if ([touch.view respondsToSelector:@selector(isResponseLongPressGresture)]){
//        return YES;
//    }
//#pragma clang diagnostic pop
//    return NO;
//}


@end
