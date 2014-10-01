//
//  HLSViewAnimation+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 9/2/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

/**
 * Interface meant to be used by friend classes of HLSViewAnimation (= classes which must have access to private implementation
 * details)
 */
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
