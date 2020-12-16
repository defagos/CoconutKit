//
//  MAZeroingWeakProxy.h
//  ZeroingWeakRef
//
//  Created by Michael Ash on 7/17/10.
//  Copyright 2010 Michael Ash. All rights reserved.
//

#import <Foundation/Foundation.h>


@class HLSMAZeroingWeakRef;

@interface HLSMAZeroingWeakProxy : NSProxy
{
    HLSMAZeroingWeakRef *_weakRef;
    Class _targetClass;
}

+ (id)proxyWithTarget: (id)target;

- (id)initWithTarget: (id)target;

- (id)zeroingProxyTarget;

#if NS_BLOCKS_AVAILABLE
// same caveats/restrictions as HLSMAZeroingWeakRef cleanup block
- (void)setCleanupBlock: (void (^)(id target))block;
#endif

@end
