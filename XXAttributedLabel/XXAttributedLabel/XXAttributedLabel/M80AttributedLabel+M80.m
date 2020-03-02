//
//  M80AttributedLabel+M80.m
//  XXAttributedLabel
//
//  Created by solehe on 2020/3/2.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <objc/runtime.h>
#import "M80AttributedLabel+M80.h"

@implementation M80AttributedLabel (M80)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        Method m80Method1 = class_getInstanceMethod(self.class, @selector(resetTextFrame:));
        Method m80Method2 = class_getInstanceMethod(self.class, @selector(prepareTextFrame:rect:));
#pragma clang diagnostic pop
        Method xxMethod1 = class_getInstanceMethod(self.class, @selector(xx_resetTextFrame));
        Method xxMethod2 = class_getInstanceMethod(self.class, @selector(xx_prepareTextFrame:rect:));
        method_exchangeImplementations(m80Method1, xxMethod1);
        method_exchangeImplementations(m80Method2, xxMethod2);
    });
}

- (void)xx_resetTextFrame
{
    if (self.textFrameRef)
    {
        CFRelease(self.textFrameRef);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        self.textFrameRef = nil;
#pragma clang diagnostic pop
    }
   
    [self xx_resetTextFrame];
}

- (void)xx_prepareTextFrame:(NSAttributedString *)string
                       rect:(CGRect)rect
{
    if (self.textFrameRef == nil)
    {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, nil,rect);
        self.textFrameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CGPathRelease(path);
        CFRelease(framesetter);
    }
    
    [self xx_prepareTextFrame:string rect:rect];
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
