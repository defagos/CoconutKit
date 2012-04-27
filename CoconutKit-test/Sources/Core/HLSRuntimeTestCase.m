//
//  HLSRuntimeTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 27.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSRuntimeTestCase.h"

#pragma mark Test classes

@protocol RuntimeTestFormalProtocolA <NSObject>

@required
- (void)methodA1;

@optional
- (void)methodA2;

@end

@protocol RuntimeTestFormalSubProtocolA <RuntimeTestFormalProtocolA>

@required
- (void)methodA3;

@optional
- (void)methodA4;

@end

@protocol RuntimeTestInformalProtocolA <NSObject>

@optional
- (void)methodA2;

@required
- (void)methodA3;

@end

@protocol RuntimeTestFormalProtocolB <NSObject>

@required
- (void)methodB1;

@optional
- (void)methodB2;

@end

@interface RuntimeTestClass1 : NSObject <RuntimeTestFormalProtocolA> {
@private

}

@end

@implementation RuntimeTestClass1

- (void)methodA1
{}

- (void)methodA2
{}

@end

@interface RuntimeTestSubclass11 : RuntimeTestClass1 <RuntimeTestFormalProtocolB>

@end

@implementation RuntimeTestSubclass11

- (void)methodB1
{}

- (void)methodB2
{}

@end

@interface RuntimeTestSubclass12 : RuntimeTestClass1 <RuntimeTestFormalProtocolB>

@end

@implementation RuntimeTestSubclass12

- (void)methodB1
{}

@end

@interface RuntimeTestClass2 : NSObject <RuntimeTestFormalProtocolA>

@end

@implementation RuntimeTestClass2

- (void)methodA1
{}

@end

@interface RuntimeTestClass3 : NSObject    // Informally conforms to RuntimeTestInformalProtocolA

@end

@implementation RuntimeTestClass3

- (void)methodA2
{}

- (void)methodA3
{}

@end

@interface RuntimeTestClass4 : NSObject    // Informally conforms to RuntimeTestInformalProtocolA

@end

@implementation RuntimeTestClass4

- (void)methodA3
{}

@end

@interface RuntimeTestClass5 : NSObject <RuntimeTestFormalSubProtocolA>

@end

@implementation RuntimeTestClass5

- (void)methodA1
{}

- (void)methodA2
{}

- (void)methodA3
{}

- (void)methodA4
{}

@end

@interface RuntimeTestClass6   // No NSObject superclass, no protocol

@end

@implementation RuntimeTestClass6

@end

@interface RuntimeTestClass7 : NSObject

@end

// Protocols on class categories (BAD IDEA!). The class is NOT considered to conform to 
// the protocol at runtime
@interface RuntimeTestClass7 () <RuntimeTestFormalProtocolA>

@end

@implementation RuntimeTestClass7

// Method body mandatory for @required methods. At least this is not too bad
- (void)methodA1
{}

@end

@interface RuntimeTestClass8 : NSObject

@end

// Protocols on class extensions (BAD IDEA!). The class is NOT considered to conform to 
// the protocol at runtime
@interface RuntimeTestClass8 (Category) <RuntimeTestFormalProtocolA>

// Method body not even mandatory for @required methods! Bad!

@end

@implementation RuntimeTestClass8

@end

#pragma mark Test case implementation

@implementation HLSRuntimeTestCase

#pragma mark Tests

- (void)test_class_copyProtocolList
{

}

- (void)test_class_conformsToProtocol
{
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass1 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass11 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass12 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass2 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass3 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass4 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass5 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass6"), @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass6"), @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass6"), @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass6"), @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass6"), @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalProtocolB)), nil);
}

- (void)test_class_conformsToInformalProtocol
{

}

- (void)test_class_implementsProtocol
{

}

- (void)test_class_swizzleClassMethod
{

}

- (void)test_class_swizzleInstanceMethod
{

}

@end
