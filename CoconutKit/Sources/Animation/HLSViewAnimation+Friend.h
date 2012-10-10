//
//  HLSViewAnimation+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 9/2/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface HLSViewAnimation (Friend)

/**
 * The transform corresponding to the view animation settings
 */
@property (nonatomic, readonly, assign) CGAffineTransform transform;

/**
 * The increment to apply to the view alpha value
 */
@property (nonatomic, readonly, assign) CGFloat alphaIncrement;

@end
