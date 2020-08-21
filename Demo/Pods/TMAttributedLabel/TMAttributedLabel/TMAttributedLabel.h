//
//  TMAttributedLabel.h
//
//  Created by solehe on 2020/8/15.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMAttributedLabelHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMAttributedLabel : UILabel

/// 代理
@property (nonatomic, weak) id<TMAttributedLabelDelegate> delegate;

/// 行间距，默认为0
@property (nonatomic, assign) IBInspectable CGFloat lineSpacing;

/// 段间距，默认为0
@property (nonatomic, assign) IBInspectable CGFloat paragraphSpacing;

/// 最小行高如果此值设置小于或等于0，将默认为字体行高
@property (nonatomic, assign) IBInspectable CGFloat minimumLineHeight;

/// 最大行高如果此值设置小于或等于0，将默认为字体行高
@property (nonatomic, assign) IBInspectable CGFloat maximumLineHeight;

/// 多行行高，默认为1.0，设置改值，行高将在原设置的基础上放大或缩小对应的倍数
@property (nonatomic, assign) IBInspectable CGFloat lineHeightMultiple;

/// 边距，默认为UIEdgeInsetsZero
@property (nonatomic, assign) IBInspectable UIEdgeInsets textInsets;

/// 是否扩大链接点击选取
@property (nonatomic, assign) IBInspectable BOOL extendsLinkTouchArea;

/// 链接颜色
@property (nonatomic, strong, nullable) IBInspectable UIColor *linkColor;

/// 链接点击时的高亮颜色
@property (nonatomic, strong, nullable) IBInspectable UIColor *linkHighlightColor;

/// 竖直方向对齐方式，默认为居中对齐
@property (nonatomic, assign) IBInspectable TMAttributedAlignment verticalAlignment;

/// TruncationToken
@property (nonatomic, copy, nullable) NSAttributedString *attributedTruncationToken;

/// 当前展示的文本内容
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;

/**
 * 设置文本，通过该方法设置后会清空之前的内容
 *
 * @param text 支持传入NSString和NSAttributedString
 */
- (void)setText:(id _Nullable)text;

/**
 * 增加文本内容，不会清空之前的内容
 *
 * @param obj 支持传入NSString、NSAttributedString、UIImage和UIView
 * @param alignment 对齐方式
 */
- (void)append:(id)obj alignment:(TMAttributedAlignment)alignment;
- (void)append:(id)obj;

/**
 * 添加自定义链接
 *
 *  @param linkData 支持传入任何类型，触发点击事件后会原样返回
 *  @param range 需要点击的文本范围
 *  @param color 可点击文本的颜色
 */
- (void)addCustomLink:(id)linkData forRange:(NSRange)range color:(UIColor *)color;
- (void)addCustomLink:(id)linkData forRange:(NSRange)range;

/**
 * 计算占用尺寸大小
 *
 * @param size 最大支持尺寸
 */
- (CGSize)sizeThatFits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
