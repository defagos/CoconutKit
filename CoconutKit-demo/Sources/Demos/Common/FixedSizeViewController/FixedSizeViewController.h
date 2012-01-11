//
//  FixedSizeViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * A view controller with fixed size
 */
@interface FixedSizeViewController : HLSViewController {
@private
    
}

- (id)initLarge:(BOOL)large;

@property (nonatomic, assign, getter=isLarge) BOOL large;

@end
