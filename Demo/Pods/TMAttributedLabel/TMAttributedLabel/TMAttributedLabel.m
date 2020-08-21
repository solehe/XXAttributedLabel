//
//  TMAttributedLabel.m
//
//  Created by solehe on 2020/8/15.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <Availability.h>

#import "NSMutableAttributedString+TM.h"

#import "TMAttributedLabelAttachment.h"
#import "TMAttributedLabelLink.h"
#import "TMAttributedLabel.h"

#define kXXLineBreakWordWrapTextWidthScalingFactor (M_PI / M_E)

static CGFloat const TMFLOAT_MAX = 100000;

NSString * const kXXStrikeOutAttributeName = @"XXStrikeOutAttribute";
NSString * const kXXBackgroundFillColorAttributeName = @"XXBackgroundFillColor";
NSString * const kXXBackgroundFillPaddingAttributeName = @"XXBackgroundFillPadding";
NSString * const kXXBackgroundStrokeColorAttributeName = @"XXBackgroundStrokeColor";
NSString * const kXXBackgroundLineWidthAttributeName = @"XXBackgroundLineWidth";
NSString * const kXXBackgroundCornerRadiusAttributeName = @"XXBackgroundCornerRadius";


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

static inline NSDictionary * NSAttributedStringAttributesFromLabel(TMAttributedLabel *label) {
    
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];

    [mutableAttributes setObject:label.font forKey:(NSString *)kCTFontAttributeName];
    [mutableAttributes setObject:label.textColor forKey:(NSString *)kCTForegroundColorAttributeName];
    
    CGFloat multipleLineHeight = label.font.lineHeight * label.lineHeightMultiple;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = (label.numberOfLines == 1) ? label.lineBreakMode : NSLineBreakByWordWrapping;
    paragraphStyle.minimumLineHeight = label.minimumLineHeight > 0 ? label.minimumLineHeight : multipleLineHeight;
    paragraphStyle.maximumLineHeight = label.maximumLineHeight > 0 ? label.maximumLineHeight : multipleLineHeight;
    paragraphStyle.lineHeightMultiple = label.lineHeightMultiple;
    paragraphStyle.alignment = label.textAlignment;
    paragraphStyle.lineSpacing = label.lineSpacing;
    
    [mutableAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];

    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

static inline NSMutableAttributedString * NSAttributedStringAttributesFromLinks(NSAttributedString *attributedText, NSArray *links) {
    
    NSMutableAttributedString *drawString = [attributedText mutableCopy];
    
    for (TMAttributedLabelLink *link in links) {
        
        if (link.range.location + link.range.length > [drawString length]) {
            continue;
        }
        
        [drawString xx_setTextColor:[link color] range:link.range];
        [drawString xx_setUnderlineStyle:kCTUnderlineStyleNone modifier:kCTUnderlinePatternSolid range:link.range];
    }
    
    return drawString;
}

static inline CGColorRef CGColorRefFromColor(id color) {
    return [color isKindOfClass:[UIColor class]] ? [color CGColor] : (__bridge CGColorRef)color;
}

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
        return [attributedString mutableCopy];
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
    CGSize constraints = CGSizeMake(size.width, TMFLOAT_MAX);

    if (numberOfLines == 1) {
        // If there is one line, the size that fits is the full width of the line
        constraints = CGSizeMake(TMFLOAT_MAX, TMFLOAT_MAX);
    } else if (numberOfLines > 0) {
        // If the line count of the label more than 1, limit the range to size to the number of lines that have been set
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, TMFLOAT_MAX));
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


@interface TMAttributedLabel ()

@property (nonatomic, assign) BOOL              needsFramesetter;
@property (nonatomic, assign) CTFrameRef        textFrame;
@property (nonatomic, assign) CTFramesetterRef  framesetter;
@property (nonatomic, strong) NSMutableArray    *attachments;
@property (nonatomic, strong) NSMutableArray    *linkModels;
@property (nonatomic, strong) TMAttributedLabelLink *activeLink;
@property (nonatomic, strong) NSMutableAttributedString *renderedAttributedText;
@property (nonatomic, strong) NSMutableAttributedString *inactiveAttributedText;

@end

@implementation TMAttributedLabel

@dynamic text;
@synthesize framesetter = _framesetter;
@synthesize attributedText = _attributedText;

- (void)dealloc {
    if (_framesetter) {
        CFRelease(_framesetter);
    }
    if (_textFrame) {
        CFRelease(_textFrame);
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
    
    self.linkModels = [NSMutableArray array];
    self.attachments = [NSMutableArray array];
    
    self.textInsets = UIEdgeInsetsZero;
    self.lineHeightMultiple = 1.0f;
    
    self.userInteractionEnabled = YES;
}

#pragma mark -

// 添加自定义链接，支持传入NSString和XXAtributedLableLink
- (void)addCustomLink:(id)linkData forRange:(NSRange)range {
    [self addCustomLink:linkData forRange:range color:self.linkColor];
}

- (void)addCustomLink:(id)linkData forRange:(NSRange)range color:(UIColor *)color {
    UIColor *normalColor = !color ? self.textColor : color;
    UIColor *highlightColor = !self.linkHighlightColor ? self.textColor : self.linkHighlightColor;
    [_linkModels addObject:[TMAttributedLabelLink urlWithLinkData:linkData range:range
                                                      normalColor:normalColor
                                                   highlightColor:highlightColor]];
    [self setAttributedText:self.attributedText];
}

- (BOOL)containslinkAtPoint:(CGPoint)point {
    return [self linkAtPoint:point] != nil;
}

- (TMAttributedLabelLink *)linkAtPoint:(CGPoint)point {
    
    // Stop quickly if none of the points to be tested are in the bounds.
    if (!CGRectContainsPoint(CGRectInset(self.bounds, -15.f, -15.f), point) || self.linkModels.count == 0) {
        return nil;
    }
    
    TMAttributedLabelLink *result = [self linkAtCharacterIndex:[self characterIndexAtPoint:point]];
    
    if (!result && self.extendsLinkTouchArea) {
        result = [self linkAtRadius:2.5f aroundPoint:point]
              ?: [self linkAtRadius:5.f aroundPoint:point]
              ?: [self linkAtRadius:7.5f aroundPoint:point]
              ?: [self linkAtRadius:12.5f aroundPoint:point]
              ?: [self linkAtRadius:15.f aroundPoint:point];
    }
    
    return result;
}

- (TMAttributedLabelLink *)linkAtRadius:(const CGFloat)radius aroundPoint:(CGPoint)point {
    const CGFloat diagonal = CGFloat_sqrt(2 * radius * radius);
    const CGPoint deltas[] = {
        CGPointMake(0, -radius), CGPointMake(0, radius), // Above and below
        CGPointMake(-radius, 0), CGPointMake(radius, 0), // Beside
        CGPointMake(-diagonal, -diagonal), CGPointMake(-diagonal, diagonal),
        CGPointMake(diagonal, diagonal), CGPointMake(diagonal, -diagonal) // Diagonal
    };
    const size_t count = sizeof(deltas) / sizeof(CGPoint);
    
    TMAttributedLabelLink *link = nil;
    
    for (NSInteger i = 0; i < count && link == nil; i ++) {
        CGPoint currentPoint = CGPointMake(point.x + deltas[i].x, point.y + deltas[i].y);
        link = [self linkAtCharacterIndex:[self characterIndexAtPoint:currentPoint]];
    }
    
    return link;
}

- (TMAttributedLabelLink *)linkAtCharacterIndex:(CFIndex)idx {
    
    // Do not enumerate if the index is outside of the bounds of the text.
    if (!NSLocationInRange((NSUInteger)idx, NSMakeRange(0, self.attributedText.length))) {
        return nil;
    }
    
    NSEnumerator *enumerator = [self.linkModels reverseObjectEnumerator];
    TMAttributedLabelLink *link = nil;
    while ((link = [enumerator nextObject])) {
        if (NSLocationInRange((NSUInteger)idx, link.range)) {
            return link;
        }
    }

    return nil;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)p {
    
    if (!CGRectContainsPoint(self.bounds, p)) {
        return NSNotFound;
    }

    CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    if (!CGRectContainsPoint(textRect, p)) {
        return NSNotFound;
    }

    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    p = CGPointMake(p.x - textRect.origin.x, p.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    p = CGPointMake(p.x, textRect.size.height - p.y);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFrameRef frame = CTFramesetterCreateFrame([self framesetter], CFRangeMake(0, (CFIndex)[self.attributedText length]), path, NULL);
    if (frame == NULL) {
        CGPathRelease(path);
        return NSNotFound;
    }

    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    if (numberOfLines == 0) {
        CFRelease(frame);
        CGPathRelease(path);
        return NSNotFound;
    }

    CFIndex idx = NSNotFound;

    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);

    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);

        // Get bounding information of line
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = (CGFloat)floor(lineOrigin.y - descent);
        CGFloat yMax = (CGFloat)ceil(lineOrigin.y + ascent);

        // Apply penOffset using flushFactor for horizontal alignment to set lineOrigin since this is the horizontal offset from drawFramesetter
        CGFloat flushFactor = XXFlushFactorForTextAlignment(self.textAlignment);
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, textRect.size.width);
        lineOrigin.x = penOffset;

        // Check if we've already passed the line
        if (p.y > yMax) {
            break;
        }
        // Check if the point is within this line vertically
        if (p.y >= yMin) {
            // Check if the point is within this line horizontally
            if (p.x >= lineOrigin.x && p.x <= lineOrigin.x + width) {
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x, p.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }

    CFRelease(frame);
    CGPathRelease(path);

    return idx;
}

- (id)linkDataForPoint:(CGPoint)point {
    TMAttributedLabelLink *url = [self linkAtPoint:point];
    return url ? url.linkData : nil;
}

#pragma mark -

- (void)setActiveLink:(TMAttributedLabelLink *)activeLink {
    
    if (_activeLink) {
        [_activeLink setSelected:NO];
    }
    
    _activeLink = activeLink;
    _activeLink.selected = YES;
    
    UIColor *highLightColor = !self.linkHighlightColor ? activeLink.color : self.linkHighlightColor;
    highLightColor = !highLightColor ? self.textColor : highLightColor;
    NSDictionary *activeAttributes = @{NSForegroundColorAttributeName : [UIColor yellowColor]};

    if (_activeLink && activeAttributes.count > 0) {
        
        if (!self.inactiveAttributedText) {
            self.inactiveAttributedText = [self.attributedText copy];
        }

        NSMutableAttributedString *mutableAttributedString = [self.inactiveAttributedText mutableCopy];
        NSUInteger loc = NSMaxRange(self.activeLink.range) - 1;
        NSRange range = NSMakeRange(0, [self.inactiveAttributedText length]);
        if (self.activeLink.range.length > 0 && NSLocationInRange(loc, range)) {
            [mutableAttributedString addAttributes:activeAttributes range:self.activeLink.range];
        }

        self.attributedText = mutableAttributedString;
        [self setNeedsDisplay];

        [CATransaction flush];
        
    } else if (self.inactiveAttributedText) {
        
        self.attributedText = self.inactiveAttributedText;
        self.inactiveAttributedText = nil;

        [self setNeedsDisplay];
    }
}

#pragma mark -

- (void)setText:(id)text {
    text = !text ? @"" : text;
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

    if (self.attributedText.length <= 0) {
        [self.linkModels removeAllObjects];
    }
    
    _attributedText = [NSAttributedStringAttributesFromLinks(attributedText, _linkModels) copy];

    [self setNeedsFramesetter];
    [self setNeedsDisplay];

    if ([self respondsToSelector:@selector(invalidateIntrinsicContentSize)]) {
        [self invalidateIntrinsicContentSize];
    }

    [super setText:[self.attributedText string]];
}

// 增加文本，支持传入NSString、NSAttributedString、UIImage和UIView
- (void)append:(id)obj alignment:(TMAttributedAlignment)alignment {
    
    if ([obj isKindOfClass:[UIImage class]] || [obj isKindOfClass:[UIView class]]) {
        
        CGSize size = [obj isKindOfClass:[UIImage class]] ? ((UIImage *)obj).size : CGSizeZero;
        TMAttributedLabelAttachment *attachment = [TMAttributedLabelAttachment attachmentWith:obj
                                                                                       margin:UIEdgeInsetsZero
                                                                                    alignment:alignment
                                                                                      maxSize:size];
        [self appendAttachment:attachment];
        
    } else if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSAttributedString class]]) {
    
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        
        if ([obj isKindOfClass:[NSString class]]) {
            
            NSDictionary *attributes = NSAttributedStringAttributesFromLabel(self);
            [attributedText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:obj attributes:attributes]];
            
        } else if ([obj isKindOfClass:[NSAttributedString class]]) {
            
            NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:obj];
            NSRange range = NSMakeRange(0, [mutableAttributedString length]);
            [mutableAttributedString addAttributes:NSAttributedStringAttributesFromLabel(self) range:range];
            [attributedText appendAttributedString:mutableAttributedString];
        }
        
        [self setAttributedText:attributedText];
        
    } else {
        NSLog(@"【AttributedLabel】不支持的类型");
    }
}

- (void)appendAttachment:(TMAttributedLabelAttachment *)attachment {
    
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

- (void)appendAttributedText:(NSAttributedString *)attributedText {
    NSMutableAttributedString *mutableAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [mutableAttributedText appendAttributedString:attributedText];
    [self setAttributedText:[mutableAttributedText copy]];
}

// 默认竖直方向居中对齐
- (void)append:(id)obj {
    [self append:obj alignment:TMAttributedAlignmentCenter];
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

- (void)setTextFrame:(CTFrameRef)textFrame {
    
    if (textFrame) {
        CFRetain(textFrame);
    }

    if (_textFrame) {
        CFRelease(_textFrame);
    }

    _textFrame = textFrame;
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
            case TMAttributedAlignmentCenter:
                yOffset = CGFloat_floor((bounds.size.height - textSize.height) / 2.0f);
                break;
            case TMAttributedAlignmentBottom:
                yOffset = bounds.size.height - textSize.height;
                break;
            case TMAttributedAlignmentTop:
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
        CGSize maxSize = (self.numberOfLines > 1) ? CGSizeMake(TMFLOAT_MAX, TMFLOAT_MAX) : CGSizeZero;

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
    
    [self setTextFrame:frame];;
    
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
                
                
                NSRange linkRange;
                if ([attributedTruncationString attribute:NSLinkAttributeName atIndex:0 effectiveRange:&linkRange]) {
                    NSRange tokenRange = [truncationString.string rangeOfString:attributedTruncationString.string];
                    NSUInteger loc = lastLineRange.location + lastLineRange.length;
                    NSRange tokenLinkRange = NSMakeRange(loc - tokenRange.length, tokenRange.length);
                    
                    [self addCustomLink:[attributedTruncationString string] forRange:tokenLinkRange];
                }

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
            TMAttributedLabelAttachment* attributedImage = (TMAttributedLabelAttachment *)CTRunDelegateGetRefCon(delegate);
            
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
                case TMAttributedAlignmentTop:
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight);
                    break;
                case TMAttributedAlignmentCenter:
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight) / 2.0;
                    break;
                case TMAttributedAlignmentBottom:
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

#pragma mark - 点击事件相应
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.activeLink == nil)
    {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        self.activeLink =  [self linkAtPoint:point];
    }
    
    if (self.activeLink)
    {
          [self setNeedsDisplay];
    }
    else
    {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    TMAttributedLabelLink *touchedLink = [self linkAtPoint:point];
    if (self.activeLink != touchedLink)
    {
        self.activeLink = touchedLink;
        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if (self.activeLink)
    {
        self.activeLink = nil;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if(![self onLabelClick:point])
    {
        [super touchesEnded:touches withEvent:event];
    }
    if (self.activeLink)
    {
        self.activeLink = nil;
        [self setNeedsDisplay];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    TMAttributedLabelLink *touchedLink = [self linkAtPoint:point];
    if (touchedLink == nil)
    {
        NSArray *subViews = [self subviews];
        for (UIView *view in subViews)
        {
            CGPoint hitPoint = [view convertPoint:point
                                         fromView:self];
            
            UIView *hitTestView = [view hitTest:hitPoint
                                      withEvent:event];
            if (hitTestView)
            {
                return hitTestView;
            }
        }
        return nil;
    }
    else
    {
        return self;
    }
}

- (BOOL)onLabelClick:(CGPoint)point
{
    id linkData = [self linkDataForPoint:point];
    if (linkData)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(attributedLabel:clickedOnLink:)])
        {
            [_delegate attributedLabel:self clickedOnLink:linkData];
        }

        return YES;
    }
    
    return NO;
}

@end



