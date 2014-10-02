//
//  MAZeroingWeakProxy.m
//  ZeroingWeakRef
//
//  Created by Michael Ash on 7/17/10.
//  Copyright 2010 Michael Ash. All rights reserved.
//

#import "MAZeroingWeakProxy.h"

#import "MAZeroingWeakRef.h"

@implementation MAZeroingWeakProxy

+ (id)proxyWithTarget: (id)target
{
    return [[[self alloc] initWithTarget: target] autorelease];
}

- (id)initWithTarget: (id)target
{
    // stash the class of the target so we can get method signatures after it goes away
    _targetClass = [target class];
    _weakRef = [[MAZeroingWeakRef alloc] initWithTarget: target];
    return self;
}

- (void)dealloc
{
    [_weakRef release];
    [super dealloc];
}

- (id)zeroingProxyTarget
{
    return [_weakRef target];
}

#if NS_BLOCKS_AVAILABLE
- (void)setCleanupBlock: (void (^)(id target))block
{
    [_weakRef setCleanupBlock: block];
}
#endif

- (id)forwardingTargetForSelector: (SEL)sel
{
    return [_weakRef target];
}

- (NSMethodSignature *)methodSignatureForSelector: (SEL)sel
{
    return [_targetClass instanceMethodSignatureForSelector: sel];
}

- (void)forwardInvocation: (NSInvocation *)inv
{
    NSMethodSignature *sig = [inv methodSignature];
    NSUInteger returnLength = [sig methodReturnLength];
    
    if(returnLength)
    {
        char buf[returnLength];
        bzero(buf, sizeof(buf));
        [inv setReturnValue: buf];
    }
}

- (BOOL)respondsToSelector: (SEL)sel
{
    id target = [_weakRef target];
    if(target)
        return [target respondsToSelector: sel];
    else
        return [_targetClass instancesRespondToSelector: sel];
}

- (BOOL)conformsToProtocol: (Protocol *)protocol
{
    id target = [_weakRef target];
    if(target)
        return [target conformsToProtocol: protocol];
    else
        return [_targetClass conformsToProtocol: protocol];
}

// NSProxy implements these for some incomprehensibly stupid reason

- (NSUInteger)hash
{
    return [[_weakRef target] hash];
}

- (BOOL)isEqual: (id)obj
{
    return [[_weakRef target] isEqual: obj];
}

@end
