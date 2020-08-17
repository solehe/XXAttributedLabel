//
//  M80AttributedLabel+M80.h
//  XXAttributedLabel
//
//  Created by solehe on 2020/3/2.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "TMAttributedLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMAttributedLabel (XX)

//计算需要绘制内容的frame
@property (nonatomic,assign) CTFrameRef textFrameRef;

@end

NS_ASSUME_NONNULL_END
