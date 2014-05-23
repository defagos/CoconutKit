//
//  HLSVector.m
//  CoconutKit
//
//  Created by Samuel Défago on 13.06.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
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

NSString *HLSStringFromVector2(HLSVector2 vector2)
{
    return [NSString stringWithFormat:@"[%.2f, %.2f]", vector2.v1, vector2.v2];
}

NSString *HLSStringFromVector3(HLSVector3 vector3)
{
    return [NSString stringWithFormat:@"[%.2f, %.2f, %.2f]", vector3.v1, vector3.v2, vector3.v3];
}

NSString *HLSStringFromVector4(HLSVector4 vector4)
{
    return [NSString stringWithFormat:@"[%.2f, %.2f, %.2f, %.2f]", vector4.v1, vector4.v2, vector4.v3, vector4.v4];
}
