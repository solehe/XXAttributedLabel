//
//  TMAtributedLableLink.m
//
//  Created by solehe on 2020/8/15.
//  Copyright © 2020 solehe. All rights reserved.
//

#import "TMAttributedLabelLink.h"

@implementation TMAttributedLabelLink

- (UIColor *)color {
    return self.selected ? self.highlightColor : self.normalColor;
}

+ (TMAttributedLabelLink *)urlWithLinkData:(id)linkData
                                     range:(NSRange)range
                               normalColor:(nullable UIColor *)normalColor
                            highlightColor:(nullable UIColor *)highlightColor {
    
    TMAttributedLabelLink *link  = [[TMAttributedLabelLink alloc] init];
    link.linkData                = linkData;
    link.range                   = range;
    link.normalColor             = normalColor;
    link.highlightColor          = highlightColor;
    return link;
}

@end
