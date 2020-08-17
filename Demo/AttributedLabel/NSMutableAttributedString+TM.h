//
//  NSMutableAttributedString+TM.h
//  Demo
//
//  Created by solehe on 2020/8/17.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (TM)

- (void)xx_setTextColor:(UIColor *)color;
- (void)xx_setTextColor:(UIColor *)color range:(NSRange)range;

- (void)xx_setFont:(UIFont *)font;
- (void)xx_setFont:(UIFont *)font range:(NSRange)range;

- (void)xx_setUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier;
- (void)xx_setUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
