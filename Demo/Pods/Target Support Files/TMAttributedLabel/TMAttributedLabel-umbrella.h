#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSMutableAttributedString+TM.h"
#import "TMAttributedLabel.h"
#import "TMAttributedLabelAttachment.h"
#import "TMAttributedLabelHeader.h"
#import "TMAttributedLabelLink.h"

FOUNDATION_EXPORT double TMAttributedLabelVersionNumber;
FOUNDATION_EXPORT const unsigned char TMAttributedLabelVersionString[];

