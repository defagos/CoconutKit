//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Conversions to string. Other conventional conversions are already available as NSStringFrom... functions
 */
OBJC_EXPORT NSString *HLSStringFromBool(BOOL yesOrNo);
OBJC_EXPORT NSString *HLSStringFromInterfaceOrientation(UIInterfaceOrientation interfaceOrientation);
OBJC_EXPORT NSString *HLSStringFromDeviceOrientation(UIDeviceOrientation deviceOrientation);
OBJC_EXPORT NSString *HLSStringFromCATransform3D(CATransform3D transform);

/**
 * Block signatures
 */
typedef id __nullable (^HLSTransformerBlock)(id __nullable object);
typedef BOOL (^HLSReverseTransformerBlock)(id __nullable * __nonnull pObject, id fromObject, NSError *__autoreleasing *pError);

/**
 * A protocol to define transformations between objects. Transformations in forward direction are mandatory and
 * can never fail (most probably they correspond to some kind of formatting), while transformations in reverse
 * direction are optional and might fail, in which case a corresponding error should be returned (most probably
 * they correspond to some kind of parsing)
 *
 * Transformers can be seen as a more general NSFormatter, though they are not limited to formatting / parsing.
 * For example, you can define an NSNumber to NSNumber transformer applying some kind of calculation to it. During
 * forward transformation, some information might get lost (e.g. through rounding), in which case implementing
 * a reverse transformation does not make sense. In other cases (e.g. multiplication with a constant factor), the
 * reverse transformation can be meaningfully implemented. The rule should be that applying the transform and 
 * reverse transform to some object should return an object equal to it
 *
 * Remark: Foundation provides NSValueTransformer, which provides a similar kind of functionality, but requires
 *         subclassing
 */
@protocol HLSTransformer <NSObject>

/**
 * Transform the provided object of class A into another one of class B (the classes might be the same)
 */
- (nullable id)transformObject:(nullable id)object;

/**
 * Reverse transform the provided object of class B into another one of class A. Check for existence before calling
 */
@optional
- (BOOL)getObject:(inout id __nullable * __nonnull)pObject fromObject:(nullable id)fromObject error:(out NSError *__autoreleasing *)pError;

@end

/**
 * A convenience transformer class which makes it easy to define transformations using blocks
 *
 * Designated initializer: -initWithBlock:reverseBlock:
 */
@interface HLSBlockTransformer : NSObject <HLSTransformer>

/**
 * Convenience constructor
 */
+ (instancetype)blockTransformerWithBlock:(HLSTransformerBlock)transformerBlock
                             reverseBlock:(nullable HLSReverseTransformerBlock)reverseBlock;

/**
 * Designated intializer. The forward transformer block is mandatory, the reverse one is optional. If no reverse
 * transformation block has been provided, the instance does not respond to -getObject:fromObject:error:
 */
- (instancetype)initWithBlock:(HLSTransformerBlock)transformerBlock
                 reverseBlock:(nullable HLSReverseTransformerBlock)reverseBlock NS_DESIGNATED_INITIALIZER;

@end

@interface HLSBlockTransformer (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

@interface HLSBlockTransformer (Adapters)

/**
 * Create a block transformer from a standard NSFormatter
 */
+ (instancetype)blockTransformerFromFormatter:(NSFormatter *)formatter;

/**
 * Create a block transformer from a standard NSValueFormatter
 */
+ (instancetype)blockTransformerFromValueTransformer:(NSValueTransformer *)valueTransformer;

@end

NS_ASSUME_NONNULL_END
