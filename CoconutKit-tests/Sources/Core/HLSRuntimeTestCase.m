//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSRuntimeTestCase.h"

#import <CoreLocation/CoreLocation.h>

typedef struct SmallStruct_ {
    NSInteger i;
} SmallStruct;

typedef struct LargeStruct_ {
    float values[50];
} LargeStruct;

typedef union SmallUnion_ {
    NSInteger i;
    char c;
} SmallUnion;

typedef union LargeUnion_ {
    LargeStruct largeStruct;
    NSInteger i;
} LargeUnion;

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

// Object as return value
+ (NSString *)classString;
- (NSString *)instanceString;

// Primitive integer type as return value
- (NSInteger)instanceInteger;

// Primitive floating-point type as return value
- (float)instanceFloat;
- (double)instanceDouble;
- (CGFloat)instanceCGFloat;

// Void
- (void)instanceVoidReturningIntegerByReference:(NSInteger *)pValue;

// Struct as return value
- (CGPoint)instancePoint;
- (CLLocationCoordinate2D)instanceLocationCoordinate;
- (SmallStruct)instanceSmallStruct;
- (LargeStruct)instanceLargeStruct;
- (SmallUnion)instanceSmallUnion;
- (LargeUnion)instanceLargeUnion;

// Parameters
- (NSString *)instanceMethodJoiningInteger:(NSInteger)i float:(float)f string:(NSString *)s point:(CGPoint)p;
- (NSString *)instanceVariadicMethodJoiningStrings:(NSString *)firstString stringList:(va_list)stringList;
- (NSString *)instanceVariadicMethodJoiningStrings:(NSString *)firstString, ... NS_REQUIRES_NIL_TERMINATION;

@end

@implementation RuntimeTestClass10

+ (NSString *)classString
{
    return @"Tom";
}

- (NSInteger)instanceInteger
{
    return 420;
}

- (float)instanceFloat
{
    return 420.f;
}

- (double)instanceDouble
{
    return 420.;
}

- (CGFloat)instanceCGFloat
{
    return 420.f;
}

- (void)instanceVoidReturningIntegerByReference:(NSInteger *)pValue
{
    if (pValue) {
        *pValue = 420;
    }
}

- (NSString *)instanceString
{
    return @"Tom";
}

- (CGPoint)instancePoint
{
    return CGPointMake(420.f, 420.f);
}

- (CLLocationCoordinate2D)instanceLocationCoordinate
{
    return CLLocationCoordinate2DMake(120., 120.);
}

- (SmallStruct)instanceSmallStruct
{
    SmallStruct smallStruct;
    memset(&smallStruct, 0, sizeof(SmallStruct));
    smallStruct.i = 420;
    return smallStruct;
}

- (LargeStruct)instanceLargeStruct
{
    LargeStruct largeStruct;
    memset(&largeStruct, 0, sizeof(LargeStruct));
    for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
        largeStruct.values[i] = 420.f;
    }
    return largeStruct;
}

- (SmallUnion)instanceSmallUnion
{
    SmallUnion smallUnion;
    smallUnion.i = 420;
    return smallUnion;
}

- (LargeUnion)instanceLargeUnion
{
    LargeUnion largeUnion;
    
    LargeStruct largeStruct;
    memset(&largeStruct, 0, sizeof(LargeStruct));
    for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
        largeStruct.values[i] = 420.f;
    }
    largeUnion.largeStruct = largeStruct;
    
    return largeUnion;
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
    // Swizzle to uppercase
    HLSSwizzleClassSelectorWithBlock_Begin(self, @selector(classString))
    ^(RuntimeTestClass10 *self) {
        return [((id (*)(id, SEL))_imp)(self, _cmd) uppercaseString];
    }
    HLSSwizzleClassSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceString))
    ^(RuntimeTestClass10 *self) {
        return [((id (*)(id, SEL))_imp)(self, _cmd) uppercaseString];
    }
    HLSSwizzleSelectorWithBlock_End;
    
    // Swizzle to get 42 as a result
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceInteger))
    ^(RuntimeTestClass10 *self) {
        return ((NSInteger (*)(id, SEL))_imp)(self, _cmd) / 10;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceFloat))
    ^(RuntimeTestClass10 *self) {
        return ((float (*)(id, SEL))_imp)(self, _cmd) / 10.f;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceDouble))
    ^(RuntimeTestClass10 *self) {
        return ((double (*)(id, SEL))_imp)(self, _cmd) / 10.;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceCGFloat))
    ^(RuntimeTestClass10 *self) {
        return ((CGFloat (*)(id, SEL))_imp)(self, _cmd) / 10.f;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    // Void
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceVoidReturningIntegerByReference:))
    ^(RuntimeTestClass10 *self, NSInteger *pValue) {
        ((void (*)(id, SEL, NSInteger *))_imp)(self, _cmd, pValue);
        
        if (pValue) {
            *pValue /= 10;
        }
    }
    HLSSwizzleSelectorWithBlock_End;
    
    // Swizzle to get (42, 42) as a result
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instancePoint))
    ^(RuntimeTestClass10 *self) {
        CGPoint point = ((CGPoint (*)(id, SEL))_imp)(self, _cmd);
        return CGPointMake(point.x / 10.f, point.y / 10.f);
    }
    HLSSwizzleSelectorWithBlock_End;
    
    // Swizzle to get 42 for all values
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceSmallStruct))
    ^(RuntimeTestClass10 *self) {
        SmallStruct smallStruct = ((SmallStruct (*)(id, SEL))_imp)(self, _cmd);
        smallStruct.i /= 10;
        return smallStruct;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceLargeStruct))
    ^(RuntimeTestClass10 *self) {
        LargeStruct largeStruct = ((LargeStruct (*)(id, SEL))_imp)(self, _cmd);
        for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
            largeStruct.values[i] /= 10.f;
        }
        return largeStruct;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceSmallUnion))
    ^(RuntimeTestClass10 *self) {
        SmallUnion smallUnion = ((SmallUnion (*)(id, SEL))_imp)(self, _cmd);
        smallUnion.i /= 10;
        return smallUnion;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceLargeUnion))
    ^(RuntimeTestClass10 *self) {
        LargeUnion largeUnion = ((LargeUnion (*)(id, SEL))_imp)(self, _cmd);
        
        LargeStruct largeStruct = largeUnion.largeStruct;
        for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
            largeStruct.values[i] /= 10.f;
        }
        largeUnion.largeStruct = largeStruct;
        
        return largeUnion;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    // Swizzle to get (12, 12) as a result
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceLocationCoordinate))
    ^(RuntimeTestClass10 *self) {
        CLLocationCoordinate2D locationCoordinate = ((CLLocationCoordinate2D (*)(id, SEL))_imp)(self, _cmd);
        return CLLocationCoordinate2DMake(locationCoordinate.longitude / 10., locationCoordinate.latitude / 10.);
    }
    HLSSwizzleSelectorWithBlock_End;
    
    // Replace ',' with '.' as separator
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceMethodJoiningInteger:float:string:point:))
    ^(RuntimeTestClass10 *self, NSInteger i, float f, NSString *s, CGPoint p) {
        NSString *joinedString = ((id (*)(id, SEL, NSInteger, float, id, CGPoint))_imp)(self, _cmd, i, f, s, p);
        return [joinedString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    }
    HLSSwizzleSelectorWithBlock_End;
    
    // Cannot swizzle functions with ellipsis (cannot forward the call to the original implementation). Must swizzle the method with va_list if available (of course, here available :) )
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(instanceVariadicMethodJoiningStrings:stringList:))
    ^(RuntimeTestClass10 *self, NSString *firstString, va_list stringList) {
        NSString *joinedString = ((id (*)(id, SEL, id, va_list))_imp)(self, _cmd, firstString, stringList);
        return [joinedString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    }
    HLSSwizzleSelectorWithBlock_End;
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
    HLSSwizzleClassSelectorWithBlock_Begin(self, @selector(testString))
    ^(RuntimeTestClass11 *self) {
        return [((id (*)(id, SEL))_imp)(self, _cmd) stringByAppendingString:@"B"];
    }
    HLSSwizzleClassSelectorWithBlock_End;
    
    HLSSwizzleClassSelectorWithBlock_Begin(self, @selector(testString))
    ^(RuntimeTestClass11 *self) {
        return [((id (*)(id, SEL))_imp)(self, _cmd) stringByAppendingString:@"C"];
    }
    HLSSwizzleClassSelectorWithBlock_End;

    HLSSwizzleClassSelectorWithBlock_Begin(self, @selector(testString))
    ^(RuntimeTestClass11 *self) {
        return [((id (*)(id, SEL))_imp)(self, _cmd) stringByAppendingString:@"D"];
    }
    HLSSwizzleClassSelectorWithBlock_End;

    HLSSwizzleClassSelectorWithBlock_Begin(self, @selector(testString))
    ^(RuntimeTestClass11 *self) {
        return [((id (*)(id, SEL))_imp)(self, _cmd) stringByAppendingString:@"E"];
    }
    HLSSwizzleClassSelectorWithBlock_End;
}

@end

@interface RuntimeTestClass12 : NSObject

+ (NSString *)topClassString;
- (NSString *)topInstanceString;

- (NSInteger)topInstanceInteger;
- (float)topInstanceFloat;
- (double)topInstanceDouble;
- (CGFloat)topInstanceCGFloat;

- (void)topInstanceVoidReturningIntegerByReference:(NSInteger *)pValue;

- (CGPoint)topInstancePoint;
- (CLLocationCoordinate2D)topInstanceLocationCoordinate;
- (SmallStruct)topInstanceSmallStruct;
- (LargeStruct)topInstanceLargeStruct;
- (SmallUnion)topInstanceSmallUnion;
- (LargeUnion)topInstanceLargeUnion;

- (NSString *)topInstanceMethodJoiningInteger:(NSInteger)i float:(float)f string:(NSString *)s point:(CGPoint)p;
- (NSString *)topInstanceVariadicMethodJoiningStrings:(NSString *)firstString stringList:(va_list)stringList;
- (NSString *)topInstanceVariadicMethodJoiningStrings:(NSString *)firstString, ... NS_REQUIRES_NIL_TERMINATION;

@end

@implementation RuntimeTestClass12

+ (NSString *)topClassString
{
    return @"1";
}

- (NSString *)topInstanceString
{
    return @"A";
}

- (NSInteger)topInstanceInteger
{
    return 420;
}

- (float)topInstanceFloat
{
    return 420.f;
}

- (double)topInstanceDouble
{
    return 420.;
}

- (CGFloat)topInstanceCGFloat
{
    return 420.f;
}

- (void)topInstanceVoidReturningIntegerByReference:(NSInteger *)pValue
{
    if (pValue) {
        *pValue = 420;
    }
}

- (CGPoint)topInstancePoint
{
    return CGPointMake(420.f, 420.f);
}

- (CLLocationCoordinate2D)topInstanceLocationCoordinate
{
    return CLLocationCoordinate2DMake(120., 120.);
}

- (SmallStruct)topInstanceSmallStruct
{
    SmallStruct smallStruct;
    memset(&smallStruct, 0, sizeof(SmallStruct));
    smallStruct.i = 420;
    return smallStruct;
}

- (LargeStruct)topInstanceLargeStruct
{
    LargeStruct largeStruct;
    memset(&largeStruct, 0, sizeof(LargeStruct));
    for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
        largeStruct.values[i] = 420.f;
    }
    return largeStruct;
}

- (SmallUnion)topInstanceSmallUnion
{
    SmallUnion smallUnion;
    smallUnion.i = 420;
    return smallUnion;
}

- (LargeUnion)topInstanceLargeUnion
{
    LargeUnion largeUnion;
    
    LargeStruct largeStruct;
    memset(&largeStruct, 0, sizeof(LargeStruct));
    for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
        largeStruct.values[i] = 420.f;
    }
    largeUnion.largeStruct = largeStruct;
    
    return largeUnion;
}

- (NSString *)topInstanceMethodJoiningInteger:(NSInteger)i float:(float)f string:(NSString *)s point:(CGPoint)p
{
    return [NSString stringWithFormat:@"%@,%@,%@,%@,%@", @(i), @(f), s, @(p.x), @(p.y)];
}

- (NSString *)topInstanceVariadicMethodJoiningStrings:(NSString *)firstString stringList:(va_list)stringList
{
    NSMutableArray *strings = [NSMutableArray arrayWithObject:firstString];
    
    NSString *string = va_arg(stringList, NSString *);
    while (string) {
        [strings addObject:string];
        string = va_arg(stringList, NSString *);
    }
    
    return [strings componentsJoinedByString:@","];
}

- (NSString *)topInstanceVariadicMethodJoiningStrings:(NSString *)firstString, ...
{
    va_list args;
    
    va_start(args, firstString);
    NSString *string = [self topInstanceVariadicMethodJoiningStrings:firstString stringList:args];
    va_end(args);
    
    return string;
}

@end

@interface RuntimeTestSubClass121 : RuntimeTestClass12

// Does not override any class / instance method from the superclass

@end

@implementation RuntimeTestSubClass121

@end

@interface RuntimeTestSubClass121 (Swizzling)

@end

@implementation RuntimeTestSubClass121 (Swizzling)

+ (void)load
{
    // Swizzling of non-overridden methods in class hierarchies (see HLSRuntime.m for an explanation)
    HLSSwizzleClassSelectorWithBlock_Begin(self, @selector(topClassString))
    ^(RuntimeTestSubClass121 *self) {
        return [((id (*)(id, SEL))_imp)(self, _cmd) stringByAppendingString:@"2"];
    }
    HLSSwizzleClassSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceString))
    ^(RuntimeTestSubClass121 *self) {
        return [((id (*)(id, SEL))_imp)(self, _cmd) stringByAppendingString:@"B"];
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceInteger))
    ^(RuntimeTestSubClass121 *self) {
        return ((NSInteger (*)(id, SEL))_imp)(self, _cmd) / 10;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceFloat))
    ^(RuntimeTestSubClass121 *self) {
        return ((float (*)(id, SEL))_imp)(self, _cmd) / 10.f;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceDouble))
    ^(RuntimeTestSubClass121 *self) {
        return ((double (*)(id, SEL))_imp)(self, _cmd) / 10.;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceCGFloat))
    ^(RuntimeTestSubClass121 *self) {
        return ((CGFloat (*)(id, SEL))_imp)(self, _cmd) / 10.f;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceVoidReturningIntegerByReference:))
    ^(RuntimeTestSubClass121 *self, NSInteger *pValue) {
        ((void (*)(id, SEL, NSInteger *))_imp)(self, _cmd, pValue);
        
        if (pValue) {
            *pValue /= 10;
        }
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstancePoint))
    ^(RuntimeTestSubClass121 *self) {
        CGPoint point = ((CGPoint (*)(id, SEL))_imp)(self, _cmd);
        return CGPointMake(point.x / 10.f, point.y / 10.f);
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceLocationCoordinate))
    ^(RuntimeTestSubClass121 *self) {
        CLLocationCoordinate2D locationCoordinate = ((CLLocationCoordinate2D (*)(id, SEL))_imp)(self, _cmd);
        return CLLocationCoordinate2DMake(locationCoordinate.longitude / 10., locationCoordinate.latitude / 10.);
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceSmallStruct))
    ^(RuntimeTestSubClass121 *self) {
        SmallStruct smallStruct = ((SmallStruct (*)(id, SEL))_imp)(self, _cmd);
        smallStruct.i /= 10;
        return smallStruct;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceLargeStruct))
    ^(RuntimeTestSubClass121 *self) {
        LargeStruct largeStruct = ((LargeStruct (*)(id, SEL))_imp)(self, _cmd);
        for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
            largeStruct.values[i] /= 10.f;
        }
        return largeStruct;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceSmallUnion))
    ^(RuntimeTestSubClass121 *self) {
        SmallUnion smallUnion = ((SmallUnion (*)(id, SEL))_imp)(self, _cmd);
        smallUnion.i /= 10;
        return smallUnion;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceLargeUnion))
    ^(RuntimeTestSubClass121 *self) {
        LargeUnion largeUnion = ((LargeUnion (*)(id, SEL))_imp)(self, _cmd);
        
        LargeStruct largeStruct = largeUnion.largeStruct;
        for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
            largeStruct.values[i] /= 10.f;
        }
        largeUnion.largeStruct = largeStruct;
        
        return largeUnion;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceMethodJoiningInteger:float:string:point:))
    ^(RuntimeTestSubClass121 *self, NSInteger i, float f, NSString *s, CGPoint p) {
        NSString *string = ((id (*)(id, SEL, NSInteger, float, id, CGPoint))_imp)(self, _cmd, i, f, s, p);
        return [NSString stringWithFormat:@"-%@-", string];
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceVariadicMethodJoiningStrings:stringList:))
    ^(RuntimeTestSubClass121 *self, NSString *firstString, va_list stringList) {
        NSString *string = ((id (*)(id, SEL, NSString *, va_list))_imp)(self, _cmd, firstString, stringList);
        return [NSString stringWithFormat:@"-%@-", string];
    }
    HLSSwizzleSelectorWithBlock_End;
}

@end

@interface RuntimeTestSubSubClass1211 : RuntimeTestSubClass121

// Does not override any class / instance method from the superclass

@end

@implementation RuntimeTestSubSubClass1211

@end

@interface RuntimeTestSubSubClass1211 (Swizzling)

@end

@implementation RuntimeTestSubSubClass1211 (Swizzling)

+ (void)load
{
    // Swizzling of non-overridden methods in class hierarchies (see HLSRuntime.m for an explanation)
    HLSSwizzleClassSelectorWithBlock_Begin(self, @selector(topClassString))
    ^(RuntimeTestSubSubClass1211 *self) {
        return [((id (*)(id, SEL))_imp)(self, _cmd) stringByAppendingString:@"3"];
    }
    HLSSwizzleClassSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceString))
    ^(RuntimeTestSubSubClass1211 *self) {
        return [((id (*)(id, SEL))_imp)(self, _cmd) stringByAppendingString:@"C"];
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceInteger))
    ^(RuntimeTestSubSubClass1211 *self) {
        return ((NSInteger (*)(id, SEL))_imp)(self, _cmd) / 2;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceFloat))
    ^(RuntimeTestSubSubClass1211 *self) {
        return ((float (*)(id, SEL))_imp)(self, _cmd) / 2.f;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceDouble))
    ^(RuntimeTestSubSubClass1211 *self) {
        return ((double (*)(id, SEL))_imp)(self, _cmd) / 2.;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceCGFloat))
    ^(RuntimeTestSubSubClass1211 *self) {
        return ((CGFloat (*)(id, SEL))_imp)(self, _cmd) / 2.f;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceVoidReturningIntegerByReference:))
    ^(RuntimeTestSubSubClass1211 *self, NSInteger *pValue) {
        ((void (*)(id, SEL, NSInteger *))_imp)(self, _cmd, pValue);
        
        if (pValue) {
            *pValue /= 2;
        }
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstancePoint))
    ^(RuntimeTestSubSubClass1211 *self) {
        CGPoint point = ((CGPoint (*)(id, SEL))_imp)(self, _cmd);
        return CGPointMake(point.x / 2.f, point.y / 2.f);
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceLocationCoordinate))
    ^(RuntimeTestSubSubClass1211 *self) {
        CLLocationCoordinate2D locationCoordinate = ((CLLocationCoordinate2D (*)(id, SEL))_imp)(self, _cmd);
        return CLLocationCoordinate2DMake(locationCoordinate.longitude / 2., locationCoordinate.latitude / 2.);
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceSmallStruct))
    ^(RuntimeTestSubSubClass1211 *self) {
        SmallStruct smallStruct = ((SmallStruct (*)(id, SEL))_imp)(self, _cmd);
        smallStruct.i /= 2;
        return smallStruct;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceLargeStruct))
    ^(RuntimeTestSubSubClass1211 *self) {
        LargeStruct largeStruct = ((LargeStruct (*)(id, SEL))_imp)(self, _cmd);
        for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
            largeStruct.values[i] /= 2.f;
        }
        return largeStruct;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceSmallUnion))
    ^(RuntimeTestSubSubClass1211 *self) {
        SmallUnion smallUnion = ((SmallUnion (*)(id, SEL))_imp)(self, _cmd);
        smallUnion.i /= 2;
        return smallUnion;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceLargeUnion))
    ^(RuntimeTestSubSubClass1211 *self) {
        LargeUnion largeUnion = ((LargeUnion (*)(id, SEL))_imp)(self, _cmd);
        
        LargeStruct largeStruct = largeUnion.largeStruct;
        for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
            largeStruct.values[i] /= 2.f;
        }
        largeUnion.largeStruct = largeStruct;
        
        return largeUnion;
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceMethodJoiningInteger:float:string:point:))
    ^(RuntimeTestSubSubClass1211 *self, NSInteger i, float f, NSString *s, CGPoint p) {
        NSString *string = ((id (*)(id, SEL, NSInteger, float, id, CGPoint))_imp)(self, _cmd, i, f, s, p);
        return [NSString stringWithFormat:@"-%@-", string];
    }
    HLSSwizzleSelectorWithBlock_End;
    
    HLSSwizzleSelectorWithBlock_Begin(self, @selector(topInstanceVariadicMethodJoiningStrings:stringList:))
    ^(RuntimeTestSubSubClass1211 *self, NSString *firstString, va_list stringList) {
        NSString *string = ((id (*)(id, SEL, NSString *, va_list))_imp)(self, _cmd, firstString, stringList);
        return [NSString stringWithFormat:@"-%@-", string];
    }
    HLSSwizzleSelectorWithBlock_End;
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

- (void)testSimpleSwizzling
{
    // Swizzling has been made in a +load. We here simply check that expected values after swizzling are correct
    XCTAssertEqualObjects([RuntimeTestClass10 classString], @"TOM");
    XCTAssertEqualObjects([[RuntimeTestClass10 new] instanceString], @"TOM");
    
    XCTAssertEqual([[RuntimeTestClass10 new] instanceInteger], (NSInteger)42);
    
    XCTAssertEqual([[RuntimeTestClass10 new] instanceFloat], 42.f);
    XCTAssertEqual([[RuntimeTestClass10 new] instanceDouble], 42.f);
    XCTAssertEqual([[RuntimeTestClass10 new] instanceCGFloat], 42.f);
    
    NSInteger value = 0;
    [[RuntimeTestClass10 new] instanceVoidReturningIntegerByReference:&value];
    XCTAssertEqual(value, 42);
    
    CGPoint point = [[RuntimeTestClass10 new] instancePoint];
    XCTAssertEqual(point.x, 42.f);
    XCTAssertEqual(point.y, 42.f);
    
    CLLocationCoordinate2D locationCoordinate = [[RuntimeTestClass10 new] instanceLocationCoordinate];
    XCTAssertEqual(locationCoordinate.longitude, 12.f);
    XCTAssertEqual(locationCoordinate.latitude, 12.f);
    
    SmallStruct smallStruct = [[RuntimeTestClass10 new] instanceSmallStruct];
    XCTAssertEqual(smallStruct.i, 42);
    
    LargeStruct largeStruct = [[RuntimeTestClass10 new] instanceLargeStruct];
    for (size_t i = 0; i < sizeof(largeStruct.values) / sizeof(largeStruct.values[0]); ++i) {
        XCTAssertEqual(largeStruct.values[i], 42.f);
    }
    
    SmallUnion smallUnion = [[RuntimeTestClass10 new] instanceSmallUnion];
    XCTAssertEqual(smallUnion.i, 42);
    
    LargeUnion largeUnion = [[RuntimeTestClass10 new] instanceLargeUnion];
    for (size_t i = 0; i < sizeof(largeUnion.largeStruct.values) / sizeof(largeUnion.largeStruct.values[0]); ++i) {
        XCTAssertEqual(largeUnion.largeStruct.values[i], 42);
    }
    
    XCTAssertEqualObjects([[RuntimeTestClass10 new] instanceMethodJoiningInteger:42 float:42.f string:@"42" point:CGPointMake(42.f, 42.f)], @"42.42.42.42.42");
    
    NSString *joinedString1 = [[RuntimeTestClass10 new] instanceVariadicMethodJoiningStrings:@"42", @"42", @"42", nil];
    XCTAssertEqualObjects(joinedString1, @"42.42.42");
    NSString *joinedString2 = [[RuntimeTestClass10 new] instanceVariadicMethodJoiningStrings:@"42", @"42", @"42", @"42", @"42", nil];
    XCTAssertEqualObjects(joinedString2, @"42.42.42.42.42");
}

- (void)testMultipleSwizzling
{
    // Multiple swizzling
    XCTAssertEqualObjects([RuntimeTestClass11 testString], @"ABCDE");
}

- (void)testSwizzlingInClassHierarchies
{
    // Swizzling of non-overridden methods in class hierarchies (see HLSRuntime.m for an explanation)
    XCTAssertEqualObjects([RuntimeTestSubClass121 topClassString], @"12");
    XCTAssertEqualObjects([RuntimeTestSubSubClass1211 topClassString], @"123");
    
    XCTAssertEqualObjects([[RuntimeTestSubClass121 new] topInstanceString], @"AB");
    XCTAssertEqualObjects([[RuntimeTestSubSubClass1211 new] topInstanceString], @"ABC");
    
    XCTAssertEqual([[RuntimeTestSubClass121 new] topInstanceInteger], 42);
    XCTAssertEqual([[RuntimeTestSubSubClass1211 new] topInstanceInteger], 21);
    
    XCTAssertEqual([[RuntimeTestSubClass121 new] topInstanceFloat], 42.f);
    XCTAssertEqual([[RuntimeTestSubSubClass1211 new] topInstanceFloat], 21.f);
    
    XCTAssertEqual([[RuntimeTestSubClass121 new] topInstanceDouble], 42.);
    XCTAssertEqual([[RuntimeTestSubSubClass1211 new] topInstanceDouble], 21.);
    
    XCTAssertEqual([[RuntimeTestSubClass121 new] topInstanceCGFloat], 42.f);
    XCTAssertEqual([[RuntimeTestSubSubClass1211 new] topInstanceCGFloat], 21.f);
    
    CGPoint point121 = [[RuntimeTestSubClass121 new] topInstancePoint];
    XCTAssertEqual(point121.x, 42.f);
    XCTAssertEqual(point121.y, 42.f);
    
    CGPoint point1211 = [[RuntimeTestSubSubClass1211 new] topInstancePoint];
    XCTAssertEqual(point1211.x, 21.f);
    XCTAssertEqual(point1211.y, 21.f);

    CLLocationCoordinate2D locationCoordinate121 = [[RuntimeTestSubClass121 new] topInstanceLocationCoordinate];
    XCTAssertEqual(locationCoordinate121.longitude, 12.f);
    XCTAssertEqual(locationCoordinate121.latitude, 12.f);
    
    CLLocationCoordinate2D locationCoordinate1211 = [[RuntimeTestSubSubClass1211 new] topInstanceLocationCoordinate];
    XCTAssertEqual(locationCoordinate1211.longitude, 6.f);
    XCTAssertEqual(locationCoordinate1211.latitude, 6.f);
    
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
