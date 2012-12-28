//
//  UIView+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#define HLSViewAutoresizingAll UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |         \
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |                               \
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin

@interface UIView (HLSExtensions)

/**
 * Use this property if you want to tag your view with a string instead of an integer
 */
@property (nonatomic, retain) NSString *tag_hls;

/**
 * Use this dictionary to convey additional information about your views
 */
@property (nonatomic, retain) NSDictionary *userInfo_hls;

/**
 * Return the view and all its subview flattened as a UIImage
 */
- (UIImage *)flattenedImage;

/**
 * Fades the view borders.
 * Fades left border of 'left' pixels, right border of 'right' pixels, etc.
 * These methods cannot be used together; only the last method called will be applied
 */
- (void)fadeLeftBorder:(CGFloat)left rightBorder:(CGFloat)right;
- (void)fadeBottomBorder:(CGFloat)bottom topBorder:(CGFloat)top;

@end
