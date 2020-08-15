//
//  AttributedLabel.m
//  Demo
//
//  Created by solehe on 2020/8/15.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <Availability.h>

#import "XXAtributedLabelAttachment.h"
#import "AttributedLabel.h"

#define kXXLineBreakWordWrapTextWidthScalingFactor (M_PI / M_E)

static CGFloat const XXFLOAT_MAX = 100000;

NSString * const kXXStrikeOutAttributeName = @"XXStrikeOutAttribute";
NSString * const kXXBackgroundFillColorAttributeName = @"XXBackgroundFillColor";
NSString * const kXXBackgroundFillPaddingAttributeName = @"XXBackgroundFillPadding";
NSString * const kXXBackgroundStrokeColorAttributeName = @"XXBackgroundStrokeColor";
NSString * const kXXBackgroundLineWidthAttributeName = @"XXBackgroundLineWidth";
NSString * const kXXBackgroundCornerRadiusAttributeName = @"XXBackgroundCornerRadius";

static inline CTTextAlignment CTTextAlignmentFromTTTTextAlignment(NSTextAlignment alignment) {
    switch (alignment) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
        case NSTextAlignmentLeft: return kCTTextAlignmentLeft;
        case NSTextAlignmentCenter: return kCTTextAlignmentCenter;
        case NSTextAlignmentRight: return kCTTextAlignmentRight;
        default: return kCTTextAlignmentNatural;
#else
        case NSTextAlignmentLeft: return kCTLeftTextAlignment;
        case NSTextAlignmentCenter: return kCTCenterTextAlignment;
        case NSTextAlignmentRight: return kCTRightTextAlignment;
        default: return kCTNaturalTextAlignment;
#endif
    }
}

static inline CTLineBreakMode CTLineBreakModeFromTTTLineBreakMode(NSLineBreakMode lineBreakMode) {
    switch (lineBreakMode) {
        case NSLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
        case NSLineBreakByCharWrapping: return kCTLineBreakByCharWrapping;
        case NSLineBreakByClipping: return kCTLineBreakByClipping;
        case NSLineBreakByTruncatingHead: return kCTLineBreakByTruncatingHead;
        case NSLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
        case NSLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
        default: return 0;
    }
}

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_floor(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return floor(cgfloat);
#else
    return floorf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_round(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return round(cgfloat);
#else
    return roundf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_sqrt(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return sqrt(cgfloat);
#else
    return sqrtf(cgfloat);
#endif
}

static inline CGFloat XXFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
    switch (textAlignment) {
        case NSTextAlignmentCenter:
            return 0.5f;
        case NSTextAlignmentRight:
            return 1.0f;
        case NSTextAlignmentLeft:
        default:
            return 0.0f;
    }
}

static inline NSDictionary * NSAttributedStringAttributesFromLabel(AttributedLabel *label) {
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];

    if ([NSMutableParagraphStyle class]) {
        [mutableAttributes setObject:label.font forKey:(NSString *)kCTFontAttributeName];
        [mutableAttributes setObject:label.textColor forKey:(NSString *)kCTForegroundColorAttributeName];

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = label.textAlignment;
        paragraphStyle.lineSpacing = label.lineSpacing;
        paragraphStyle.minimumLineHeight = label.minimumLineHeight > 0 ? label.minimumLineHeight : label.font.lineHeight * label.lineHeightMultiple;
        paragraphStyle.maximumLineHeight = label.maximumLineHeight > 0 ? label.maximumLineHeight : label.font.lineHeight * label.lineHeightMultiple;
        paragraphStyle.lineHeightMultiple = label.lineHeightMultiple;

        if (label.numberOfLines == 1) {
            paragraphStyle.lineBreakMode = label.lineBreakMode;
        } else {
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        }

        [mutableAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
    } else {
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)label.font.fontName, label.font.pointSize, NULL);
        [mutableAttributes setObject:(__bridge id)font forKey:(NSString *)kCTFontAttributeName];
        CFRelease(font);

        [mutableAttributes setObject:(id)[label.textColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];

        CTTextAlignment alignment = CTTextAlignmentFromTTTTextAlignment(label.textAlignment);
        CGFloat lineSpacing = label.lineSpacing;
        CGFloat minimumLineHeight = label.minimumLineHeight * label.lineHeightMultiple;
        CGFloat maximumLineHeight = label.maximumLineHeight * label.lineHeightMultiple;
        CGFloat lineSpacingAdjustment = CGFloat_ceil(label.font.lineHeight - label.font.ascender + label.font.descender);
        CGFloat lineHeightMultiple = label.lineHeightMultiple;

        CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
        if (label.numberOfLines == 1) {
            lineBreakMode = CTLineBreakModeFromTTTLineBreakMode(label.lineBreakMode);
        }

        CTParagraphStyleSetting paragraphStyles[12] = {
            {.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void *)&alignment},
            {.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void *)&lineBreakMode},
            {.spec = kCTParagraphStyleSpecifierLineSpacing, .valueSize = sizeof(CGFloat), .value = (const void *)&lineSpacing},
            {.spec = kCTParagraphStyleSpecifierMinimumLineSpacing, .valueSize = sizeof(CGFloat), .value = (const void *)&minimumLineHeight},
            {.spec = kCTParagraphStyleSpecifierMaximumLineSpacing, .valueSize = sizeof(CGFloat), .value = (const void *)&maximumLineHeight},
            {.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment, .valueSize = sizeof (CGFloat), .value = (const void *)&lineSpacingAdjustment},
            {.spec = kCTParagraphStyleSpecifierLineHeightMultiple, .valueSize = sizeof(CGFloat), .value = (const void *)&lineHeightMultiple},
        };

        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphStyles, 12);

        [mutableAttributes setObject:(__bridge id)paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];

        CFRelease(paragraphStyle);
    }

    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

static inline CGColorRef CGColorRefFromColor(id color);
static inline NSDictionary * convertNSAttributedStringAttributesToCTAttributes(NSDictionary *attributes);

static inline NSAttributedString * NSAttributedStringByScalingFontSize(NSAttributedString *attributedString, CGFloat scale) {
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    [mutableAttributedString enumerateAttribute:(NSString *)kCTFontAttributeName inRange:NSMakeRange(0, [mutableAttributedString length]) options:0 usingBlock:^(id value, NSRange range, BOOL * __unused stop) {
        UIFont *font = (UIFont *)value;
        if (font) {
            NSString *fontName;
            CGFloat pointSize;

            if ([font isKindOfClass:[UIFont class]]) {
                fontName = font.fontName;
                pointSize = font.pointSize;
            } else {
                fontName = (NSString *)CFBridgingRelease(CTFontCopyName((__bridge CTFontRef)font, kCTFontPostScriptNameKey));
                pointSize = CTFontGetSize((__bridge CTFontRef)font);
            }

            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:range];
            CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, CGFloat_floor(pointSize * scale), NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }];

    return mutableAttributedString;
}

static inline NSMutableAttributedString * NSAttributedStringBySettingColorFromContext(NSAttributedString *attributedString, UIColor *color) {
    
    if (!color) {
        return attributedString;
    }

    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    [mutableAttributedString enumerateAttribute:(NSString *)kCTForegroundColorFromContextAttributeName inRange:NSMakeRange(0, [mutableAttributedString length]) options:0 usingBlock:^(id value, NSRange range, __unused BOOL *stop) {
        BOOL usesColorFromContext = (BOOL)value;
        if (usesColorFromContext) {
            [mutableAttributedString setAttributes:[NSDictionary dictionaryWithObject:color forKey:(NSString *)kCTForegroundColorAttributeName] range:range];
            [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorFromContextAttributeName range:range];
        }
    }];

    return mutableAttributedString;
}

static inline CGSize CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {
    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    CGSize constraints = CGSizeMake(size.width, XXFLOAT_MAX);

    if (numberOfLines == 1) {
        // If there is one line, the size that fits is the full width of the line
        constraints = CGSizeMake(XXFLOAT_MAX, XXFLOAT_MAX);
    } else if (numberOfLines > 0) {
        // If the line count of the label more than 1, limit the range to size to the number of lines that have been set
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, XXFLOAT_MAX));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);

        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);

            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }

        CFRelease(frame);
        CGPathRelease(path);
    }

    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);

    return CGSizeMake(CGFloat_ceil(suggestedSize.width), CGFloat_ceil(suggestedSize.height));
}


@interface AttributedLabel ()

@property (nonatomic, assign)   BOOL                needsFramesetter;
@property (nonatomic, assign)   CTFramesetterRef    framesetter;
@property (nonatomic, strong)   NSMutableArray      *attachments;
@property (nonatomic, copy)     NSMutableAttributedString  *renderedAttributedText;

@end

@implementation AttributedLabel

@dynamic text;
@synthesize framesetter = _framesetter;
@synthesize attributedText = _attributedText;

- (void)dealloc {
    if (_framesetter) {
        CFRelease(_framesetter);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.attachments = [NSMutableArray array];
    
    self.textInsets = UIEdgeInsetsZero;
    self.lineHeightMultiple = 1.0f;
    
    self.userInteractionEnabled = YES;
}

#pragma mark -

- (void)setText:(id)text {
    if ([text isKindOfClass:[NSString class]]) {
        [self setAttributedText:[[NSMutableAttributedString alloc] initWithString:text attributes:NSAttributedStringAttributesFromLabel(self)]];
    } else if ([text isKindOfClass:[NSAttributedString class]]) {
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        NSRange range = NSMakeRange(0, [mutableAttributedString length]);
        [mutableAttributedString addAttributes:NSAttributedStringAttributesFromLabel(self) range:range];
        [self setAttributedText:mutableAttributedString];
    } else {
        NSLog(@"【XXAtributedLabel】错误的类型");
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    
    if ([attributedText isEqualToAttributedString:_attributedText]) {
        return;
    }

    _attributedText = [attributedText copy];

    [self setNeedsFramesetter];
    [self setNeedsDisplay];

    if ([self respondsToSelector:@selector(invalidateIntrinsicContentSize)]) {
        [self invalidateIntrinsicContentSize];
    }

    [super setText:[self.attributedText string]];
}

// 增加文本，支持传入NSString、NSAttributedString、UIImage和UIView
- (void)append:(id)obj alignment:(XXAttributedAlignment)alignment {
    CGSize size = [obj isKindOfClass:[UIImage class]] ? ((UIImage *)obj).size : CGSizeZero;
    XXAttributedLabelAttachment *attachment = [XXAttributedLabelAttachment attachmentWith:obj
                                                                                   margin:UIEdgeInsetsZero
                                                                                alignment:alignment
                                                                                  maxSize:size];
    [self appendAttachment:attachment];
}

- (void)appendAttachment:(XXAttributedLabelAttachment *)attachment {
    
    attachment.fontAscent                   = self.font.ascender;
    attachment.fontDescent                  = self.font.descender;
    unichar objectReplacementChar           = 0xFFFC;
    NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *attachText   = [[NSMutableAttributedString alloc]initWithString:objectReplacementString];
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version       = kCTRunDelegateVersion1;
    callbacks.getAscent     = ascentCallback;
    callbacks.getDescent    = descentCallback;
    callbacks.getWidth      = widthCallback;
    callbacks.dealloc       = deallocCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (void *)attachment);
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)delegate,kCTRunDelegateAttributeName, nil];
    [attachText setAttributes:attr range:NSMakeRange(0, 1)];
    CFRelease(delegate);
    
    [_attachments addObject:attachment];
    [self appendAttributedText:attachText];
}

- (void)appendAttributedText:(NSAttributedString *)attributedText
{
    NSMutableAttributedString *mutableAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [mutableAttributedText appendAttributedString:attributedText];
    [self setAttributedText:[mutableAttributedText copy]];
}

// 默认竖直方向居中对齐
- (void)append:(id)obj {
    [self append:obj alignment:XXAttributedAlignmentCenter];
}

#pragma mark -

- (void)setNeedsFramesetter {
    _renderedAttributedText = nil;
    _needsFramesetter = YES;
}

- (CTFramesetterRef)framesetter {
    if (_needsFramesetter) {
        @synchronized(self) {
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.renderedAttributedText);
            [self setFramesetter:framesetter];
            _needsFramesetter = NO;

            if (framesetter) {
                CFRelease(framesetter);
            }
        }
    }

    return _framesetter;
}

- (void)setFramesetter:(CTFramesetterRef)framesetter {
    
    if (framesetter) {
        CFRetain(framesetter);
    }

    if (_framesetter) {
        CFRelease(_framesetter);
    }

    _framesetter = framesetter;
}

- (NSAttributedString *)renderedAttributedText {
    if (!_renderedAttributedText) {
        self.renderedAttributedText = NSAttributedStringBySettingColorFromContext(self.attributedText, self.textColor);
    }

    return _renderedAttributedText;
}

#pragma mark -

- (CGSize)sizeThatFits:(CGSize)size {
    
    if (!self.attributedText) {
        
        return [super sizeThatFits:size];
        
    } else {

        NSAttributedString *string = [[NSAttributedString alloc] initWithAttributedString:self.attributedText];
        
        CGSize labelSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints([self framesetter], string, size, (NSUInteger)self.numberOfLines);
        labelSize.width += self.textInsets.left + self.textInsets.right;
        labelSize.height += self.textInsets.top + self.textInsets.bottom;

        return labelSize;
    }
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:[super intrinsicContentSize]];
}

- (CGRect)textRectForBounds:(CGRect)bounds
     limitedToNumberOfLines:(NSInteger)numberOfLines {
    
    bounds = UIEdgeInsetsInsetRect(bounds, self.textInsets);
    if (!self.attributedText) {
        return [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    }

    CGRect textRect = bounds;

    // Calculate height with a minimum of double the font pointSize, to ensure that CTFramesetterSuggestFrameSizeWithConstraints doesn't return CGSizeZero, as it would if textRect height is insufficient.
    textRect.size.height = MAX(self.font.lineHeight * MAX(2, numberOfLines), bounds.size.height);

    // Adjust the text to be in the center vertically, if the text size is smaller than bounds
    CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints([self framesetter], CFRangeMake(0, (CFIndex)[self.attributedText length]), NULL, textRect.size, NULL);
    textSize = CGSizeMake(CGFloat_ceil(textSize.width), CGFloat_ceil(textSize.height)); // Fix for iOS 4, CTFramesetterSuggestFrameSizeWithConstraints sometimes returns fractional sizes

    if (textSize.height < bounds.size.height) {
        CGFloat yOffset = 0.0f;
        switch (self.verticalAlignment) {
            case XXAttributedAlignmentCenter:
                yOffset = CGFloat_floor((bounds.size.height - textSize.height) / 2.0f);
                break;
            case XXAttributedAlignmentBottom:
                yOffset = bounds.size.height - textSize.height;
                break;
            case XXAttributedAlignmentTop:
            default:
                break;
        }

        textRect.origin.y += yOffset;
    }

    return textRect;
}

#pragma mark -

- (void)drawTextInRect:(CGRect)rect {
    
    CGRect insetRect = UIEdgeInsetsInsetRect(rect, self.textInsets);
    if (!self.attributedText) {
        [super drawTextInRect:insetRect];
        return;
    }
    
    NSAttributedString *originalAttributedText = nil;

    // Adjust the font size to fit width, if necessarry
    if (self.adjustsFontSizeToFitWidth && self.numberOfLines > 0) {
        // Framesetter could still be working with a resized version of the text;
        // need to reset so we start from the original font size.
        // See #393.
        [self setNeedsFramesetter];
        [self setNeedsDisplay];
        
        if ([self respondsToSelector:@selector(invalidateIntrinsicContentSize)]) {
            [self invalidateIntrinsicContentSize];
        }
        
        // Use infinite width to find the max width, which will be compared to availableWidth if needed.
        CGSize maxSize = (self.numberOfLines > 1) ? CGSizeMake(XXFLOAT_MAX, XXFLOAT_MAX) : CGSizeZero;

        CGFloat textWidth = [self sizeThatFits:maxSize].width;
        CGFloat availableWidth = self.frame.size.width * self.numberOfLines;
        if (self.numberOfLines > 1 && self.lineBreakMode == NSLineBreakByWordWrapping) {
            textWidth *= kXXLineBreakWordWrapTextWidthScalingFactor;
        }

        if (textWidth > availableWidth && textWidth > 0.0f) {
            originalAttributedText = [self.attributedText copy];

            CGFloat scaleFactor = availableWidth / textWidth;
            if ([self respondsToSelector:@selector(minimumScaleFactor)] && self.minimumScaleFactor > scaleFactor) {
                scaleFactor = self.minimumScaleFactor;
            }

            self.attributedText = NSAttributedStringByScalingFontSize(self.attributedText, scaleFactor);
        }
    }

    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    {
        CGContextSetTextMatrix(c, CGAffineTransformIdentity);

        // Inverts the CTM to match iOS coordinates (otherwise text draws upside-down; Mac OS's system is different)
        CGContextTranslateCTM(c, 0.0f, insetRect.size.height);
        CGContextScaleCTM(c, 1.0f, -1.0f);

        CFRange textRange = CFRangeMake(0, (CFIndex)[self.attributedText length]);

        // First, get the text rect (which takes vertical centering into account)
        CGRect textRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];

        // CoreText draws its text aligned to the bottom, so we move the CTM here to take our vertical offsets into account
        CGContextTranslateCTM(c, insetRect.origin.x, insetRect.size.height - textRect.origin.y - textRect.size.height);


        // Finally, draw the text or highlighted text itself (on top of the shadow, if there is one)
        [self drawFramesetter:[self framesetter] attributedString:self.renderedAttributedText textRange:textRange inRect:textRect context:c];

        // If we adjusted the font size, set it back to its original size
        if (originalAttributedText) {
            // Use ivar directly to avoid clearing out framesetter and renderedAttributedText
            _attributedText = originalAttributedText;
        }
    }
    CGContextRestoreGState(c);
}

- (void)drawFramesetter:(CTFramesetterRef)framesetter
       attributedString:(NSAttributedString *)attributedString
              textRange:(CFRange)textRange
                 inRect:(CGRect)rect
                context:(CGContextRef)c {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, path, NULL);
    
    [self drawBackground:frame inRect:rect context:c];
    
    [self drawAttachments:frame inRect:rect context:c];

    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    BOOL truncateLastLine = (self.lineBreakMode == NSLineBreakByTruncatingHead || self.lineBreakMode == NSLineBreakByTruncatingMiddle || self.lineBreakMode == NSLineBreakByTruncatingTail);

    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);

    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CGContextSetTextPosition(c, lineOrigin.x, lineOrigin.y);
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);

        CGFloat descent = 0.0f;
        CTLineGetTypographicBounds((CTLineRef)line, NULL, &descent, NULL);

        // Adjust pen offset for flush depending on text alignment
        CGFloat flushFactor = XXFlushFactorForTextAlignment(self.textAlignment);

        if (lineIndex == numberOfLines - 1 && truncateLastLine) {
            // Check if the range of text in the last line reaches the end of the full attributed string
            CFRange lastLineRange = CTLineGetStringRange(line);

            if (!(lastLineRange.length == 0 && lastLineRange.location == 0) && lastLineRange.location + lastLineRange.length < textRange.location + textRange.length) {
                // Get correct truncationType and attribute position
                CTLineTruncationType truncationType;
                CFIndex truncationAttributePosition = lastLineRange.location;
                NSLineBreakMode lineBreakMode = self.lineBreakMode;

                // Multiple lines, only use UILineBreakModeTailTruncation
                if (numberOfLines != 1) {
                    lineBreakMode = NSLineBreakByTruncatingTail;
                }

                switch (lineBreakMode) {
                    case NSLineBreakByTruncatingHead:
                        truncationType = kCTLineTruncationStart;
                        break;
                    case NSLineBreakByTruncatingMiddle:
                        truncationType = kCTLineTruncationMiddle;
                        truncationAttributePosition += (lastLineRange.length / 2);
                        break;
                    case NSLineBreakByTruncatingTail:
                    default:
                        truncationType = kCTLineTruncationEnd;
                        truncationAttributePosition += (lastLineRange.length - 1);
                        break;
                }

                NSAttributedString *attributedTruncationString = self.attributedTruncationToken;
                if (!attributedTruncationString) {
                    NSString *truncationTokenString = @"\u2026"; // Unicode Character 'HORIZONTAL ELLIPSIS' (U+2026)
                    
                    NSDictionary *truncationTokenStringAttributes = truncationTokenStringAttributes = [attributedString attributesAtIndex:(NSUInteger)truncationAttributePosition effectiveRange:NULL];
                    
                    attributedTruncationString = [[NSAttributedString alloc] initWithString:truncationTokenString attributes:truncationTokenStringAttributes];
                }
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTruncationString);

                // Append truncationToken to the string
                // because if string isn't too long, CT won't add the truncationToken on its own.
                // There is no chance of a double truncationToken because CT only adds the
                // token if it removes characters (and the one we add will go first)
                NSMutableAttributedString *truncationString = [[NSMutableAttributedString alloc] initWithAttributedString:
                                                               [attributedString attributedSubstringFromRange:
                                                                NSMakeRange((NSUInteger)lastLineRange.location,
                                                                            (NSUInteger)lastLineRange.length)]];
                if (lastLineRange.length > 0) {
                    // Remove any newline at the end (we don't want newline space between the text and the truncation token). There can only be one, because the second would be on the next line.
                    unichar lastCharacter = [[truncationString string] characterAtIndex:(NSUInteger)(lastLineRange.length - 1)];
                    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
                        [truncationString deleteCharactersInRange:NSMakeRange((NSUInteger)(lastLineRange.length - 1), 1)];
                    }
                }
                [truncationString appendAttributedString:attributedTruncationString];
                CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);

                // Truncate the line in case it is too long.
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                if (!truncatedLine) {
                    // If the line is not as wide as the truncationToken, truncatedLine is NULL
                    truncatedLine = CFRetain(truncationToken);
                }

                CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(truncatedLine, flushFactor, rect.size.width);
                CGContextSetTextPosition(c, penOffset, lineOrigin.y - descent - self.font.descender);

                CTLineDraw(truncatedLine, c);
                
                /*
                NSRange linkRange;
                if ([attributedTruncationString attribute:NSLinkAttributeName atIndex:0 effectiveRange:&linkRange]) {
                    NSRange tokenRange = [truncationString.string rangeOfString:attributedTruncationString.string];
                    NSRange tokenLinkRange = NSMakeRange((NSUInteger)(lastLineRange.location+lastLineRange.length)-tokenRange.length, (NSUInteger)tokenRange.length);
                    
                    [self addLinkToURL:[attributedTruncationString attribute:NSLinkAttributeName atIndex:0 effectiveRange:&linkRange] withRange:tokenLinkRange];
                }
                 */

                CFRelease(truncatedLine);
                CFRelease(truncationLine);
                CFRelease(truncationToken);
            } else {
                CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
                CGContextSetTextPosition(c, penOffset, lineOrigin.y - descent - self.font.descender);
                CTLineDraw(line, c);
            }
        } else {
            CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
            CGContextSetTextPosition(c, penOffset, lineOrigin.y - descent - self.font.descender);
            CTLineDraw(line, c);
        }
    }

    [self drawStrike:frame inRect:rect context:c];

    CFRelease(frame);
    CGPathRelease(path);
}

- (void)drawAttachments:(CTFrameRef)frame
                 inRect:(CGRect)rect
                context:(CGContextRef)ctx {
    
    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    for (CFIndex i = 0; i < numberOfLines; i++)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        CGPoint lineOrigin = lineOrigins[i];
        CGFloat lineAscent;
        CGFloat lineDescent;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
        CGFloat lineHeight = lineAscent + lineDescent;
        CGFloat lineBottomY = lineOrigin.y - lineDescent;
        
        //遍历找到对应的 attachment 进行绘制
        for (CFIndex k = 0; k < runCount; k++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(runs, k);
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (nil == delegate)
            {
                continue;
            }
            XXAttributedLabelAttachment* attributedImage = (XXAttributedLabelAttachment *)CTRunDelegateGetRefCon(delegate);
            
            CGFloat ascent = 0.0f;
            CGFloat descent = 0.0f;
            CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                               CFRangeMake(0, 0),
                                                               &ascent,
                                                               &descent,
                                                               NULL);
            
            CGFloat imageBoxHeight = [attributedImage boxSize].height;
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
            
            CGFloat imageBoxOriginY = 0.0f;
            switch (attributedImage.alignment)
            {
                case XXAttributedAlignmentTop:
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight);
                    break;
                case XXAttributedAlignmentCenter:
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight) / 2.0;
                    break;
                case XXAttributedAlignmentBottom:
                    imageBoxOriginY = lineBottomY;
                    break;
            }
            
            CGFloat offsetY = rect.origin.y - self.textInsets.top - self.textInsets.bottom;
            CGRect viewRect = CGRectMake(lineOrigin.x + xOffset + self.textInsets.left, imageBoxOriginY - offsetY, width, imageBoxHeight);
            UIEdgeInsets flippedMargins = attributedImage.margin;
            CGFloat top = flippedMargins.top;
            flippedMargins.top = flippedMargins.bottom;
            flippedMargins.bottom = top;
            
            CGRect attatchmentRect = UIEdgeInsetsInsetRect(viewRect, flippedMargins);
            
            if (self.numberOfLines > 0 &&
                i == numberOfLines - 1 &&
                k >= runCount - 2 &&
                self.lineBreakMode == NSLineBreakByTruncatingTail)
            {
                //最后行最后的2个CTRun需要做额外判断
                CGFloat attachmentWidth = CGRectGetWidth(attatchmentRect);
                const CGFloat kMinEllipsesWidth = attachmentWidth;
                if (CGRectGetWidth(self.bounds) - CGRectGetMinX(attatchmentRect) - attachmentWidth <  kMinEllipsesWidth)
                {
                    continue;
                }
            }
            
            id content = attributedImage.content;
            if ([content isKindOfClass:[UIImage class]])
            {
                CGRect imageRect = CGRectMake(lineOrigin.x + xOffset, imageBoxOriginY, width, imageBoxHeight);
                CGRect attatchmentImageRect = UIEdgeInsetsInsetRect(imageRect, flippedMargins);
                
                CGContextDrawImage(ctx, attatchmentImageRect, ((UIImage *)content).CGImage);
            }
            else if ([content isKindOfClass:[UIView class]])
            {
                UIView *view = (UIView *)content;
                if (view.superview == nil)
                {
                    [self addSubview:view];
                }
                CGRect viewFrame = CGRectMake(attatchmentRect.origin.x,
                                              self.bounds.size.height - attatchmentRect.origin.y - attatchmentRect.size.height,
                                              attatchmentRect.size.width,
                                              attatchmentRect.size.height);
                [view setFrame:viewFrame];
            }
            else
            {
                NSLog(@"Attachment Content Not Supported %@",content);
            }
            
        }
    }
}

- (void)drawBackground:(CTFrameRef)frame
                inRect:(CGRect)rect
               context:(CGContextRef)c {
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);

    CFIndex lineIndex = 0;
    for (id line in lines) {
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds((__bridge CTLineRef)line, &ascent, &descent, &leading) ;

        for (id glyphRun in (__bridge NSArray *)CTLineGetGlyphRuns((__bridge CTLineRef)line)) {
            NSDictionary *attributes = (__bridge NSDictionary *)CTRunGetAttributes((__bridge CTRunRef) glyphRun);
            CGColorRef strokeColor = CGColorRefFromColor([attributes objectForKey:kXXBackgroundStrokeColorAttributeName]);
            CGColorRef fillColor = CGColorRefFromColor([attributes objectForKey:kXXBackgroundFillColorAttributeName]);
            UIEdgeInsets fillPadding = [[attributes objectForKey:kXXBackgroundFillPaddingAttributeName] UIEdgeInsetsValue];
            CGFloat cornerRadius = [[attributes objectForKey:kXXBackgroundCornerRadiusAttributeName] floatValue];
            CGFloat lineWidth = [[attributes objectForKey:kXXBackgroundLineWidthAttributeName] floatValue];

            if (strokeColor || fillColor) {
                CGRect runBounds = CGRectZero;
                CGFloat runAscent = 0.0f;
                CGFloat runDescent = 0.0f;

                runBounds.size.width = (CGFloat)CTRunGetTypographicBounds((__bridge CTRunRef)glyphRun, CFRangeMake(0, 0), &runAscent, &runDescent, NULL) + fillPadding.left + fillPadding.right;
                runBounds.size.height = runAscent + runDescent + fillPadding.top + fillPadding.bottom;

                CGFloat xOffset = 0.0f;
                CFRange glyphRange = CTRunGetStringRange((__bridge CTRunRef)glyphRun);
                switch (CTRunGetStatus((__bridge CTRunRef)glyphRun)) {
                    case kCTRunStatusRightToLeft:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location + glyphRange.length, NULL);
                        break;
                    default:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location, NULL);
                        break;
                }

                runBounds.origin.x = origins[lineIndex].x + rect.origin.x + xOffset - fillPadding.left - rect.origin.x;
                runBounds.origin.y = origins[lineIndex].y + rect.origin.y - fillPadding.bottom - rect.origin.y;
                runBounds.origin.y -= runDescent;

                // Don't draw higlightedLinkBackground too far to the right
                if (CGRectGetWidth(runBounds) > width) {
                    runBounds.size.width = width;
                }

                CGPathRef path = [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(UIEdgeInsetsInsetRect(runBounds, UIEdgeInsetsZero), lineWidth, lineWidth) cornerRadius:cornerRadius] CGPath];

                CGContextSetLineJoin(c, kCGLineJoinRound);

                if (fillColor) {
                    CGContextSetFillColorWithColor(c, fillColor);
                    CGContextAddPath(c, path);
                    CGContextFillPath(c);
                }

                if (strokeColor) {
                    CGContextSetStrokeColorWithColor(c, strokeColor);
                    CGContextAddPath(c, path);
                    CGContextStrokePath(c);
                }
            }
        }

        lineIndex++;
    }
}

- (void)drawStrike:(CTFrameRef)frame
            inRect:(__unused CGRect)rect
           context:(CGContextRef)c {
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);

    CFIndex lineIndex = 0;
    for (id line in lines) {
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds((__bridge CTLineRef)line, &ascent, &descent, &leading) ;

        for (id glyphRun in (__bridge NSArray *)CTLineGetGlyphRuns((__bridge CTLineRef)line)) {
            NSDictionary *attributes = (__bridge NSDictionary *)CTRunGetAttributes((__bridge CTRunRef) glyphRun);
            BOOL strikeOut = [[attributes objectForKey:kXXStrikeOutAttributeName] boolValue];
            NSInteger superscriptStyle = [[attributes objectForKey:(id)kCTSuperscriptAttributeName] integerValue];

            if (strikeOut) {
                CGRect runBounds = CGRectZero;
                CGFloat runAscent = 0.0f;
                CGFloat runDescent = 0.0f;

                runBounds.size.width = (CGFloat)CTRunGetTypographicBounds((__bridge CTRunRef)glyphRun, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
                runBounds.size.height = runAscent + runDescent;

                CGFloat xOffset = 0.0f;
                CFRange glyphRange = CTRunGetStringRange((__bridge CTRunRef)glyphRun);
                switch (CTRunGetStatus((__bridge CTRunRef)glyphRun)) {
                    case kCTRunStatusRightToLeft:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location + glyphRange.length, NULL);
                        break;
                    default:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location, NULL);
                        break;
                }
                runBounds.origin.x = origins[lineIndex].x + xOffset;
                runBounds.origin.y = origins[lineIndex].y;
                runBounds.origin.y -= runDescent;

                // Don't draw strikeout too far to the right
                if (CGRectGetWidth(runBounds) > width) {
                    runBounds.size.width = width;
                }

                switch (superscriptStyle) {
                    case 1:
                        runBounds.origin.y -= runAscent * 0.47f;
                        break;
                    case -1:
                        runBounds.origin.y += runAscent * 0.25f;
                        break;
                    default:
                        break;
                }

                // Use text color, or default to black
                id color = [attributes objectForKey:(id)kCTForegroundColorAttributeName];
                if (color) {
                    CGContextSetStrokeColorWithColor(c, CGColorRefFromColor(color));
                } else {
                    CGContextSetGrayStrokeColor(c, 0.0f, 1.0);
                }

                CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
                CGContextSetLineWidth(c, CTFontGetUnderlineThickness(font));
                CFRelease(font);

                CGFloat y = CGFloat_round(runBounds.origin.y + runBounds.size.height / 2.0f);
                CGContextMoveToPoint(c, runBounds.origin.x, y);
                CGContextAddLineToPoint(c, runBounds.origin.x + runBounds.size.width, y);

                CGContextStrokePath(c);
            }
        }

        lineIndex++;
    }
}

@end


#pragma mark -

static inline CGColorRef CGColorRefFromColor(id color) {
    return [color isKindOfClass:[UIColor class]] ? [color CGColor] : (__bridge CGColorRef)color;
}

static inline CTFontRef CTFontRefFromUIFont(UIFont * font) {
    CTFontRef ctfont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    return CFAutorelease(ctfont);
}

static inline NSDictionary * convertNSAttributedStringAttributesToCTAttributes(NSDictionary *attributes) {
    if (!attributes) return nil;
    
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
    
    NSDictionary *NSToCTAttributeNamesMap = @{
        NSFontAttributeName:            (NSString *)kCTFontAttributeName,
        NSBackgroundColorAttributeName: (NSString *)kXXBackgroundFillColorAttributeName,
        NSForegroundColorAttributeName: (NSString *)kCTForegroundColorAttributeName,
        NSUnderlineColorAttributeName:  (NSString *)kCTUnderlineColorAttributeName,
        NSUnderlineStyleAttributeName:  (NSString *)kCTUnderlineStyleAttributeName,
        NSStrokeWidthAttributeName:     (NSString *)kCTStrokeWidthAttributeName,
        NSStrokeColorAttributeName:     (NSString *)kCTStrokeWidthAttributeName,
        NSKernAttributeName:            (NSString *)kCTKernAttributeName,
        NSLigatureAttributeName:        (NSString *)kCTLigatureAttributeName
    };
    
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        key = [NSToCTAttributeNamesMap objectForKey:key] ? : key;
        
        if (![NSMutableParagraphStyle class]) {
            if ([value isKindOfClass:[UIFont class]]) {
                value = (__bridge id)CTFontRefFromUIFont(value);
            } else if ([value isKindOfClass:[UIColor class]]) {
                value = (__bridge id)((UIColor *)value).CGColor;
            }
        }
        
        [mutableAttributes setObject:value forKey:key];
    }];
    
    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}
