//
//  HLS3DTransform.h
//  CoconutKit
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface HLS3DTransform : NSObject

/**
 * Transform turning a rect into some destination rect (not necessarily the same size). Both rects must be given
 * relative to a common coordinate system, and must have parallel edges, otherwise the result is undefined
 */
+ (CATransform3D)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect;

@end
