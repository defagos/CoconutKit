//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (HLSExtensions)

/**
 * Return an image from the CoconutKit resource bundle
 */
+ (nullable instancetype)coconutKitImageNamed:(NSString *)imageName;

/**
 * Return a 1x1 px image having a given color
 */
+ (instancetype)imageWithColor:(UIColor *)color;

/**
 * Return the receiver masked with some image. Black mask pixels correspond to unmasked portions. To make parts of
 * the mask transparent, use pixels between black (opaque) and white (transparent), not an alpha
 */
- (UIImage *)imageMaskedWithImage:(UIImage *)maskImage;

/**
 * Return the image scaled to fill the specified size. The image will be stretched as needed
 */
- (UIImage *)imageScaledToSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
