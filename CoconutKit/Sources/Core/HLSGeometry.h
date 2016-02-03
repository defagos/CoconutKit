//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

// Same as UIViewContentMode values, but without irrelevant ones
typedef NS_ENUM(NSInteger, HLSContentMode) {
    HLSContentModeEnumBegin = 0,
    HLSContentModeScaleToFill = HLSContentModeEnumBegin,
    HLSContentModeScaleAspectFit,
    HLSContentModeScaleAspectFill,
    HLSContentModeCenter = 4,           // Match UIViewContentMode values
    HLSContentModeTop,
    HLSContentModeBottom,
    HLSContentModeLeft,
    HLSContentModeRight,
    HLSContentModeTopLeft,
    HLSContentModeTopRight,
    HLSContentModeBottomLeft,
    HLSContentModeBottomRight,
    HLSContentModeEnumEnd,
    HLSContentModeEnumSize = HLSContentModeEnumEnd - HLSContentModeEnumBegin
};

/**
 * Given a size, return the rectangle corresponding to a rectangle passing in a given target rectangle for the provided content
 * mode. The returned rectangle coordinates are expressed in the same coordinate system as the target rectangle. For content
 * modes with scaling, the returned rectangle will be larger or smaller than the size specified by the caller
 */
OBJC_EXPORT CGRect HLSRectForSizeContainedInRect(CGSize size, CGRect targetRect, HLSContentMode contentMode);

/**
 * Given a size, return the size which aspect fits, respectively fills a specified target size
 */
OBJC_EXPORT CGSize HLSSizeForAspectFittingInSize(CGSize size, CGSize targetSize);
OBJC_EXPORT CGSize HLSSizeForAspectFillingInSize(CGSize size, CGSize targetSize);
