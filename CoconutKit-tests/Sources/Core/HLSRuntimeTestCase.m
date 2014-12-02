//
//  HLSRuntimeTestCase.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 27.04.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
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

@interface RuntimeTestClass10 : NSObject

// Primitive integer type as return value
+ (NSInteger)classMagicalInteger;
- (NSInteger)instanceMagicalInteger;

// Primitive floating-point type as return value
+ (float)classMagicalFloat;
- (float)instanceMagicalFloat;

// Object as return value
+ (NSString *)classMagicalString;
- (NSString *)instanceMagicalString;

// Struct as return value
+ (CGPoint)classMagicalPoint;
- (CGPoint)instanceMagicalPoint;

// Parameters
- (NSString *)instanceMethodJoiningInteger:(NSInteger)i float:(float)f string:(NSString *)s point:(CGPoint)p;
- (NSString *)instanceVariadicMethodJoiningStrings:(NSString *)firstString stringList:(va_list)stringList;
- (NSString *)instanceVariadicMethodJoiningStrings:(NSString *)firstString, ... NS_REQUIRES_NIL_TERMINATION;

@end

@implementation RuntimeTestClass10

+ (NSInteger)classMagicalInteger
{
    return 420;
}
- (NSInteger)instanceMagicalInteger
{
    return 420;
}

+ (float)classMagicalFloat
{
    return 420.f;
}

- (float)instanceMagicalFloat
{
    return 420.f;
}

+ (NSString *)classMagicalString
{
    return @"Tom";
}

- (NSString *)instanceMagicalString
{
    return @"Tom";
}

+ (CGPoint)classMagicalPoint
{
    return CGPointMake(420.f, 420.f);
}
- (CGPoint)instanceMagicalPoint
{
    return CGPointMake(420.f, 420.f);
}

- (NSString *)instanceMethodJoiningInteger:(NSInteger)i float:(float)f string:(NSString *)s point:(CGPoint)p
{
    return [NSString stringWithFormat:@"%@,%@,%@,%@,%@", @(i), @(f), s, @(p.x), @(p.y)];
}

- (NSString *)instanceVariadicMethodJoiningStrings:(NSString *)firstString stringList:(va_list)stringList
{
    NSMutableArray *strings = [NSMutableArray arrayWithObject:firstString];
    
    NSString *string = va_arg(stringList, NSString *);
    while (string) {
        [strings addObject:string];
        string = va_arg(stringList, NSString *);
    }
    
    return [strings componentsJoinedByString:@","];
}

- (NSString *)instanceVariadicMethodJoiningStrings:(NSString *)firstString, ...
{
    va_list args;
    
    va_start(args, firstString);
    NSString *string = [self instanceVariadicMethodJoiningStrings:firstString stringList:args];
    va_end(args);
    
    return string;
}

@end

@interface RuntimeTestClass10 (Swizzling)

@end

@implementation RuntimeTestClass10 (Swizzling)

+ (void)load
{
    // Swizzle to get 42 as a result
    __block IMP originalClassMagicalIntegerImp = hls_class_swizzleClassSelector_block(self, @selector(classMagicalInteger), ^(RuntimeTestClass10 *self_) {
        return ((NSInteger (*)(id, SEL))originalClassMagicalIntegerImp)(self_, @selector(classMagicalInteger)) / 10;
    });
    __block IMP originalInstanceMagicalIntegerImp = hls_class_swizzleSelector_block(self, @selector(instanceMagicalInteger), ^(RuntimeTestClass10 *self_) {
        return ((NSInteger (*)(id, SEL))originalInstanceMagicalIntegerImp)(self_, @selector(instanceMagicalInteger)) / 10;
    });
    
    __block IMP originalClassMagicalFloatImp = hls_class_swizzleClassSelector_block(self, @selector(classMagicalFloat), ^(RuntimeTestClass10 *self_) {
        return ((float (*)(id, SEL))originalClassMagicalFloatImp)(self_, @selector(classMagicalFloat)) / 10.f;
    });
    __block IMP originalInstanceMagicalFloatImp = hls_class_swizzleSelector_block(self, @selector(instanceMagicalFloat), ^(RuntimeTestClass10 *self_) {
        return ((float (*)(id, SEL))originalInstanceMagicalFloatImp)(self_, @selector(instanceMagicalFloat)) / 10.f;
    });
    
    // Swizzle to uppercase
    __block IMP originalClassMagicalStringImp = hls_class_swizzleClassSelector_block(self, @selector(classMagicalString), ^(RuntimeTestClass10 *self_) {
        return [((id (*)(id, SEL))originalClassMagicalStringImp)(self_, @selector(classMagicalString)) uppercaseString];
    });
    __block IMP originalInstanceMagicalStringImp = hls_class_swizzleSelector_block(self, @selector(instanceMagicalString), ^(RuntimeTestClass10 *self_) {
        return [((id (*)(id, SEL))originalInstanceMagicalStringImp)(self_, @selector(instanceMagicalInteger)) uppercaseString];
    });
    
    // Swizzle to get (42, 42) as a result
    __block IMP originalClassMagicalPointImp = hls_class_swizzleClassSelector_block(self, @selector(classMagicalPoint), ^(RuntimeTestClass10 *self_) {
        CGPoint point = ((CGPoint (*)(id, SEL))originalClassMagicalPointImp)(self_, @selector(classMagicalPoint));
        return CGPointMake(point.x / 10.f, point.y / 10.f);
    });
    __block IMP originalInstanceMagicalPointImp = hls_class_swizzleSelector_block(self, @selector(instanceMagicalPoint), ^(RuntimeTestClass10 *self_) {
        CGPoint point = ((CGPoint (*)(id, SEL))originalInstanceMagicalPointImp)(self_, @selector(instanceMagicalInteger));
        return CGPointMake(point.x / 10.f, point.y / 10.f);
    });
    
    // Replace ',' with '.' as separator
    __block IMP originalInstanceMethodJoiningIntegerFloatStringPointImp = hls_class_swizzleSelector_block(self, @selector(instanceMethodJoiningInteger:float:string:point:), ^(RuntimeTestClass10 *self_, NSInteger i, float f, NSString *s, CGPoint p) {
        NSString *joinedString = ((id (*)(id, SEL, NSInteger, float, id, CGPoint))originalInstanceMethodJoiningIntegerFloatStringPointImp)(self_, @selector(instanceMethodJoiningInteger:float:string:point:), i, f, s, p);
        return [joinedString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    });
    
    // Cannot swizzle functions with ellipsis (cannot forward the call to the original implementation). Must swizzle the method with va_list if available (of course, here available :) )
    __block IMP originalInstanceVariadicMethodJoiningStringsStringListImp = hls_class_swizzleSelector_block(self, @selector(instanceVariadicMethodJoiningStrings:stringList:), ^(RuntimeTestClass10 *self_, NSString *firstString, va_list stringList) {
        NSString *joinedString = ((id (*)(id, SEL, id, va_list))originalInstanceVariadicMethodJoiningStringsStringListImp)(self_, @selector(instanceVariadicMethodJoiningStrings:stringList:), firstString, stringList);
        return [joinedString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    });
}

@end

@interface RuntimeTestClass11 : NSObject

+ (NSString *)testString;

@end

@implementation RuntimeTestClass11

+ (NSString *)testString
{
    return @"A";
}

@end

@interface RuntimeTestClass11 (Swizzling)

@end

@implementation RuntimeTestClass11 (Swizzling)

+ (void)load
{
    // Test multiple swizzlings of the same method
    __block IMP originalTestStringImp1 = hls_class_swizzleClassSelector_block(self, @selector(testString), ^(id self_) {
        return [((id (*)(id, SEL))originalTestStringImp1)(self_, @selector(testString)) stringByAppendingString:@"B"];
    });
    
    __block IMP originalTestStringImp2 = hls_class_swizzleClassSelector_block(self, @selector(testString), ^(id self_) {
        return [((id (*)(id, SEL))originalTestStringImp2)(self_, @selector(testString)) stringByAppendingString:@"C"];
    });

    __block IMP originalTestStringImp3 = hls_class_swizzleClassSelector_block(self, @selector(testString), ^(id self_) {
        return [((id (*)(id, SEL))originalTestStringImp3)(self_, @selector(testString)) stringByAppendingString:@"D"];
    });

    __block IMP originalTestStringImp4 = hls_class_swizzleClassSelector_block(self, @selector(testString), ^(id self_) {
        return [((id (*)(id, SEL))originalTestStringImp4)(self_, @selector(testString)) stringByAppendingString:@"E"];
    });
}

@end

@interface RuntimeTestClass12 : NSObject

+ (NSString *)topClassMethod;
- (NSString *)topMethod;

@end

@implementation RuntimeTestClass12

+ (NSString *)topClassMethod
{
    return @"1";
}

- (NSString *)topMethod
{
    return @"A";
}

@end

@interface RuntimeTestSubClass121 : RuntimeTestClass12

// Does not override +topClassMethod / -topMethod

@end

@implementation RuntimeTestSubClass121

@end

@interface RuntimeTestSubClass121 (Swizzling)

@end

@implementation RuntimeTestSubClass121 (Swizzling)

+ (void)load
{
    // Swizzling of non-overridden methods in class hierarchies (see HLSRuntime.m for an explanation)
    __block IMP originalTopClassMethodImp = hls_class_swizzleClassSelector_block(self, @selector(topClassMethod), ^(RuntimeTestSubClass121 *self_) {
        return [((id (*)(id, SEL))originalTopClassMethodImp)(self_, @selector(topClassMethod)) stringByAppendingString:@"2"];
    });
    __block IMP originalTopMethodImp = hls_class_swizzleSelector_block(self, @selector(topMethod), ^(RuntimeTestSubClass121 *self_) {
        return [((id (*)(id, SEL))originalTopMethodImp)(self_, @selector(topMethod)) stringByAppendingString:@"B"];
    });
}

@end

@interface RuntimeTestSubSubClass1211 : RuntimeTestSubClass121

// Does not override +topClassMethod / -topMethod

@end

@implementation RuntimeTestSubSubClass1211

@end

@interface RuntimeTestSubSubClass1211 (Swizzling)

@end

@implementation RuntimeTestSubSubClass1211 (Swizzling)

+ (void)load
{
    // Swizzling of non-overridden methods in class hierarchies (see HLSRuntime.m for an explanation)
    __block IMP originalTopClassMethodImp = hls_class_swizzleClassSelector_block(self, @selector(topClassMethod), ^(RuntimeTestSubSubClass1211 *self_) {
        return [((id (*)(id, SEL))originalTopClassMethodImp)(self_, @selector(topClassMethod)) stringByAppendingString:@"3"];
    });
    __block IMP originalTopMethodImp = hls_class_swizzleSelector_block(self, @selector(topMethod), ^(RuntimeTestSubSubClass1211 *self_) {
        return [((id (*)(id, SEL))originalTopMethodImp)(self_, @selector(topMethod)) stringByAppendingString:@"C"];
    });
}

@end

#pragma mark Test case implementation

@implementation HLSRuntimeTestCase

#pragma mark Tests

- (void)testProtocolCopyMethodDescriptionList
{
    unsigned int NSObject_numberOfRequiredClassMethods = 0;
    struct objc_method_description *NSObject_requiredClassMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(NSObject), YES, NO, &NSObject_numberOfRequiredClassMethods);
    XCTAssertTrue(NSObject_requiredClassMethodDescriptions == NULL);
    XCTAssertEqual(NSObject_numberOfRequiredClassMethods, (unsigned int)0);
    free(NSObject_requiredClassMethodDescriptions);
    
    unsigned int NSObject_numberOfRequiredInstanceMethods = 0;
    struct objc_method_description *NSObject_requiredInstanceMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(NSObject), YES, YES, &NSObject_numberOfRequiredInstanceMethods);
    XCTAssertTrue(NSObject_requiredInstanceMethodDescriptions != NULL);
    XCTAssertEqual(NSObject_numberOfRequiredInstanceMethods, (unsigned int)19);
    free(NSObject_requiredInstanceMethodDescriptions);

    unsigned int NSObject_numberOfOptionalClassMethods = 0;
    struct objc_method_description *NSObject_optionalClassMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(NSObject), NO, NO, &NSObject_numberOfOptionalClassMethods);
    XCTAssertTrue(NSObject_requiredClassMethodDescriptions == NULL);
    XCTAssertEqual(NSObject_numberOfOptionalClassMethods, (unsigned int)0);
    free(NSObject_optionalClassMethodDescriptions);
    
    unsigned int NSObject_numberOfOptionalInstanceMethods = 0;
    struct objc_method_description *NSObject_optionalInstanceMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(NSObject), NO, YES, &NSObject_numberOfOptionalInstanceMethods);
    XCTAssertTrue(NSObject_requiredInstanceMethodDescriptions != NULL);
    XCTAssertEqual(NSObject_numberOfOptionalInstanceMethods, (unsigned int)1);
    free(NSObject_optionalInstanceMethodDescriptions);
    
    unsigned int RuntimeTestCompositeProtocol_numberOfRequiredClassMethods = 0;
    struct objc_method_description *RuntimeTestCompositeProtocol_requiredClassMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(RuntimeTestCompositeProtocol),
                                                                                                                                          YES,
                                                                                                                                          NO,
                                                                                                                                          &RuntimeTestCompositeProtocol_numberOfRequiredClassMethods);
    XCTAssertTrue(RuntimeTestCompositeProtocol_requiredClassMethodDescriptions != NULL);
    XCTAssertEqual(RuntimeTestCompositeProtocol_numberOfRequiredClassMethods - NSObject_numberOfRequiredClassMethods, (unsigned int)4);
    free(RuntimeTestCompositeProtocol_requiredClassMethodDescriptions);
    
    unsigned int RuntimeTestCompositeProtocol_numberOfRequiredInstanceMethods = 0;
    struct objc_method_description *RuntimeTestCompositeProtocol_requiredInstanceMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(RuntimeTestCompositeProtocol),
                                                                                                                                             YES,
                                                                                                                                             YES,
                                                                                                                                             &RuntimeTestCompositeProtocol_numberOfRequiredInstanceMethods);
    XCTAssertTrue(RuntimeTestCompositeProtocol_requiredInstanceMethodDescriptions != NULL);
    XCTAssertEqual(RuntimeTestCompositeProtocol_numberOfRequiredInstanceMethods - NSObject_numberOfRequiredInstanceMethods, (unsigned int)4);
    free(RuntimeTestCompositeProtocol_requiredInstanceMethodDescriptions);
    
    unsigned int RuntimeTestCompositeProtocol_numberOfOptionalClassMethods = 0;
    struct objc_method_description *RuntimeTestCompositeProtocol_optionalClassMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(RuntimeTestCompositeProtocol),
                                                                                                                                          NO,
                                                                                                                                          NO,
                                                                                                                                          &RuntimeTestCompositeProtocol_numberOfOptionalClassMethods);
    XCTAssertTrue(RuntimeTestCompositeProtocol_optionalClassMethodDescriptions != NULL);
    XCTAssertEqual(RuntimeTestCompositeProtocol_numberOfOptionalClassMethods - NSObject_numberOfOptionalClassMethods, (unsigned int)3);                 // +classMethodA2 appears twice, counted once
    free(RuntimeTestCompositeProtocol_optionalClassMethodDescriptions);
    
    unsigned int RuntimeTestCompositeProtocol_numberOfOptionalInstanceMethods = 0;
    struct objc_method_description *RuntimeTestCompositeProtocol_optionalInstanceMethodDescriptions = hls_protocol_copyMethodDescriptionList(@protocol(RuntimeTestCompositeProtocol),
                                                                                                                                             NO,
                                                                                                                                             YES,
                                                                                                                                             &RuntimeTestCompositeProtocol_numberOfOptionalInstanceMethods);
    XCTAssertTrue(RuntimeTestCompositeProtocol_optionalInstanceMethodDescriptions != NULL);
    XCTAssertEqual(RuntimeTestCompositeProtocol_numberOfOptionalInstanceMethods - NSObject_numberOfOptionalInstanceMethods, (unsigned int)3);           // -methodA2 appears twice, counted once
    free(RuntimeTestCompositeProtocol_optionalInstanceMethodDescriptions);
}

- (void)testClassConformsToProtocol
{
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass1 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass11 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass12 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass2 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass3 class], @protocol(NSObject)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass4 class], @protocol(NSObject)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass5 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass6 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(NSObject)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(NSObject)));
    XCTAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalProtocolB)));
}

- (void)testClassConformsToInformalProtocol
{
    XCTAssertFalse(hls_class_conformsToInformalProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToInformalProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToInformalProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToInformalProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertTrue(hls_class_conformsToInformalProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertTrue(hls_class_conformsToInformalProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertTrue(hls_class_conformsToInformalProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertTrue(hls_class_conformsToInformalProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertTrue(hls_class_conformsToInformalProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToInformalProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_conformsToInformalProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestInformalProtocolA)));
}

// This tests hls_class_implementsProtocolMethods as well
- (void)testClassImplementsProtocol
{
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass1 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass1 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestSubclass11 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestSubclass11 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestSubclass12 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestSubclass12 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass2 class], @protocol(NSObject)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass2 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass3 class], @protocol(NSObject)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass3 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass4 class], @protocol(NSObject)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass4 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass5 class], @protocol(NSObject)));
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass5 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass6 class], @protocol(NSObject)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass6 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass7 class], @protocol(NSObject)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass7 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertTrue(hls_class_implementsProtocol([RuntimeTestClass8 class], @protocol(NSObject)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol([RuntimeTestClass8 class], @protocol(RuntimeTestFormalProtocolB)));
    
    XCTAssertFalse(hls_class_implementsProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(NSObject)));
    XCTAssertFalse(hls_class_implementsProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalSubProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestInformalProtocolA)));
    XCTAssertFalse(hls_class_implementsProtocol(NSClassFromString(@"RuntimeTestClass9"), @protocol(RuntimeTestFormalProtocolB)));
}

- (void)testSwizzling
{
    // Swizzling has been made in a +load. We here simply check that expected values after swizzling are correct
    XCTAssertEqual([RuntimeTestClass10 classMagicalInteger], (NSInteger)42);
    XCTAssertEqual([[RuntimeTestClass10 new] instanceMagicalInteger], (NSInteger)42);
    
    XCTAssertEqual([RuntimeTestClass10 classMagicalFloat], 42.f);
    XCTAssertEqual([[RuntimeTestClass10 new] instanceMagicalFloat], 42.f);
    
    XCTAssertEqualObjects([RuntimeTestClass10 classMagicalString], @"TOM");
    XCTAssertEqualObjects([[RuntimeTestClass10 new] instanceMagicalString], @"TOM");
    
    CGPoint expectedPoint = CGPointMake(42.f, 42.f);
    XCTAssertTrue(CGPointEqualToPoint([RuntimeTestClass10 classMagicalPoint], expectedPoint));
    XCTAssertTrue(CGPointEqualToPoint([[RuntimeTestClass10 new] instanceMagicalPoint], expectedPoint));
    
    XCTAssertEqualObjects([[RuntimeTestClass10 new] instanceMethodJoiningInteger:42 float:42.f string:@"42" point:CGPointMake(42.f, 42.f)], @"42.42.42.42.42");
    
    NSString *joinedString1 = [[RuntimeTestClass10 new] instanceVariadicMethodJoiningStrings:@"42", @"42", @"42", nil];
    XCTAssertEqualObjects(joinedString1, @"42.42.42");
    NSString *joinedString2 = [[RuntimeTestClass10 new] instanceVariadicMethodJoiningStrings:@"42", @"42", @"42", @"42", @"42", nil];
    XCTAssertEqualObjects(joinedString2, @"42.42.42.42.42");
    
    // Multiple swizzling
    XCTAssertEqualObjects([RuntimeTestClass11 testString], @"ABCDE");
    
    // Swizzling of non-overridden methods in class hierarchies (see HLSRuntime.m for an explanation)
    XCTAssertEqualObjects([RuntimeTestSubClass121 topClassMethod], @"12");
    XCTAssertEqualObjects([RuntimeTestSubSubClass1211 topClassMethod], @"123");
    
    XCTAssertEqualObjects([[RuntimeTestSubClass121 new] topMethod], @"AB");
    XCTAssertEqualObjects([[RuntimeTestSubSubClass1211 new] topMethod], @"ABC");
    
    // Failures
    XCTAssertTrue(hls_class_swizzleSelector([RuntimeTestClass11 class], NSSelectorFromString(@"unknownSelector"), nil) == NULL);
}

- (void)testClassIsSubclassOfClass
{
    XCTAssertTrue(hls_class_isSubclassOfClass([UIView class], [NSObject class]));
    XCTAssertTrue(hls_class_isSubclassOfClass([UIView class], [UIView class]));
    XCTAssertFalse(hls_class_isSubclassOfClass([NSObject class], [UIView class]));
    XCTAssertFalse(hls_class_isSubclassOfClass([UIView class], [UIViewController class]));
}

- (void)testAssociatedObjects
{
    // ASSIGN is not weak, as for the usual objc_setAssociatedObject
    static void *kAssociatedObject1Key = &kAssociatedObject1Key;
    NSObject *object1 = [[NSObject alloc] init];
    __weak NSObject *weakObject1 = object1;

    // Used to update weak references to their final values
    @autoreleasepool {
        XCTAssertNotNil(weakObject1);
        
        hls_setAssociatedObject(self, kAssociatedObject1Key, object1, HLS_ASSOCIATION_ASSIGN);
        XCTAssertNotNil(hls_getAssociatedObject(self, kAssociatedObject1Key));
        
        object1 = nil;
        
        // Cannot access hls_getAssociatedObject(self, kAssociatedObject1Key) since this would most probably crash!
        // Accessing a deallocated associated object namely crashes, exactly like calling a selector on a deallocated object
    }
    
    XCTAssertNil(weakObject1);
    
    // WEAK
    static void *kAssociatedObject2Key = &kAssociatedObject2Key;
    NSObject *object2 = [[NSObject alloc] init];
    __weak NSObject *weakObject2 = object2;

    // Used to update weak references to their final values
    @autoreleasepool {
        XCTAssertNotNil(weakObject2);
    
        hls_setAssociatedObject(self, kAssociatedObject2Key, object2, HLS_ASSOCIATION_WEAK);
        XCTAssertNotNil(hls_getAssociatedObject(self, kAssociatedObject2Key));
    
        object2 = nil;        
    }
    
    XCTAssertNil(weakObject2);
    
    // Can safely access hls_getAssociatedObject(self, kAssociatedObject2Key). object2 is now deallocated because of
    // the autorelease pool drain, but the reference is weak and has been nilled
    XCTAssertNil(hls_getAssociatedObject(self, kAssociatedObject2Key));
    
    // Check that objc_ and hls_ functions are indenpendent
    static void *kAssociatedObject3Key = &kAssociatedObject3Key;
    NSObject *object3 = [[NSObject alloc] init];
    objc_setAssociatedObject(self, kAssociatedObject3Key, object3, OBJC_ASSOCIATION_RETAIN);
    XCTAssertNotNil(objc_getAssociatedObject(self, kAssociatedObject3Key));
    XCTAssertNil(hls_getAssociatedObject(self, kAssociatedObject3Key));
    
    static void *kAssociatedObject4Key = &kAssociatedObject4Key;
    NSObject *object4 = [[NSObject alloc] init];
    hls_setAssociatedObject(self, kAssociatedObject4Key, object4, HLS_ASSOCIATION_STRONG);
    XCTAssertNotNil(hls_getAssociatedObject(self, kAssociatedObject4Key));
    XCTAssertNil(objc_getAssociatedObject(self, kAssociatedObject4Key));
    
    objc_removeAssociatedObjects(self);
}

@end
