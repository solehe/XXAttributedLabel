//
//  M80AttributedLabel+M80.h
//  XXAttributedLabel
//
//  Created by solehe on 2020/3/2.
//  Copyright © 2020 solehe. All rights reserved.
//

#import "M80AttributedLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface M80AttributedLabel (M80)

//计算需要绘制内容的frame
@property (nonatomic,assign) CTFrameRef textFrameRef;

@end

NS_ASSUME_NONNULL_END
