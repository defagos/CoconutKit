//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSGeometry.h"

#import "HLSLogger.h"

CGRect HLSRectForSizeContainedInRect(CGSize size, CGRect targetRect, HLSContentMode contentMode)
{
    switch (contentMode) {
        case HLSContentModeScaleToFill: {
            return targetRect;
            break;
        }
            
        case HLSContentModeScaleAspectFit: {
            CGSize targetSize = CGSizeMake(CGRectGetWidth(targetRect), CGRectGetHeight(targetRect));
            CGSize fittingSize = HLSSizeForAspectFittingInSize(size, targetSize);
            return CGRectMake(CGRectGetMinX(targetRect) + (CGRectGetWidth(targetRect) - fittingSize.width) / 2.f,
                              CGRectGetMinY(targetRect) + (CGRectGetHeight(targetRect) - fittingSize.height) / 2.f,
                              fittingSize.width,
                              fittingSize.height);
            break;
        }
            
        case HLSContentModeScaleAspectFill: {
            CGSize targetSize = CGSizeMake(CGRectGetWidth(targetRect), CGRectGetHeight(targetRect));
            CGSize fillingSize = HLSSizeForAspectFillingInSize(size, targetSize);
            return CGRectMake(CGRectGetMinX(targetRect) + (CGRectGetWidth(targetRect) - fillingSize.width) / 2.f,
                              CGRectGetMinY(targetRect) + (CGRectGetHeight(targetRect) - fillingSize.height) / 2.f,
                              fillingSize.width,
                              fillingSize.height);
            break;
        }
            
        case HLSContentModeCenter: {
            return CGRectMake(CGRectGetMinX(targetRect) + (CGRectGetWidth(targetRect) - size.width) / 2.f,
                              CGRectGetMinY(targetRect) + (CGRectGetHeight(targetRect) - size.height) / 2.f,
                              size.width,
                              size.height);
            break;
        }
            
        case HLSContentModeTop: {
            return CGRectMake(CGRectGetMinX(targetRect) + (CGRectGetWidth(targetRect) - size.width) / 2.f,
                              CGRectGetMinY(targetRect),
                              size.width,
                              size.height);
            break;
        }
            
        case HLSContentModeBottom: {
            return CGRectMake(CGRectGetMinX(targetRect) + (CGRectGetWidth(targetRect) - size.width) / 2.f,
                              CGRectGetMaxY(targetRect) - size.height,
                              size.width,
                              size.height);
            break;
        }
            
        case HLSContentModeLeft: {
            return CGRectMake(CGRectGetMinX(targetRect),
                              CGRectGetMinY(targetRect) + (CGRectGetHeight(targetRect) - size.height) / 2.f,
                              size.width,
                              size.height);
            break;
        }
            
        case HLSContentModeRight: {
            return CGRectMake(CGRectGetMaxX(targetRect) - size.width,
                              CGRectGetMinY(targetRect) + (CGRectGetHeight(targetRect) - size.height) / 2.f,
                              size.width,
                              size.height);
            break;
        }
            
        case HLSContentModeTopLeft: {
            return CGRectMake(CGRectGetMinX(targetRect),
                              CGRectGetMinY(targetRect),
                              size.width,
                              size.height);
            break;
        }
            
        case HLSContentModeTopRight: {
            return CGRectMake(CGRectGetMaxX(targetRect) - size.width,
                              CGRectGetMinY(targetRect),
                              size.width,
                              size.height);
            break;
        }
            
        case HLSContentModeBottomLeft: {
            return CGRectMake(CGRectGetMinX(targetRect),
                              CGRectGetMaxY(targetRect) - size.height,
                              size.width,
                              size.height);
            break;
        }
            
        case HLSContentModeBottomRight: {
            return CGRectMake(CGRectGetMaxX(targetRect) - size.width,
                              CGRectGetMaxY(targetRect) - size.height,
                              size.width,
                              size.height);
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown content mode. Fixed to Scale to fill");
            return CGRectZero;
            break;
        }
    }
}

CGSize HLSSizeForAspectFittingInSize(CGSize size, CGSize targetSize)
{
    CGFloat targetRatio = targetSize.width / targetSize.height;
    CGFloat ratio = size.width / size.height;
    
    CGFloat scale = isgreaterequal(ratio, targetRatio) ? targetSize.width / size.width : targetSize.height / size.height;
    return CGSizeMake(size.width * scale, size.height * scale);
}

CGSize HLSSizeForAspectFillingInSize(CGSize size, CGSize targetSize)
{
    CGFloat targetRatio = targetSize.width / targetSize.height;
    CGFloat ratio = size.width / size.height;
    
    CGFloat scale = isgreaterequal(ratio, targetRatio) ? targetSize.height / size.height : targetSize.width / size.width;
    return CGSizeMake(size.width * scale, size.height * scale);
}
