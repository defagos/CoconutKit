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
+ (void)classMethodA1;
- (void)methodA1;

@optional
+ (void)classMethodA2;
- (void)methodA2;

@end

@protocol RuntimeTestFormalSubProtocolA <RuntimeTestFormalProtocolA>

@required
- (void)methodA3;
+ (void)classMethodA3;

@optional
- (void)methodA4;
+ (void)classMethodA4;

@end

@protocol RuntimeTestInformalProtocolA <NSObject>

@optional
- (void)methodA2;
+ (void)classMethodA2;

@required
- (void)methodA3;
+ (void)classMethodA3;

@end

@protocol RuntimeTestFormalProtocolB <NSObject>

@required
- (void)methodB1;
+ (void)classMethodB1;

@optional
- (void)methodB2;
+ (void)classMethodB2;

@end

@protocol RuntimeTestCompositeProtocol <RuntimeTestFormalProtocolA, RuntimeTestInformalProtocolA, RuntimeTestFormalProtocolB>

@required
- (void)methodC1;
+ (void)classMethodC1;

@optional
- (void)methodC2;
+ (void)classMethodC2;

@end

@interface RuntimeTestClass1 : NSObject <RuntimeTestFormalProtocolA>

@end

@implementation RuntimeTestClass1

- (void)methodA1
{}

+ (void)classMethodA1
{}

- (void)methodA2
{}

+ (void)classMethodA2
{}

@end

@interface RuntimeTestSubclass11 : RuntimeTestClass1 <RuntimeTestFormalProtocolB>

@end

@implementation RuntimeTestSubclass11

- (void)methodB1
{}

+ (void)classMethodB1
{}

- (void)methodB2
{}

+ (void)classMethodB2
{}

@end

@interface RuntimeTestSubclass12 : RuntimeTestClass1 <RuntimeTestFormalProtocolB>

@end

@implementation RuntimeTestSubclass12

- (void)methodB1
{}

+ (void)classMethodB1
{}

@end

@interface RuntimeTestClass2 : NSObject <RuntimeTestFormalProtocolA>

@end

@implementation RuntimeTestClass2

- (void)methodA1
{}

+ (void)classMethodA1
{}

@end

@interface RuntimeTestClass3 : NSObject    // Informally conforms to RuntimeTestInformalProtocolA

@end

@implementation RuntimeTestClass3

- (void)methodA2
{}

+ (void)classMethodA2
{}

- (void)methodA3
{}

+ (void)classMethodA3
{}

@end

@interface RuntimeTestClass4 : NSObject    // Informally conforms to RuntimeTestInformalProtocolA

@end

@implementation RuntimeTestClass4

- (void)methodA3
{}

+ (void)classMethodA3
{}

@end

@interface RuntimeTestClass5 : NSObject <RuntimeTestFormalSubProtocolA>

@end

@implementation RuntimeTestClass5

- (void)methodA1
{}

+ (void)classMethodA1
{}

- (void)methodA2
{}

+ (void)classMethodA2
{}

- (void)methodA3
{}

+ (void)classMethodA3
{}

- (void)methodA4
{}

+ (void)classMethodA4
{}

@end

@interface RuntimeTestClass6 : NSObject <RuntimeTestFormalSubProtocolA>

@end

@implementation RuntimeTestClass6

- (void)methodA1
{}

+ (void)classMethodA1
{}

- (void)methodA3
{}

+ (void)classMethodA3
{}

@end

@interface RuntimeTestClass7 : NSObject

@end

// Protocols on class categories (bad idea in general, this hides important information for
// subclassers)
@interface RuntimeTestClass7 () <RuntimeTestFormalSubProtocolA>

@end

@implementation RuntimeTestClass7

// Method body mandatory for @required methods. At least this is not too bad
- (void)methodA1
{}

+ (void)classMethodA1
{}

- (void)methodA3
{}

+ (void)classMethodA3
{}

@end

@interface RuntimeTestClass8 : NSObject

@end

// Protocols on class extensions (bad idea in general, this decreases interface locality,
// and bypasses compiler checks, most). Moreover, the class is NOT considered conforming
// to the protocol
@interface RuntimeTestClass8 (Category) <RuntimeTestFormalSubProtocolA>

// Method body not even mandatory for @required methods! Bad!

@end

@implementation RuntimeTestClass8

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-root-class"
@interface RuntimeTestClass9   // No NSObject superclass, no protocol
#pragma clang diagnostic pop

@end

@implementation RuntimeTestClass9

@end

#pragma mark Test case implementation

@implementation HLSRuntimeTestCase

#pragma mark Tests

- (void)test_protocol_copyMethodDescriptionList
{
    unsigned int NSObject_numberOfRequiredClassMethods = 0;
    struct objc_method_description *NSObject_requiredClassMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(NSObject), YES, NO, &NSObject_numberOfRequiredClassMethods);
    GHAssertNULL(NSObject_requiredClassMethodDescriptions, nil);
    GHAssertEquals(NSObject_numberOfRequiredClassMethods, 0U, nil);
    free(NSObject_requiredClassMethodDescriptions);
    
    unsigned int NSObject_numberOfRequiredInstanceMethods = 0;
    struct objc_method_description *NSObject_requiredInstanceMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(NSObject), YES, YES, &NSObject_numberOfRequiredInstanceMethods);
    GHAssertNotNULL(NSObject_requiredInstanceMethodDescriptions, nil);
    // Prior to iOS 7, -debugDescription is @required, even though marked as @optional. Fixed in iOS 7
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        GHAssertEquals(NSObject_numberOfRequiredInstanceMethods, 20U, nil);
    }
    else {
        GHAssertEquals(NSObject_numberOfRequiredInstanceMethods, 19U, nil);
    }
    free(NSObject_requiredInstanceMethodDescriptions);

    unsigned int NSObject_numberOfOptionalClassMethods = 0;
    struct objc_method_description *NSObject_optionalClassMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(NSObject), NO, NO, &NSObject_numberOfOptionalClassMethods);
    GHAssertNULL(NSObject_requiredClassMethodDescriptions, nil);
    GHAssertEquals(NSObject_numberOfOptionalClassMethods, 0U, nil);
    free(NSObject_optionalClassMethodDescriptions);
    
    unsigned int NSObject_numberOfOptionalInstanceMethods = 0;
    struct objc_method_description *NSObject_optionalInstanceMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(NSObject), NO, YES, &NSObject_numberOfOptionalInstanceMethods);
    GHAssertNotNULL(NSObject_requiredInstanceMethodDescriptions, nil);
    // Prior to iOS 7, -debugDescription is @required, even though marked as @optional. Fixed in iOS 7
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        GHAssertEquals(NSObject_numberOfOptionalInstanceMethods, 0U, nil);
    }
    else {
        GHAssertEquals(NSObject_numberOfOptionalInstanceMethods, 1U, nil);
    }
    free(NSObject_optionalInstanceMethodDescriptions);
    
    unsigned int RuntimeTestCompositeProtocol_numberOfRequiredClassMethods = 0;
    struct objc_method_description *RuntimeTestCompositeProtocol_requiredClassMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(RuntimeTestCompositeProtocol),
                                                                                                                                          YES,
                                                                                                                                          NO,
                                                                                                                                          &RuntimeTestCompositeProtocol_numberOfRequiredClassMethods);
    GHAssertNotNULL(RuntimeTestCompositeProtocol_requiredClassMethodDescriptions, nil);
    GHAssertEquals(RuntimeTestCompositeProtocol_numberOfRequiredClassMethods - NSObject_numberOfRequiredClassMethods, 4U, nil);
    free(RuntimeTestCompositeProtocol_requiredClassMethodDescriptions);
    
    unsigned int RuntimeTestCompositeProtocol_numberOfRequiredInstanceMethods = 0;
    struct objc_method_description *RuntimeTestCompositeProtocol_requiredInstanceMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(RuntimeTestCompositeProtocol),
                                                                                                                                             YES,
                                                                                                                                             YES,
                                                                                                                                             &RuntimeTestCompositeProtocol_numberOfRequiredInstanceMethods);
    GHAssertNotNULL(RuntimeTestCompositeProtocol_requiredInstanceMethodDescriptions, nil);
    GHAssertEquals(RuntimeTestCompositeProtocol_numberOfRequiredInstanceMethods - NSObject_numberOfRequiredInstanceMethods, 4U, nil);
    free(RuntimeTestCompositeProtocol_requiredInstanceMethodDescriptions);
    
    unsigned int RuntimeTestCompositeProtocol_numberOfOptionalClassMethods = 0;
    struct objc_method_description *RuntimeTestCompositeProtocol_optionalClassMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(RuntimeTestCompositeProtocol),
                                                                                                                                          NO,
                                                                                                                                          NO,
                                                                                                                                          &RuntimeTestCompositeProtocol_numberOfOptionalClassMethods);
    GHAssertNotNULL(RuntimeTestCompositeProtocol_optionalClassMethodDescriptions, nil);
    GHAssertEquals(RuntimeTestCompositeProtocol_numberOfOptionalClassMethods - NSObject_numberOfOptionalClassMethods, 3U, nil);                 // +classMethodA2 appears twice, counted once
    free(RuntimeTestCompositeProtocol_optionalClassMethodDescriptions);
    
    unsigned int RuntimeTestCompositeProtocol_numberOfOptionalInstanceMethods = 0;
    struct objc_method_description *RuntimeTestCompositeProtocol_optionalInstanceMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(RuntimeTestCompositeProtocol),
                                                                                                                                             NO,
                                                                                                                                             YES,
                                                                                                                                             &RuntimeTestCompositeProtocol_numberOfOptionalInstanceMethods);
    GHAssertNotNULL(RuntimeTestCompositeProtocol_optionalInstanceMethodDescriptions, nil);
    GHAssertEquals(RuntimeTestCompositeProtocol_numberOfOptionalInstanceMethods - NSObject_numberOfOptionalInstanceMethods, 3U, nil);           // -methodA2 appears twice, counted once
    free(RuntimeTestCompositeProtocol_optionalInstanceMethodDescriptions);
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
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass6 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalProtocolB)), nil);
}

- (void)test_class_conformsToInformalProtocol
{
    GHAssertFalse(hls_class_conformsToInformalProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToInformalProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToInformalProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToInformalProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertTrue(hls_class_conformsToInformalProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertTrue(hls_class_conformsToInformalProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertTrue(hls_class_conformsToInformalProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertTrue(hls_class_conformsToInformalProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertTrue(hls_class_conformsToInformalProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToInformalProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_conformsToInformalProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestInformalProtocolA)), nil);
}

// This tests hls_class_implementsProtocolMethods as well
- (void)test_class_implementsProtocol
{
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass1 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestSubclass11 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestSubclass12 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass2 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass3 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass4 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass5 class], @protocol(NSObject)), nil);
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass6 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass7 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertTrue(hls_class_implementsProtocol([RuntimeTestClass8 class], @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalProtocolB)), nil);
    
    GHAssertFalse(hls_class_implementsProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(NSObject)), nil);
    GHAssertFalse(hls_class_implementsProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalSubProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestInformalProtocolA)), nil);
    GHAssertFalse(hls_class_implementsProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalProtocolB)), nil);
}

- (void)test_class_isSubclassOfClass
{
    GHAssertTrue(hls_class_isSubclassOfClass([UIView class], [NSObject class]), nil);
    GHAssertTrue(hls_class_isSubclassOfClass([UIView class], [UIView class]), nil);
    GHAssertFalse(hls_class_isSubclassOfClass([NSObject class], [UIView class]), nil);
    GHAssertFalse(hls_class_isSubclassOfClass([UIView class], [UIViewController class]), nil);
}

@end
