//
//  TMAtributedLableLink.h
//
//  Created by solehe on 2020/8/15.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMAttributedLabelLink : NSObject

@property (nonatomic, assign) BOOL    selected;
@property (nonatomic, strong) id      linkData;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightColor;

- (UIColor *)color;

+ (TMAttributedLabelLink *)urlWithLinkData:(id)linkData
                                     range:(NSRange)range
                               normalColor:(nullable UIColor *)normalColor
                            highlightColor:(nullable UIColor *)highlightColor;

@end

NS_ASSUME_NONNULL_END
