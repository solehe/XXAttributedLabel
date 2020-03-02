//
//  XXAttributedLabelMagnifyView.h
//  XXAttributedLabel
//
//  Created by solehe on 2020/3/1.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XXAttributedLabelMagnifyView : UIView

// 需要放大的视图
@property (nonatomic, weak) UIView *view;
// 需要放大的点
@property (nonatomic, assign, readonly) CGPoint magnifyPoint;

// 更新放大位置
- (void)refreshCenter:(CGPoint)center magnifyPoint:(CGPoint)magnifyPoint;

@end

NS_ASSUME_NONNULL_END
