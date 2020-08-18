//
//  TMAtributedLabelHeader.h
//
//  Created by solehe on 2020/8/15.
//  Copyright © 2020 solehe. All rights reserved.
//

#ifndef TMAtributedLabelHeader_h
#define TMAtributedLabelHeader_h

@class TMAttributedLabel;

/**
 竖直方向对齐方式
 */
typedef NS_ENUM(NSInteger, TMAttributedAlignment) {
    TMAttributedAlignmentCenter   = 0,
    TMAttributedAlignmentTop      = 1,
    TMAttributedAlignmentBottom   = 2,
};

/**
 TMAttributedLabel代理
 */
@protocol TMAttributedLabelDelegate <NSObject>

@optional
- (void)attributedLabel:(TMAttributedLabel *)label clickedOnLink:(id)linkData;

@end

#endif /* TMAtributedLabelHeader_h */
