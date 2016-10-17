//
//  MANotificationCenterAdditions.h
//  ZeroingWeakRef
//
//  Created by Michael Ash on 7/12/10.
//

#import <Foundation/Foundation.h>


@interface NSNotificationCenter (MAZeroingWeakRefAdditions)

/**
 * Returns an opaque observation handle that can be removed with NSNotificationCenter's 'removeObserver:'.
 */
- (id)hls_addWeakObserver: (id)observer selector: (SEL)selector name: (NSString *)name object: (id)object;

@end
