//
//  HLSObjectAnimation+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Interface meant to be used by friend classes of HLSObjectAnimation (= classes which must have access to private implementation
 * details)
 */
@interface HLSObjectAnimation (Friend)

/**
 * Return the object animation corresponding to the inverse animation
 */
- (id)reverseObjectAnimation;

@end
