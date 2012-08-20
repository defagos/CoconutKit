//
//  HLSVector.h
//  CoconutKit
//
//  Created by Samuel Défago on 13.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

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
HLSVector2 HLSVector2Make(CGFloat v1, CGFloat v2);
HLSVector3 HLSVector3Make(CGFloat v1, CGFloat v2, CGFloat v3);
HLSVector4 HLSVector4Make(CGFloat v1, CGFloat v2, CGFloat v3, CGFloat v4);
