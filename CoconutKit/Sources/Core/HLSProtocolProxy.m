//
//  HLSProtocolProxy.m
//  CoconutKit
//
//  Created by Samuel Défago on 25.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSProtocolProxy.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSZeroingWeakRef.h"

static NSMutableDictionary *s_classToCompatibleClassesMap = nil;

@interface HLSProtocolProxy ()

@property (nonatomic, retain) HLSZeroingWeakRef *targetZeroingWeakRef;

@end

@implementation HLSProtocolProxy

#pragma mark Class methods

+ (id)proxyWithTarget:(id)target
{
    return [[[[self class] alloc] initWithTarget:target] autorelease];
}

#pragma mark Object creation and destruction

- (id)initWithTarget:(id)target
{
    if (target) {
        // Use the "public" class identities advertised by the classes (can be hidden, e.g. by some dynamic subclasses),
        // not the ones which could be obtained by using <objc/runtime.h> functions. This avoids polluting the compatibility
        // map with such classes
        Class class = [self class];
        Class targetClass = [target class];
        
        @synchronized([HLSProtocolProxy class]) {
            NSValue *classValue = [NSValue valueWithPointer:class];
            NSValue *targetClassValue = [NSValue valueWithPointer:targetClass];
            
            // First check if we have already found both classes to be compatible (and cached this information)
            if (! [[s_classToCompatibleClassesMap objectForKey:classValue] containsObject:targetClassValue]) {
                // Get all protocols implemented by the instantiated HLSProtocolProxy subclass
                unsigned int numberOfProtocols = 0;
                Protocol **protocols = hls_class_copyProtocolList(class, &numberOfProtocols);
                
                // Check that all those protocols are also implemented by the target's class. This makes those protocols 
                // define a common interface between self and target
                BOOL compatible = YES;
                for (unsigned int i = 0; i < numberOfProtocols; ++i) {
                    Protocol *protocol = protocols[i];
                    if (! hls_class_conformsToProtocol(targetClass, protocol)) {
                        compatible = NO;
                        break;
                    }
                }
                free(protocols);
                
                if (! compatible) {
                    HLSLoggerError(@"The class %@ must implement at least the same protocols as the proxy class %@", targetClass, class);
                    [self release];
                    return nil;
                }
                
                // Cache the compatibility relationship. This is made lazily (not in +initialize, e.g.) to account
                // for classes added at runtime
                if (! s_classToCompatibleClassesMap) {
                    s_classToCompatibleClassesMap = [[NSMutableDictionary dictionary] retain];
                }
                
                NSMutableSet *compatibleClasses = [s_classToCompatibleClassesMap objectForKey:classValue];
                if (! compatibleClasses) {
                    compatibleClasses = [NSMutableSet set];
                    [s_classToCompatibleClassesMap setObject:compatibleClasses forKey:classValue];
                }
                
                [compatibleClasses addObject:targetClassValue];
            }
        }
    }
    self.targetZeroingWeakRef = [[[HLSZeroingWeakRef alloc] initWithObject:target] autorelease];
    
    return self;
}

- (void)dealloc
{
    self.targetZeroingWeakRef = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize targetZeroingWeakRef = _targetZeroingWeakRef;

#pragma mark Message forwarding

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [self.targetZeroingWeakRef.object methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.targetZeroingWeakRef.object];
}

#pragma mark Description

- (NSString *)description
{
    // Retrieve the proxy subclass name (return the official public name to avoid revealing dynamic subclasses). The
    // target class could be a proxy as well, we thus cannot use the CoconutKit -className method to retrieve its name 
    // (since this method is on NSObject and NSProxy is a separate root class)
    NSString *className = [NSString stringWithCString:class_getName([self class])
                                             encoding:NSUTF8StringEncoding];
    NSString *targetClassName = [NSString stringWithCString:class_getName([self.targetZeroingWeakRef.object class]) 
                                                   encoding:NSUTF8StringEncoding];
    
    // Replace the target class name (if appearing in the description) with the proxy class name so
    // that we get the impression that the proxy implements its own -description method
    return [[self.targetZeroingWeakRef.object description] stringByReplacingOccurrencesOfString:targetClassName
                                                                                     withString:className];
}

@end
