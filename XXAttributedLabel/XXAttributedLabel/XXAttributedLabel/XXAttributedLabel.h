//
//  XXAttributedLabel.h
//  XXAttributedLabel
//
//  Created by solehe on 2020/2/29.
//  Copyright © 2020 solehe. All rights reserved.
//

#import "M80AttributedLabel.h"

typedef void(^LongPressedEndBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface XXAttributedLabel : M80AttributedLabel

// 是否允许长按触发选择，默认为NO
@property (nonatomic, assign) BOOL enableSelected;
// 长按触发选择时间，默认0.5s且不能小于该值
@property (nonatomic, assign) CGFloat activeDuration;
// 选中背景颜色
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
// 选中范围标记颜色
@property (nonatomic, strong) UIColor *selectedAnchorColor;
// 选中的字符串
@property (nonatomic, strong, readonly) NSString *selectedText;
// 长按链接事件监听
@property (nonatomic, copy) void(^longPressedLinkBlock)(id linkData, LongPressedEndBlock block);

@end

NS_ASSUME_NONNULL_END
