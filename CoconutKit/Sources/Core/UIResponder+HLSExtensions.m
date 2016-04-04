//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIResponder+HLSExtensions.h"

#import "HLSRuntime.h"

// Associated object keys
static void *s_keyboardDistanceKey = &s_keyboardDistanceKey;

@implementation UIResponder (HLSExtensions)

#pragma mark Accessors and mutators

- (NSNumber *)keyboardDistance
{
    return hls_getAssociatedObject(self, s_keyboardDistanceKey);
}

- (void)setKeyboardDistance:(NSNumber *)keyboardDistance
{
    hls_setAssociatedObject(self, s_keyboardDistanceKey, keyboardDistance, HLS_ASSOCIATION_STRONG_NONATOMIC);
}

@end
