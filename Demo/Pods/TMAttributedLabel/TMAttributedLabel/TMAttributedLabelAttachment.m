//
//  TMAtributedLabelAttachment.m
//
//  Created by solehe on 2020/8/15.
//  Copyright © 2020 solehe. All rights reserved.
//

#import "TMAttributedLabelAttachment.h"

void deallocCallback(void * ref)
{
    
}

CGFloat ascentCallback(void *ref)
{
    TMAttributedLabelAttachment *image = (__bridge TMAttributedLabelAttachment *)ref;
//    CGFloat ascent = 0;
//    CGFloat height = [image boxSize].height;
//    switch (image.alignment)
//    {
//        case TMAttributedAlignmentTop:
//            ascent = image.fontAscent;
//            break;
//        case TMAttributedAlignmentCenter:
//        {
//            CGFloat fontAscent  = image.fontAscent;
//            CGFloat fontDescent = image.fontDescent;
//            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
//            ascent = height / 2 + baseLine;
//        }
//            break;
//        case TMAttributedAlignmentBottom:
//            ascent = height - image.fontDescent;
//            break;
//        default:
//            break;
//    }
    return image.fontAscent;
}

CGFloat descentCallback(void *ref)
{
    TMAttributedLabelAttachment *image = (__bridge TMAttributedLabelAttachment *)ref;
//    CGFloat descent = 0;
//    CGFloat height = [image boxSize].height;
//    switch (image.alignment)
//    {
//        case TMAttributedAlignmentTop:
//        {
//            descent = height - image.fontAscent;
//            break;
//        }
//        case TMAttributedAlignmentCenter:
//        {
//            CGFloat fontAscent  = image.fontAscent;
//            CGFloat fontDescent = image.fontDescent;
//            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
//            descent = height / 2 - baseLine;
//        }
//            break;
//        case TMAttributedAlignmentBottom:
//        {
//            descent = image.fontDescent;
//            break;
//        }
//        default:
//            break;
//    }
    
    return image.fontDescent;
}

CGFloat widthCallback(void* ref)
{
    TMAttributedLabelAttachment *image  = (__bridge TMAttributedLabelAttachment *)ref;
    return [image boxSize].width;
}


#pragma mark -

@interface TMAttributedLabelAttachment ()

@end

@implementation TMAttributedLabelAttachment

+ (TMAttributedLabelAttachment *)attachmentWith:(id)content
                                        margin:(UIEdgeInsets)margin
                                     alignment:(TMAttributedAlignment)alignment
                                       maxSize:(CGSize)maxSize {
    TMAttributedLabelAttachment *attachment    = [[TMAttributedLabelAttachment alloc]init];
    attachment.content                          = content;
    attachment.margin                           = margin;
    attachment.alignment                        = alignment;
    attachment.maxSize                          = maxSize;
    return attachment;
}

- (CGSize)boxSize {
    CGSize contentSize = [self attachmentSize];
    if (_maxSize.width > 0 &&_maxSize.height > 0 &&
       contentSize.width > 0 && contentSize.height > 0)
    {
       contentSize = [self calculateContentSize];
    }
    return CGSizeMake(contentSize.width + _margin.left + _margin.right,
                     contentSize.height+ _margin.top  + _margin.bottom);
}

#pragma mark - 辅助方法
- (CGSize)calculateContentSize
{
    CGSize attachmentSize   = [self attachmentSize];
    CGFloat width           = attachmentSize.width;
    CGFloat height          = attachmentSize.height;
    CGFloat newWidth        = _maxSize.width;
    CGFloat newHeight       = _maxSize.height;
    if (width <= newWidth &&
        height<= newHeight)
    {
        return attachmentSize;
    }
    CGSize size;
    if (width / height > newWidth / newHeight)
    {
        size = CGSizeMake(newWidth, newWidth * height / width);
    }
    else
    {
        size = CGSizeMake(newHeight * width / height, newHeight);
    }
    return size;
}

- (CGSize)attachmentSize
{
    CGSize size = CGSizeZero;
    if ([_content isKindOfClass:[UIImage class]])
    {
        size = [((UIImage *)_content) size];
    }
    else if ([_content isKindOfClass:[UIView class]])
    {
        size = [((UIView *)_content) bounds].size;
    }
    return size;
}

@end
