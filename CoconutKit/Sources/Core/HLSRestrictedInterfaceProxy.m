//
//  HLSRestrictedInterfaceProxy.m
//  CoconutKit
//
//  Created by Samuel Défago on 25.04.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSRestrictedInterfaceProxy.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSMAZeroingWeakRef.h"
#import "NSObject+HLSExtensions.h"

@interface HLSRestrictedInterfaceProxy ()

@property (nonatomic, strong) HLSMAZeroingWeakRef *targetZeroingWeakRef;

@end

@implementation HLSRestrictedInterfaceProxy {
@private
    Protocol *_protocol;
}

#pragma mark Class methods

+ (instancetype)proxyWithTarget:(id)target protocol:(Protocol *)protocol
{
    return [[[self class] alloc] initWithTarget:target protocol:protocol];
}

#pragma mark Object creation and destruction

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)initWithTarget:(id)target protocol:(Protocol *)protocol
{    
    if (! protocol) {
        HLSLoggerError(@"Cannot create a proxy to target %@ without a protocol", target);
        return nil;
    }
    
    if ([target isProxy]) {
        HLSLoggerError(@"Cannot create a proxy to another proxy");
        return nil;
    }
    
    if (target) {
        // Consider the official class identity, not the real one which could be discovered by using runtime
        // functions (-class can be e.g. faked by dynamic subclasses)
        Class targetClass = [target class];
        if (! hls_class_conformsToInformalProtocol(targetClass, protocol)) {
            HLSLoggerError(@"The class %@ must implement the protocol %s (at least informally)", targetClass, protocol_getName(protocol));
            return nil;
        }
    }
    
    self.targetZeroingWeakRef = [HLSMAZeroingWeakRef refWithTarget:target];
    _protocol = protocol;
    
    return self;
}

#pragma clang diagnostic pop

#pragma mark Accessors and mutators

@synthesize targetZeroingWeakRef = _targetZeroingWeakRef;

#pragma mark Proxy implementation

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    return _protocol == protocol;
}

- (BOOL)respondsToSelector:(SEL)selector
{
    if (! [self protocolDeclaresSelector:selector]) {
        return NO;
    }
    else {
        // See -[NSObject respondsToSelector:] documentation
        return [[[self.targetZeroingWeakRef target] class] instancesRespondToSelector:selector];
    }
}

- (BOOL)protocolDeclaresSelector:(SEL)selector
{
    // Search in required methods first (should be the most common case for protocols defining an interface subset)
    // Remark: Unlike the documentation says, protocol_getMethodDescription takes into account parent protocols as well
    struct objc_method_description methodDescription = protocol_getMethodDescription(_protocol, selector, YES, YES);
    if (! methodDescription.name) {
        // Search in optional methods
        methodDescription = protocol_getMethodDescription(_protocol, selector, NO, YES);
        if (! methodDescription.name) {
            return NO;
        }
    }
    
    return YES;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{    
    return [[self.targetZeroingWeakRef target] methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = [invocation selector];
    if (! [self protocolDeclaresSelector:selector]) {
        NSString *reason = [NSString stringWithFormat:@"[id<%s> %s]: unrecognized selector sent to proxy instance %p", protocol_getName(_protocol),
                            sel_getName(selector), self];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];        
    }
    
    // If the target does not implement the method, an exception will be raised
    [invocation invokeWithTarget:[self.targetZeroingWeakRef target]];
}

#pragma mark Description

- (NSString *)description
{
    // Must override NSProxy implementation, not forwarded automatically. Replace the target class name (if appearing in the description)
    // with the proxy object information
    id target = [self.targetZeroingWeakRef target];
    return [[target description] stringByReplacingOccurrencesOfString:[target className]
                                                           withString:[NSString stringWithFormat:@"id<%s>", protocol_getName(_protocol)]];
}

@end

@implementation NSObject (HLSRestrictedInterfaceProxy)

- (id)proxyWithRestrictedInterface:(Protocol *)protocol
{
    return [HLSRestrictedInterfaceProxy proxyWithTarget:self protocol:protocol];
}

@end
