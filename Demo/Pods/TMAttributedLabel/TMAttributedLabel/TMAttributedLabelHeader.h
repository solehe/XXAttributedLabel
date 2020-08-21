//
//  TMAttributedLabel.h
//  TMAttributedLabel
//
//  Created by solehe on 2020/8/20.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <Foundation/Foundation.h>

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

//! Project version number for TMAttributedLabel.
FOUNDATION_EXPORT double TMAttributedLabelVersionNumber;

//! Project version string for TMAttributedLabel.
FOUNDATION_EXPORT const unsigned char TMAttributedLabelVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TMAttributedLabel/PublicHeader.h>


