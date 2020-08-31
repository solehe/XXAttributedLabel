//
//  XXAttributedLabel.h
//  XXAttributedLabel
//
//  Created by solehe on 2020/2/29.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <TMAttributedLabel/TMAttributedLabel.h>

typedef void(^LongPressedEndBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface XXAttributedLabel : TMAttributedLabel

// 是否允许长按触发选择，默认为NO
@property (nonatomic, assign) IBInspectable BOOL enableSelected;

// 长按触发选择时间，默认0.5s且不能小于该值
@property (nonatomic, assign) IBInspectable CGFloat activeDuration;

// 是否处于选择状态
@property (nonatomic, assign, getter = isSelecting) BOOL selecting;

// 放大镜是否在展示中
@property (nonatomic, assign) IBInspectable BOOL isDisplayingMagnify;

// 选中背景颜色
@property (nonatomic, strong) IBInspectable UIColor *selectedBackgroundColor;

// 选中范围标记颜色
@property (nonatomic, strong) IBInspectable UIColor *selectedAnchorColor;

// 选中的字符串
@property (nonatomic, strong, readonly) NSString *selectedText;

// 长按链接事件监听
@property (nonatomic, copy) void(^longPressedLinkBlock)(id linkData, LongPressedEndBlock block);

// 放大镜展示监听
@property (nonatomic, copy) void(^magnifyDisplayBlock)(BOOL display);

// 选择视图展示监听
@property (nonatomic, copy) void(^selectingListenBlock)(BOOL selecting);

// 选中文字变化监听
@property (nonatomic, copy) void(^selectedChangeListenBlock)(BOOL isWhole);

@end

NS_ASSUME_NONNULL_END
