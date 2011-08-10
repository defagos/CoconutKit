//
//  HLSTransform.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/6/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Not meant to be instantiated. Collection of class methods
 */
@interface HLSTransform : NSObject {
@private
    
}

/**
 * Transform turning a rect into some destination rect (not necessarily the same size). Both rects must be given
 * relative to a common coordinate system, and must have parallel edges, otherwise the result is undefined
 */
+ (CGAffineTransform)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect;

@end
