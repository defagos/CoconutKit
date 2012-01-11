//
//  StretchableViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * A view controller stretchable in all directions
 */
@interface StretchableViewController : HLSViewController {
@private
    
}

- (id)initLarge:(BOOL)large;

@property (nonatomic, assign, getter=isLarge) BOOL large;

@end
