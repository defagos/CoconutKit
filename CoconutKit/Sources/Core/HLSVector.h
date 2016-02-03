//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

// A vector with 2 components
typedef struct {
    CGFloat v1;
    CGFloat v2;
} HLSVector2;

// A vector with 3 components
typedef struct {
    CGFloat v1;
    CGFloat v2;
    CGFloat v3;
} HLSVector3;

// A vector with 4 components
typedef struct {
    CGFloat v1;
    CGFloat v2;
    CGFloat v3;
    CGFloat v4;
} HLSVector4;

// Convenience constructors
OBJC_EXPORT HLSVector2 HLSVector2Make(CGFloat v1, CGFloat v2);
OBJC_EXPORT HLSVector3 HLSVector3Make(CGFloat v1, CGFloat v2, CGFloat v3);
OBJC_EXPORT HLSVector4 HLSVector4Make(CGFloat v1, CGFloat v2, CGFloat v3, CGFloat v4);

// Return a string representation of a vector
OBJC_EXPORT NSString *HLSStringFromVector2(HLSVector2 vector2);
OBJC_EXPORT NSString *HLSStringFromVector3(HLSVector3 vector3);
OBJC_EXPORT NSString *HLSStringFromVector4(HLSVector4 vector4);
