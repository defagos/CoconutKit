//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSObjectAnimation.h"

#import <Foundation/Foundation.h>

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
