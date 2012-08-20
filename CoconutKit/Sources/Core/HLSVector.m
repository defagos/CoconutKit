//
//  HLSVector.m
//  CoconutKit
//
//  Created by Samuel Défago on 13.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSVector.h"

HLSVector2 HLSVector2Make(CGFloat v1, CGFloat v2)
{
    HLSVector2 vector;
    memset(&vector, 0, sizeof(HLSVector2));
    vector.v1 = v1;
    vector.v2 = v2;
    return vector;
}

HLSVector3 HLSVector3Make(CGFloat v1, CGFloat v2, CGFloat v3)
{
    HLSVector3 vector;
    memset(&vector, 0, sizeof(HLSVector3));
    vector.v1 = v1;
    vector.v2 = v2;
    vector.v3 = v3;
    return vector;
}

HLSVector4 HLSVector4Make(CGFloat v1, CGFloat v2, CGFloat v3, CGFloat v4)
{
    HLSVector4 vector;
    memset(&vector, 0, sizeof(HLSVector4));
    vector.v1 = v1;
    vector.v2 = v2;
    vector.v3 = v3;
    vector.v4 = v4;
    return vector;
}
