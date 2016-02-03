//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
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

@protocol CompatibleRestrictedInterfaceBSubset <NSObject>

- (NSInteger)method3;

@end

@protocol IncompatibleRestrictedInterfaceA <NSObject>

- (NSInteger)method3;
- (NSInteger)method6;

@end

// At this protocol level, FullInterfaceTestClass and the protocol are compatible, but at the parent protocol level 
// they aren't
@protocol IncompatibleRestrictedSubInterfaceA <IncompatibleRestrictedInterfaceA>

- (NSInteger)method3;
- (NSInteger)method4;

@end

// Incompatible method prototype
@protocol IncompatibleRestrictedInterfaceB <NSObject>

- (void)method2;

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

#pragma mark Tests

- (void)testCreationAndRemoval
{
    FullInterfaceTestClass *target = [[FullInterfaceTestClass alloc] init];
    
    id<CompatibleRestrictedInterfaceA> proxyB = [target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceB)];
    XCTAssertNil([[HLSRestrictedInterfaceProxy alloc] initWithTarget:proxyB protocol:@protocol(CompatibleRestrictedInterfaceBSubset)]);
    XCTAssertFalse([target isProxy]);
    XCTAssertTrue([proxyB isProxy]);
    
    // According to the -[NSObject isProxy] documentation of -isKindOfClass: and -isMemberOfClass:, these methods test the target
    // identity, not the proxy
    XCTAssertTrue([proxyB isKindOfClass:[FullInterfaceTestClass class]]);
    XCTAssertTrue([proxyB isMemberOfClass:[FullInterfaceTestClass class]]);
    XCTAssertFalse([proxyB isKindOfClass:[HLSRestrictedInterfaceProxy class]]);
    XCTAssertFalse([proxyB isKindOfClass:[HLSRestrictedInterfaceProxy class]]);
    
    XCTAssertNotNil([target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceA)]);
    XCTAssertNotNil([target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceB)]);
    XCTAssertNotNil([target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceC)]);
    XCTAssertNil([target proxyWithRestrictedInterface:@protocol(IncompatibleRestrictedInterfaceA)]);
    XCTAssertNil([target proxyWithRestrictedInterface:@protocol(IncompatibleRestrictedSubInterfaceA)]);
    XCTAssertNil([target proxyWithRestrictedInterface:@protocol(IncompatibleRestrictedInterfaceB)]);
}

- (void)testConformance
{
    FullInterfaceTestClass *target = [[FullInterfaceTestClass alloc] init];
    
    id<CompatibleRestrictedInterfaceB> proxyB = [target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceB)];
    id<CompatibleRestrictedInterfaceC> proxyC = [target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceC)];
    
    // Test respondsToSelector: on proxy
    XCTAssertFalse([proxyB respondsToSelector:@selector(method1)]);
    XCTAssertFalse([proxyB respondsToSelector:@selector(method2)]);
    XCTAssertTrue([proxyB respondsToSelector:@selector(method3)]);
    XCTAssertTrue([proxyB respondsToSelector:@selector(method4)]);
    XCTAssertFalse([proxyB respondsToSelector:@selector(method5)]);
    XCTAssertFalse([proxyB respondsToSelector:@selector(method6)]);
    
    XCTAssertFalse([proxyC respondsToSelector:@selector(method1)]);
    XCTAssertTrue([proxyC respondsToSelector:@selector(method2)]);
    XCTAssertTrue([proxyC respondsToSelector:@selector(method3)]);
    XCTAssertFalse([proxyC respondsToSelector:@selector(method4)]);
    XCTAssertTrue([proxyC respondsToSelector:@selector(method5)]);
    XCTAssertFalse([proxyC respondsToSelector:@selector(method6)]);
    
    // Test conformsToProtocol: on proxy
    XCTAssertTrue([proxyB conformsToProtocol:@protocol(CompatibleRestrictedInterfaceB)]);
    XCTAssertFalse([proxyB conformsToProtocol:@protocol(CompatibleRestrictedInterfaceC)]);
    XCTAssertFalse([proxyC conformsToProtocol:@protocol(CompatibleRestrictedInterfaceB)]);
    XCTAssertTrue([proxyC conformsToProtocol:@protocol(CompatibleRestrictedInterfaceC)]);
}

- (void)testInstanceMethodCalls
{
    FullInterfaceTestClass *target = [[FullInterfaceTestClass alloc] init];
    
    id<CompatibleRestrictedInterfaceB> proxyB = [target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceB)];
    XCTAssertEqual([proxyB method3], (NSInteger)3);
    XCTAssertEqual([proxyB method4], (NSInteger)4);
    
    id<CompatibleRestrictedInterfaceC> proxyC = [target proxyWithRestrictedInterface:@protocol(CompatibleRestrictedInterfaceC)];
    XCTAssertEqual([proxyC method2], (NSInteger)2);
    XCTAssertEqual([proxyC method3], (NSInteger)3);
    XCTAssertEqual([proxyC method5], (NSInteger)5);
    XCTAssertThrows([proxyC method6]);
    
    // Cannot access the underlying interface, even when casting by mistake
    FullInterfaceTestClass *hackerCastProxyB = (FullInterfaceTestClass *)proxyB;
    XCTAssertThrows([hackerCastProxyB method1]);
}

@end
