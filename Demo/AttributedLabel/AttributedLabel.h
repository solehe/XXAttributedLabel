//
//  AttributedLabel.h
//  Demo
//
//  Created by solehe on 2020/8/15.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXAtributedLabelHeader.h"


NS_ASSUME_NONNULL_BEGIN

@interface AttributedLabel : UILabel

// 行间距，默认为0
@property (nonatomic, assign) IBInspectable CGFloat lineSpacing;
// 段间距，默认为0
@property (nonatomic, assign) IBInspectable CGFloat paragraphSpacing;
// 最小行高如果此值设置小于或等于0，将默认为字体行高
@property (nonatomic, assign) IBInspectable CGFloat minimumLineHeight;
// 最大行高如果此值设置小于或等于0，将默认为字体行高
@property (nonatomic, assign) IBInspectable CGFloat maximumLineHeight;
// 多行行高，默认为1.0，设置改值，行高将在原设置的基础上放大或缩小对应的倍数
@property (nonatomic, assign) IBInspectable CGFloat lineHeightMultiple;
// 边距，默认为UIEdgeInsetsZero
@property (nonatomic, assign) IBInspectable UIEdgeInsets textInsets;
// 竖直方向对齐方式，默认为居中对齐
@property (nonatomic, assign) IBInspectable XXAttributedAlignment verticalAlignment;
// 链接颜色
@property (nonatomic, strong, nullable) IBInspectable UIColor *linkColor;
// 链接点击时的高亮颜色
@property (nonatomic, strong, nullable) IBInspectable UIColor *linkHighlightColor;
// 当前展示的文本内容
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
// token
@property (nonatomic, copy, nullable) NSAttributedString *attributedTruncationToken;

// 设置文本，支持传入NSString和NSAttributedString
- (void)setText:(id _Nullable)text;

// 增加文本，支持传入NSString、NSAttributedString、UIImage和UIView
- (void)append:(id)obj alignment:(XXAttributedAlignment)alignment;
// 默认竖直方向居中对齐
- (void)append:(id)obj;

// 添加自定义链接，支持传入NSString和XXAtributedLableLink
- (void)addCustomLink:(id)linkData forRange:(NSRange)range;

// 计算占用尺寸大小
- (CGSize)sizeThatFits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
