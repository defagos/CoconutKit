//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSTransformer.h"

#import "HLSCoreError.h"
#import "HLSLogger.h"
#import "NSError+HLSExtensions.h"

NSString *HLSStringFromBool(BOOL yesOrNo)
{
    return yesOrNo ? @"YES" : @"NO";
}

NSString *HLSStringFromInterfaceOrientation(UIInterfaceOrientation interfaceOrientation)
{
    static NSDictionary *s_names;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_names = @{ @(UIInterfaceOrientationPortrait) : @"UIInterfaceOrientationPortrait",
                     @(UIInterfaceOrientationPortraitUpsideDown) : @"UIInterfaceOrientationPortraitUpsideDown",
                     @(UIInterfaceOrientationLandscapeLeft) : @"UIInterfaceOrientationLandscapeLeft",
                     @(UIInterfaceOrientationLandscapeRight) : @"UIInterfaceOrientationLandscapeRight" };
    });
    return [s_names objectForKey:@(interfaceOrientation)];
}

NSString *HLSStringFromDeviceOrientation(UIDeviceOrientation deviceOrientation)
{
    static NSDictionary *s_names;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_names = @{ @(UIDeviceOrientationPortrait) : @"UIDeviceOrientationPortrait",
                     @(UIDeviceOrientationPortraitUpsideDown) : @"UIDeviceOrientationPortraitUpsideDown",
                     @(UIDeviceOrientationLandscapeLeft) : @"UIDeviceOrientationLandscapeLeft",
                     @(UIDeviceOrientationLandscapeRight) : @"UIDeviceOrientationLandscapeRight" };
    });
    return [s_names objectForKey:@(deviceOrientation)];
}

NSString *HLSStringFromCATransform3D(CATransform3D transform)
{
    return [NSString stringWithFormat:@"[\n"
            "    [%.6f, %.6f, %.6f, %.6f]\n"
            "    [%.6f, %.6f, %.6f, %.6f]\n"
            "    [%.6f, %.6f, %.6f, %.6f]\n"
            "    [%.6f, %.6f, %.6f, %.6f]\n"
            "]",
            transform.m11, transform.m12, transform.m13, transform.m14,
            transform.m21, transform.m22, transform.m23, transform.m24,
            transform.m31, transform.m32, transform.m33, transform.m34,
            transform.m41, transform.m42, transform.m43, transform.m44];
}

@interface HLSBlockTransformer ()

@property (nonatomic, copy) HLSTransformerBlock transformerBlock;
@property (nonatomic, copy) HLSReverseTransformerBlock reverseBlock;

@end

@implementation HLSBlockTransformer

#pragma mark Class methods

+ (instancetype)blockTransformerWithBlock:(HLSTransformerBlock)transformerBlock
                             reverseBlock:(HLSReverseTransformerBlock)reverseBlock
{
    return [[[self class] alloc] initWithBlock:transformerBlock reverseBlock:reverseBlock];
}

#pragma mark Object creation and destruction

- (instancetype)initWithBlock:(HLSTransformerBlock)transformerBlock
                 reverseBlock:(HLSReverseTransformerBlock)reverseBlock
{
    if (self = [super init]) {
        if (! transformerBlock) {
            HLSLoggerError(@"A transformer block is mandatory");
            return nil;
        }
        
        self.transformerBlock = transformerBlock;
        self.reverseBlock = reverseBlock;
    }
    return self;
}

#pragma mark HLSTransformer protocol implementation

- (id)transformObject:(id)object
{
    return self.transformerBlock(object);
}

- (BOOL)getObject:(id *)pObject fromObject:(id)fromObject error:(NSError *__autoreleasing *)pError
{
    if (! self.reverseBlock) {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    return self.reverseBlock(pObject, fromObject, pError);
}

#pragma mark Overrides

- (BOOL)respondsToSelector:(SEL)selector
{
    // Optional reverse transformation: Does not respond if no available block
    if (selector == @selector(getObject:fromObject:error:)) {
        return self.reverseBlock != nil;
    }
    // Normal behavior
    else {
        // See -[NSObject respondsToSelector:] documentation
        return [[self class] instancesRespondToSelector:selector];
    }
}

@end

@implementation HLSBlockTransformer (Adapters)

+ (instancetype)blockTransformerFromFormatter:(NSFormatter *)formatter
{
    return [self blockTransformerWithBlock:^(id object) {
        // Remark: The specific -[NSNumberFormatter stringFromNumber:] has a behavior which differs from -stringFromObjectValue:, e.g
        //         it ignores nilSymbol. Since -stringForObjectValue: has the richest behavior, it makes sense to call it in all cases
        return [formatter stringForObjectValue:object];
    } reverseBlock:^(__autoreleasing id *pObject, NSString *string, NSError *__autoreleasing *pError) {
        // For NSFormatter subclasses, calling -getObjectValue:forString:errorDescription: will crash for nil input strings, but
        // interestingly does not crash and returns nil when calling their specific -numberFromString: (for NSNumberFormatter) and
        // -dateFromString: (for NSDateFormatter) methods. Check and apply the same behavior as those specific methods here. Since
        // converting an empty string via NSNumberFormatter or NSDateFormatter returns YES -getObjectValue:forString:errorDescription:
        // (the object returned by reference is nil), we also consider the conversion successful here, which makes sense
        if ([string length] == 0) {
            if (pObject) {
                *pObject = nil;
            }
            return YES;
        }
        
        NSString *errorDescription = nil;
        BOOL result = [formatter getObjectValue:pObject forString:string errorDescription:&errorDescription];
        if (! result && pError) {
            *pError = [NSError errorWithDomain:HLSCoreErrorDomain
                                          code:HLSCoreErrorTransformation
                          localizedDescription:errorDescription];
            
        }
        return result;
    }];
}

+ (instancetype)blockTransformerFromValueTransformer:(NSValueTransformer *)valueTransformer
{
    HLSTransformerBlock block = ^(id object) {
        return [valueTransformer transformedValue:object];
    };
    
    if ( [[valueTransformer class] allowsReverseTransformation]) {
        return [HLSBlockTransformer blockTransformerWithBlock:block reverseBlock:^(__autoreleasing id *pObject, id fromObject, NSError *__autoreleasing *pError) {
            if (pObject) {
                *pObject = [valueTransformer reverseTransformedValue:fromObject];
            }
            return YES;
        }];
    }
    else {
        return [HLSBlockTransformer blockTransformerWithBlock:block reverseBlock:nil];
    }
}

@end
