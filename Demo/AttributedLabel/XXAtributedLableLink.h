//
//  XXAtributedLableLink.h
//  Demo
//
//  Created by solehe on 2020/8/15.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XXAtributedLabelLink : NSObject

@property (nonatomic, strong)                   id      linkData;
@property (nonatomic, assign)                   NSRange range;
@property (nonatomic, strong, nullable)         UIColor *color;

+ (XXAtributedLabelLink *)urlWithLinkData:(id)linkData
                                    range:(NSRange)range
                                    color:(nullable UIColor *)color;

@end

NS_ASSUME_NONNULL_END
