//
//  NSString+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 11/3/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "NSString+HLSExtensions.h"

#import <CommonCrypto/CommonDigest.h>
#import "HLSCategoryLinker.h"

HLSLinkCategory(NSString_HLSExtensions)

static NSString* digest(NSString *string, unsigned char *(*cc_digest)(const void *, CC_LONG, unsigned char *), CC_LONG digestLength)
{
    // Hash calculation
	unsigned char md[digestLength];     // C99
    memset(md, 0, sizeof(md));
    const char *utf8str = [string UTF8String];
	cc_digest(utf8str, strlen(utf8str), md);
    
    // Hexadecimal representation
    NSMutableString *hexHash = [NSMutableString string];
    for (NSUInteger i = 0; i < sizeof(md); ++i) {
        [hexHash appendFormat:@"%02X", md[i]];
    }
    
    return [hexHash lowercaseString];
}

@implementation NSString (HLSExtensions)

#pragma mark Convenience methods

- (NSString *)stringByTrimmingWhitespaces
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)isFilled
{
    return [[self stringByTrimmingWhitespaces] length] != 0;
}

#pragma mark URL encoding

- (NSString *)urlEncodedStringUsingEncoding:(NSStringEncoding)encoding
{
    CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    NSString *result = NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+s_NSDate__descriptionWithLocale_Imp,/?%#[]"), cfEncoding));
    return [result autorelease];
}

#pragma mark Hash digests

- (NSString *)md2hash
{
    return digest(self, CC_MD2, CC_MD2_DIGEST_LENGTH);
}

- (NSString *)md4hash
{
    return digest(self, CC_MD4, CC_MD4_DIGEST_LENGTH);
}

- (NSString *)md5hash
{
    return digest(self, CC_MD5, CC_MD5_DIGEST_LENGTH);
}

- (NSString *)sha1hash
{
    return digest(self, CC_SHA1, CC_SHA1_DIGEST_LENGTH);
}

- (NSString *)sha224hash
{
    return digest(self, CC_SHA224, CC_SHA224_DIGEST_LENGTH);
}

- (NSString *)sha256hash
{
    return digest(self, CC_SHA256, CC_SHA256_DIGEST_LENGTH);
}

- (NSString *)sha384hash
{
    return digest(self, CC_SHA384, CC_SHA384_DIGEST_LENGTH);
}

- (NSString *)sha512hash
{
    return digest(self, CC_SHA512, CC_SHA512_DIGEST_LENGTH);
}

#pragma mark Version strings

- (NSString *)friendlyVersionNumber
{
    NSArray *versionComponents = [self componentsSeparatedByString:@"+"];
    if ([versionComponents count] > 1) {
        NSString *lastComponent = [versionComponents lastObject];
        if (! [lastComponent isEqualToString:@"dev"] && ! [lastComponent isEqualToString:@"test"]) {
            return lastComponent;
        }
    }
    return self;
}

#pragma mark Drawing

- (CGSize)drawInRect:(CGRect)rect 
            withFont:(UIFont *)font 
         minFontSize:(CGFloat)minFontSize
      actualFontSize:(CGFloat *)pActualFontSize
       textAlignment:(UITextAlignment)textAlignment 
       lineBreakMode:(UILineBreakMode)lineBreakMode
  baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGSize textSize = [self sizeWithFont:font 
                             minFontSize:minFontSize 
                          actualFontSize:NULL 
                                forWidth:CGRectGetWidth(rect) 
                           lineBreakMode:lineBreakMode];
    
    // Calculate the origin so that the text we draw is centered in rect
    CGPoint origin;
    switch (textAlignment) {            
        case UITextAlignmentCenter: {
            origin = CGPointMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect) - textSize.width) / 2.f, 
                                 CGRectGetMinY(rect) + (CGRectGetHeight(rect) - textSize.height) / 2.f);
            break;
        }
            
        case UITextAlignmentRight: {
            origin = CGPointMake(CGRectGetWidth(rect) - textSize.width, 
                                 CGRectGetMinY(rect) + (CGRectGetHeight(rect) - textSize.height) / 2.f);            
            break;
        }
            
        case UITextAlignmentLeft: {
            origin = CGPointMake(CGRectGetMinX(rect), 
                                 CGRectGetMinY(rect) + (CGRectGetHeight(rect) - textSize.height) / 2.f);
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown text alignment. Fixed to left alignment");
            origin = CGPointMake(CGRectGetMinX(rect), 
                                 CGRectGetMinY(rect) + (CGRectGetHeight(rect) - textSize.height) / 2.f);
            break;
        }

    }
    
    CGSize actualSize = [self drawAtPoint:origin
                                 forWidth:CGRectGetWidth(rect)
                                 withFont:font
                              minFontSize:minFontSize
                           actualFontSize:pActualFontSize
                            lineBreakMode:lineBreakMode
                       baselineAdjustment:baselineAdjustment];
    
    CGContextRestoreGState(context);
    
    return actualSize;
}

@end
