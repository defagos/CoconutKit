//
//  HLSMAKVONotificationCenter.h
//  HLSMAKVONotificationCenter
//
//  Created by Michael Ash on 10/15/08.
//

#import <Foundation/Foundation.h>

/******************************************************************************/
enum
{
    // These constants are technically unsafe to use, as Apple could add options
    //	with identical values in the future. I'm hoping the highest possible
    //	bits are high enough for them not to bother with before a point in time
    //	where it won't matter anymore. Only 32 bits are used, as the definition
    //	of NSUInteger is 32 bits on iOS.
    
    // Pass this flag to disable automatic de-registration of observers at
    //	dealloc-time of observer or target. This avoids some swizzling hackery
    //	on the observer and target objects.
    // WARNING: Manual de-registration of observations has the same caveats as
    //	stardard KVO - deallocating the target or observer objects without
    //	removing the observation WILL throw KVO errors to the console and cause
    //	crashes!
    HLSMAKeyValueObservingOptionUnregisterManually		= 0x80000000,
};

/******************************************************************************/
// An object representing a (potentially) active observation.
@protocol HLSMAKVOObservation <NSObject>

@required
- (BOOL)isValid;	// returns NO if the observation has been deregistered by any means
- (void)remove;

@end

/******************************************************************************/
// An object adopting this protocol can be passed as a key path, and every key
//	path returned from the required method will be observed. Strings, arrays,
//	sets, and ordered sets automatically get this support, as does anything else
//	that can be used with for (... in ...)
@protocol HLSMAKVOKeyPathSet <NSObject>

@required
- (id<NSFastEnumeration>)hlsma_keyPathsAsSetOfStrings;

@end

/******************************************************************************/
@interface HLSMAKVONotification : NSObject

@property(copy,readonly)	NSString			*keyPath;
@property(assign,readonly)	id					observer, target;
@property(assign,readonly)	NSKeyValueChange	kind;
@property(strong,readonly)	id					oldValue;
@property(strong,readonly)	id __attribute__((ns_returns_not_retained)) newValue;
@property(strong,readonly)	NSIndexSet			*indexes;
@property(assign,readonly)	BOOL				isPrior;

@end

/******************************************************************************/
// As with Apple's KVO, observer and target are NOT retained.
// An observation object (as returned by an -addObserver: method) will be
//	rendered invalid when either the observer or target are deallocated. If you
//	hold on to a strong reference past that point, the object will still be
//	valid, but will no longer be useful for anything (however, passing it to
//	-removeObservation is harmless). It is strongly recommended that
//	references to observation objects be weak (or nonexistent), as this will
//	make automatic deregistration 100% leak-free. Holding on to an unretained
//	(non-weak) reference will cause an observation to go invalid without warning
//	unless automatic deregistration is disabled.
// -addObserver:keyPath:selector:userInfo:options: is exactly identical to
//	-observeTarget:keyPath:selector:userInfo:options: with the sender and target
//	switched; which you use is a matter of preference.
@interface NSObject (HLSMAKVONotification)

- (id<HLSMAKVOObservation>)addObserver:(id)observer
                            keyPath:(id<HLSMAKVOKeyPathSet>)keyPath
                           selector:(SEL)selector
                           userInfo:(id)userInfo
                            options:(NSKeyValueObservingOptions)options;

- (id<HLSMAKVOObservation>)observeTarget:(id)target
                              keyPath:(id<HLSMAKVOKeyPathSet>)keyPath
                             selector:(SEL)selector
                             userInfo:(id)userInfo
                              options:(NSKeyValueObservingOptions)options;

#if NS_BLOCKS_AVAILABLE

- (id<HLSMAKVOObservation>)addObservationKeyPath:(id<HLSMAKVOKeyPathSet>)keyPath
                                      options:(NSKeyValueObservingOptions)options
                                        block:(void (^)(HLSMAKVONotification *notification))block;

- (id<HLSMAKVOObservation>)addObserver:(id)observer
                            keyPath:(id<HLSMAKVOKeyPathSet>)keyPath
                            options:(NSKeyValueObservingOptions)options
                              block:(void (^)(HLSMAKVONotification *notification))block;

- (id<HLSMAKVOObservation>)observeTarget:(id)target
                              keyPath:(id<HLSMAKVOKeyPathSet>)keyPath
                              options:(NSKeyValueObservingOptions)options
                                block:(void (^)(HLSMAKVONotification *notification))block;

#endif

- (void)removeAllObservers;
- (void)stopObservingAllTargets;

- (void)removeObserver:(id)observer keyPath:(id<HLSMAKVOKeyPathSet>)keyPath;
- (void)stopObserving:(id)target keyPath:(id<HLSMAKVOKeyPathSet>)keyPath;

- (void)removeObserver:(id)observer keyPath:(id<HLSMAKVOKeyPathSet>)keyPath selector:(SEL)selector;
- (void)stopObserving:(id)target keyPath:(id<HLSMAKVOKeyPathSet>)keyPath selector:(SEL)selector;

@end

/******************************************************************************/
@interface HLSMAKVONotificationCenter : NSObject

+ (id)defaultCenter;

// selector should have the following signature:
//	- (void)observeValueForKeyPath:(NSString *)keyPath
//						  ofObject:(id)target
//							change:(NSDictionary *)change
//						  userInfo:(id)userInfo;

// If target is an NSArray, every object in the collection will be observed,
//	per -addObserver:toObjectsAtIndexes:.
- (id<HLSMAKVOObservation>)addObserver:(id)observer
                             object:(id)target
                            keyPath:(id<HLSMAKVOKeyPathSet>)keyPath
                           selector:(SEL)selector
                           userInfo:(id)userInfo
                            options:(NSKeyValueObservingOptions)options;

#if NS_BLOCKS_AVAILABLE

- (id<HLSMAKVOObservation>)addObserver:(id)observer
                             object:(id)target
                            keyPath:(id<HLSMAKVOKeyPathSet>)keyPath
                            options:(NSKeyValueObservingOptions)options
                              block:(void (^)(HLSMAKVONotification *notification))block;

#endif

// remove all observations registered by observer on target with keypath using
//	selector. nil for any parameter is a wildcard. One of observer or target
//	must be non-nil. The only way to deregister a specific block is to
//	remove its particular HLSMAKVOObservation.
- (void)removeObserver:(id)observer object:(id)target keyPath:(id<HLSMAKVOKeyPathSet>)keyPath selector:(SEL)selector;

// remove specific registered observation
- (void)removeObservation:(id<HLSMAKVOObservation>)observation;

@end

/******************************************************************************/
// Declarations to make the basic objects work as key paths; these are
//	technically private, but need to be publically visible or the compiler will
//	complain.
@interface NSString (HLSMAKeyPath) <HLSMAKVOKeyPathSet>
@end
@interface NSArray (HLSMAKeyPath) <HLSMAKVOKeyPathSet>
@end
@interface NSSet (HLSMAKeyPath) <HLSMAKVOKeyPathSet>
@end
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_7
@interface NSOrderedSet (HLSMAKeyPath) <HLSMAKVOKeyPathSet>
@end
#endif
