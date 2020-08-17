//
//  AttributedLabel+XX.m
//  AttributedLabel
//
//  Created by solehe on 2020/3/2.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <objc/runtime.h>
#import "TMAttributedLabel+XX.h"

@implementation TMAttributedLabel (XX)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        Method method1 = class_getInstanceMethod(self.class, @selector(setTextFrame:));
#pragma clang diagnostic pop
        Method xxMethod1 = class_getInstanceMethod(self.class, @selector(xx_setTextFrame:));
        method_exchangeImplementations(method1, xxMethod1);
    });
}

- (void)xx_setTextFrame:(CTFrameRef)frameRef
{
    [self setTextFrameRef:frameRef];
    [self xx_setTextFrame:frameRef];
}

#pragma mark -

- (void)setTextFrameRef:(CTFrameRef)textFrameRef
{
    objc_setAssociatedObject(self, @"TextFrameRef", (__bridge id _Nullable)(textFrameRef), OBJC_ASSOCIATION_ASSIGN);
}

- (CTFrameRef)textFrameRef
{
    return (__bridge CTFrameRef _Nonnull)(objc_getAssociatedObject(self, @"TextFrameRef"));
}

@end
