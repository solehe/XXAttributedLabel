//
//  XXAttributedLabelDrawView.h
//  WeTalk
//
//  Created by solehe on 2020/3/3.
//  Copyright © 2020 王金悍. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXAttributedLabelDrawView;
@class XXAttributedLabelTouchView;

NS_ASSUME_NONNULL_BEGIN

@protocol XXAttributedLabelTouchViewDelegate <NSObject>

@optional
- (void)touchView:(XXAttributedLabelTouchView *)touchView begain:(CGPoint)point;
- (void)touchView:(XXAttributedLabelTouchView *)touchView moved:(CGPoint)point;
- (void)touchView:(XXAttributedLabelTouchView *)touchView cancelled:(CGPoint)point;
- (void)touchView:(XXAttributedLabelTouchView *)touchView ended:(CGPoint)point;

@end

@interface XXAttributedLabelTouchView : UIView

@property (nonatomic, weak) id<XXAttributedLabelTouchViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
