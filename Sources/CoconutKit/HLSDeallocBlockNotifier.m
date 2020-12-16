//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSDeallocBlockNotifier.h"

@interface HLSDeallocBlockNotifier ()

@property void (^block)(void);

@end

@implementation HLSDeallocBlockNotifier

#pragma mark Object lifecycle

- (instancetype)initWithBlock:(void (^)(void))block
{
    if (self = [super init]) {
        self.block = block;
    }
    return self;
}

- (void)dealloc
{
    self.block();
}

@end
