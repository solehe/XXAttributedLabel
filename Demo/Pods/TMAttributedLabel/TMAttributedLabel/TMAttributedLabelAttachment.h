//
//  TMAtributedLabelAttachment.h
//
//  Created by solehe on 2020/8/15.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TMAttributedLabelHeader.h"

NS_ASSUME_NONNULL_BEGIN

void deallocCallback(void* ref);
CGFloat ascentCallback(void *ref);
CGFloat descentCallback(void *ref);
CGFloat widthCallback(void* ref);

@interface TMAttributedLabelAttachment : NSObject

@property (nonatomic,strong)    id                      content;
@property (nonatomic,assign)    UIEdgeInsets            margin;
@property (nonatomic,assign)    TMAttributedAlignment   alignment;
@property (nonatomic,assign)    CGFloat                 fontAscent;
@property (nonatomic,assign)    CGFloat                 fontDescent;
@property (nonatomic,assign)    CGFloat                 lineHeight;
@property (nonatomic,assign)    CGSize                  maxSize;

+ (TMAttributedLabelAttachment *)attachmentWith:(id)content
                                        margin:(UIEdgeInsets)margin
                                     alignment:(TMAttributedAlignment)alignment
                                       maxSize:(CGSize)maxSize;

- (CGSize)boxSize;

@end

NS_ASSUME_NONNULL_END
