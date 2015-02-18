//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HLSWeakObjectWrapper.h"

@interface HLSWeakObjectWrapper ()

@property (nonatomic, weak) id object;

@end

@implementation HLSWeakObjectWrapper

- (instancetype)initWithObject:(id)object
{
    if (self = [super init]) {
        self.object = object;
    }
    return self;
}

@end
