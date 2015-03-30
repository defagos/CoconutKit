//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HLSLabel.h"

#import "HLSLogger.h"
#import "NSDictionary+HLSExtensions.h"
#import "NSString+HLSExtensions.h"

@implementation HLSLabel

#pragma mark Accessors and mutators

- (void)setVerticalAlignment:(HLSLabelVerticalAlignment)verticalAlignment
{
    if (_verticalAlignment == verticalAlignment) {
        return;
    }
    
    _verticalAlignment = verticalAlignment;
    
    [self setNeedsDisplay];
}

#pragma mark UILabel drawing override points

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
	
    switch (self.verticalAlignment) {
        case HLSLabelVerticalAlignmentTop: {
            textRect.origin.y = 0.f;
            break;
        }
            
        case HLSLabelVerticalAlignmentBottom: {
            textRect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(textRect);
            break;
        }
            
        case HLSLabelVerticalAlignmentMiddle: {
        default:
            textRect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(textRect)) / 2.f;
            break;
        }
    }
    
    return textRect;
}

- (void)drawTextInRect:(CGRect)requestedRect
{
    CGRect rect = [self.text boundingRectWithSize:requestedRect.size
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{ NSFontAttributeName : self.font }
                                          context:nil];
    CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    
    // Most attributes are ignored when using the attributedText property of UILabel, see UILabel.h
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes safelySetObject:self.font forKey:NSFontAttributeName];
    [attributes safelySetObject:self.textColor forKey:NSForegroundColorAttributeName];
    [attributes safelySetObject:self.backgroundColor forKey:NSBackgroundColorAttributeName];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = self.shadowOffset;
    shadow.shadowColor = self.shadowColor;
    [attributes safelySetObject:shadow forKey:NSShadowAttributeName];
    
    [self.text drawInRect:actualRect withAttributes:attributes];
}

@end
