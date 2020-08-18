//
//  NSMutableAttributedString+TM.m
//  Demo
//
//  Created by solehe on 2020/8/17.
//  Copyright © 2020 solehe. All rights reserved.
//

#import "NSMutableAttributedString+TM.h"

@implementation NSMutableAttributedString (TM)

- (void)xx_setTextColor:(UIColor *)color {
    [self xx_setTextColor:color range:NSMakeRange(0, [self length])];
}

- (void)xx_setTextColor:(UIColor *)color range:(NSRange)range {
    [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
    if (color.CGColor)
    {
        [self addAttribute:(NSString *)kCTForegroundColorAttributeName
                     value:(id)color.CGColor
                     range:range];
    }
}

- (void)xx_setFont:(UIFont *)font {
    [self xx_setFont:font range:NSMakeRange(0, [self length])];
}

- (void)xx_setFont:(UIFont *)font range:(NSRange)range {
    
    if (font) {
        
        [self removeAttribute:(NSString*)kCTFontAttributeName range:range];
        
        CTFontRef fontRef = CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)font.fontDescriptor, font.pointSize, nil);
        if (nil != fontRef) {
            [self addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }
}

- (void)xx_setUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier {
    [self xx_setUnderlineStyle:style modifier:modifier range:NSMakeRange(0, self.length)];
}

- (void)xx_setUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range; {
    [self removeAttribute:(NSString *)kCTUnderlineColorAttributeName range:range];
    [self addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:(style|modifier)] range:range];
}

@end
