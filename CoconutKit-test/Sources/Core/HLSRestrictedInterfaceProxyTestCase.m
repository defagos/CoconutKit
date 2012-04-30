//
//  HLSRestrictedInterfaceProxyTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 27.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSRestrictedInterfaceProxyTestCase.h"

@protocol CompatibleRestrictedInterfaceA <NSObject>

- (NSInteger)method2;
- (NSInteger)method3;

@end

@protocol CompatibleRestrictedInterfaceB <NSObject>

- (NSInteger)method3;
- (NSInteger)method4;

@end

@protocol CompatibleRestrictedInterfaceC <NSObject>

- (NSInteger)method2;
- (NSInteger)method3;

@optional
- (NSInteger)method5;
- (NSInteger)method6;

@end

@protocol IncompatibleRestrictedInterface <NSObject>

- (NSInteger)method3;
- (NSInteger)method6;

@end

@interface FullInterfaceTestClass : NSObject

- (NSInteger)method1;
- (NSInteger)method2;
- (NSInteger)method3;
- (NSInteger)method4;
- (NSInteger)method5;

@end

@implementation FullInterfaceTestClass

- (NSInteger)method1
{
    return 1;
}

- (NSInteger)method2
{
    return 2;
}

- (NSInteger)method3
{
    return 3;
}

- (NSInteger)method4
{
    return 4;
}

- (NSInteger)method5
{
    return 5;
}

@end

@implementation HLSRestrictedInterfaceProxyTestCase

// TODO: Test proxy as target, safe bool

#pragma mark Tests

- (void)testCreation
{
    FullInterfaceTestClass *target = [[[FullInterfaceTestClass alloc] init] autorelease];
    
    GHAssertNotNil([target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceA)], nil);
    GHAssertNotNil([target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceB)], nil);
    GHAssertNotNil([target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceC)], nil);
    GHAssertNil([target proxyWithRestrictedInterface:@protocol(IncompatibleRestrictedInterface)], nil);
}

- (void)testMethodCalls
{
    FullInterfaceTestClass *target = [[[FullInterfaceTestClass alloc] init] autorelease];
    
    id<CompatibleRestrictedInterfaceB> proxyB = [target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceB)];
    
    // According to the -[NSObject isProxy] documentation: isKindOfClass: and isMemberOfClass:, these methods test the target
    // identity, not the proxy
    GHAssertTrue([proxyB isKindOfClass:[FullInterfaceTestClass class]], nil);
    GHAssertTrue([proxyB isMemberOfClass:[FullInterfaceTestClass class]], nil);
    GHAssertFalse([proxyB isKindOfClass:[HLSRestrictedInterfaceProxy class]], nil);
    GHAssertFalse([proxyB isKindOfClass:[HLSRestrictedInterfaceProxy class]], nil);
    
    GHAssertFalse([target isProxy], nil);
    GHAssertTrue([proxyB isProxy], nil);
    
    GHAssertEquals([proxyB method3], 3, nil);
    GHAssertEquals([proxyB method4], 4, nil);
    
    id<CompatibleRestrictedInterfaceC> proxyC = [target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceC)];
    GHAssertEquals([proxyC method2], 2, nil);
    GHAssertEquals([proxyC method3], 3, nil);
    GHAssertEquals([proxyC method5], 5, nil);
    GHAssertThrows([proxyC method6], nil);
    
    // Cannot access the underlying interface, even when casting by mistake
    FullInterfaceTestClass *hackerCastProxyB = (FullInterfaceTestClass *)proxyB;
    GHAssertThrows([hackerCastProxyB method1], nil);
        
    // Test respondsToSelector on proxy
    GHAssertFalse([proxyB respondsToSelector:@selector(method1)], nil);
    GHAssertFalse([proxyB respondsToSelector:@selector(method2)], nil);
    GHAssertTrue([proxyB respondsToSelector:@selector(method3)], nil);
    GHAssertTrue([proxyB respondsToSelector:@selector(method4)], nil);
    GHAssertFalse([proxyB respondsToSelector:@selector(method5)], nil);
    GHAssertFalse([proxyB respondsToSelector:@selector(method6)], nil);
    
    GHAssertFalse([proxyC respondsToSelector:@selector(method1)], nil);
    GHAssertTrue([proxyC respondsToSelector:@selector(method2)], nil);
    GHAssertTrue([proxyC respondsToSelector:@selector(method3)], nil);
    GHAssertFalse([proxyC respondsToSelector:@selector(method4)], nil);
    GHAssertTrue([proxyC respondsToSelector:@selector(method5)], nil);
    GHAssertFalse([proxyC respondsToSelector:@selector(method6)], nil);
    
    // TODO: A proxy should check that the protocol signature and the target method signature are the same
}

- (void)testSafeMethodCalls
{

}

- (void)testProxyTarget
{
    // TODO: Won't probably work
}

@end
