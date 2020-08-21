//
//  XXAttributedLabelDrawView.h
//  XXAttributedLabel
//
//  Created by solehe on 2020/2/29.
//  Copyright © 2020 solehe. All rights reserved.
//


#import <UIKit/UIKit.h>

@class XXAttributedLabel;

NS_ASSUME_NONNULL_BEGIN

@interface XXAttributedLabelDrawView : UIView

// 所在的label
@property (nonatomic, weak) XXAttributedLabel *label;
// 是否处于选中状态
@property (nonatomic, assign) BOOL selecting;
// 选中范围
@property (nonatomic, assign, readonly) NSRange selecedRange;
// 放大镜展示监听
@property (nonatomic, copy) void(^DisplayMagnifyViewBlock)(BOOL display);
// 选中范围变化监听
@property (nonatomic, copy, nullable) void(^SelectedRangeChangedBlock)(NSRange range);

@end

NS_ASSUME_NONNULL_END
