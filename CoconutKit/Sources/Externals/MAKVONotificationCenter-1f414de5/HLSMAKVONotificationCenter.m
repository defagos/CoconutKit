//
//  HLSMAKVONotificationCenter.m
//  HLSMAKVONotificationCenter
//
//  Created by Michael Ash on 10/15/08.
//

#import "HLSMAKVONotificationCenter.h"
#import <objc/message.h>
#import <objc/runtime.h>

/******************************************************************************/
#if !__has_feature(objc_arc)	// Foundation already predefines __has_feature()
#error "HLSMAKVONotificationCenter is designed to be built with ARC and will not work otherwise. Clients of it do not have to use ARC."
#endif

/******************************************************************************/
static const char			* const HLSMAKVONotificationCenter_HelpersKey = "HLSMAKVONotificationCenter_helpers";

static NSMutableSet			*HLSMAKVONotificationCenter_swizzledClasses = nil;

/******************************************************************************/
@interface HLSMAKVONotification ()
{
    NSDictionary			*change;
}

- (id)initWithObserver:(id)observer_ object:(id)target_ keyPath:(NSString *)keyPath_ change:(NSDictionary *)change_;

@property(copy,readwrite)	NSString			*keyPath;
@property(assign,readwrite)	id					observer, target;

@end

/******************************************************************************/
@implementation HLSMAKVONotification

@synthesize keyPath, observer, target;

- (id)initWithObserver:(id)observer_ object:(id)target_ keyPath:(NSString *)keyPath_ change:(NSDictionary *)change_
{
    if ((self = [super init]))
    {
        self.observer = observer_;
        self.target = target_;
        self.keyPath = keyPath_;
        change = change_;
    }
    return self;
}

- (NSKeyValueChange)kind { return [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue]; }
- (id)oldValue { return [change objectForKey:NSKeyValueChangeOldKey]; }
- (id)newValue { return [change objectForKey:NSKeyValueChangeNewKey]; }
- (NSIndexSet *)indexes { return [change objectForKey:NSKeyValueChangeIndexesKey]; }
- (BOOL)isPrior { return [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue]; }

@end

/******************************************************************************/
@interface _HLSMAKVONotificationHelper : NSObject <HLSMAKVOObservation>
{
  @public		// for HLSMAKVONotificationCenter
    id							__unsafe_unretained _observer;
    id							__unsafe_unretained _target;
    NSSet						*_keyPaths;
    NSKeyValueObservingOptions	_options;
    SEL							_selector;	// NULL for block-based
    id							_userInfo;	// block for block-based
}

- (id)initWithObserver:(id)observer object:(id)target keyPaths:(NSSet *)keyPaths
              selector:(SEL)selector userInfo:(id)userInfo options:(NSKeyValueObservingOptions)options;
- (void)deregister;

@end

/******************************************************************************/
@implementation _HLSMAKVONotificationHelper

static char HLSMAKVONotificationHelperMagicContext = 0;

- (id)initWithObserver:(id)observer object:(id)target keyPaths:(NSSet *)keyPaths
              selector:(SEL)selector userInfo:(id)userInfo options:(NSKeyValueObservingOptions)options
{
    if ((self = [super init]))
    {
        _observer = observer;
        _selector = selector;
        _userInfo = userInfo;
        _target = target;
        _keyPaths = keyPaths;
        _options = options;
        
        // Pass only Apple's options to Apple's code.
        options &= ~(HLSMAKeyValueObservingOptionUnregisterManually);
        
        for (NSString *keyPath in _keyPaths)
        {
            if ([target isKindOfClass:[NSArray class]])
            {
                [target addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [(NSArray *)target count])]
                         forKeyPath:keyPath options:options context:&HLSMAKVONotificationHelperMagicContext];
            }
            else
                [target addObserver:self forKeyPath:keyPath options:options context:&HLSMAKVONotificationHelperMagicContext];
        }
        
        NSMutableSet				*observerHelpers = nil, *targetHelpers = nil;
        if (_observer) {
            @synchronized (_observer)
            {
                if (!(observerHelpers = objc_getAssociatedObject(_observer, &HLSMAKVONotificationCenter_HelpersKey)))
                    objc_setAssociatedObject(_observer, &HLSMAKVONotificationCenter_HelpersKey, observerHelpers = [NSMutableSet set], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            @synchronized (observerHelpers) { [observerHelpers addObject:self]; }
        }
        
        @synchronized (_target)
        {
            if (!(targetHelpers = objc_getAssociatedObject(_target, &HLSMAKVONotificationCenter_HelpersKey)))
                objc_setAssociatedObject(_target, &HLSMAKVONotificationCenter_HelpersKey, targetHelpers = [NSMutableSet set], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        @synchronized (targetHelpers) { [targetHelpers addObject:self]; }
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &HLSMAKVONotificationHelperMagicContext)
    {
        
#if NS_BLOCKS_AVAILABLE
        if (_selector)
#endif
            ((void (*)(id, SEL, NSString *, id, NSDictionary *, id))objc_msgSend)(_observer, _selector, keyPath, object, change, _userInfo);
#if NS_BLOCKS_AVAILABLE
        else
        {
            HLSMAKVONotification		*notification = nil;

            // Pass object instead of _target as the notification object so that
            //	array observations will work as expected.
            notification = [[HLSMAKVONotification alloc] initWithObserver:_observer object:object keyPath:keyPath change:change];
            ((void (^)(HLSMAKVONotification *))_userInfo)(notification);
        }
#endif
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)deregister
{
    //NSLog(@"deregistering observer %@ target %@ observation %@", _observer, _target, self);
    if ([_target isKindOfClass:[NSArray class]])
    {
        NSIndexSet		*idxSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [(NSArray *)_target count])];
        
        for (NSString *keyPath in _keyPaths)
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_7
            [_target removeObserver:self fromObjectsAtIndexes:idxSet forKeyPath:keyPath context:&HLSMAKVONotificationHelperMagicContext];
#else
            [_target removeObserver:self fromObjectsAtIndexes:idxSet forKeyPath:keyPath];
#endif
    }
    else
    {
        for (NSString *keyPath in _keyPaths)
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_7
            [_target removeObserver:self forKeyPath:keyPath context:&HLSMAKVONotificationHelperMagicContext];
#else
            [_target removeObserver:self forKeyPath:keyPath];
#endif
    }

    if (_observer)
    {
        NSMutableSet			*observerHelpers = objc_getAssociatedObject(_observer, &HLSMAKVONotificationCenter_HelpersKey);
        @synchronized (observerHelpers) { [observerHelpers removeObject:self]; }
    }
    NSMutableSet			*targetHelpers = objc_getAssociatedObject(_target, &HLSMAKVONotificationCenter_HelpersKey);
    

    @synchronized (targetHelpers) { [targetHelpers removeObject:self]; } // if during dealloc, this will happen momentarily anyway
    
    // Protect against multiple invocations
    _observer = nil;
    _target = nil;
    _keyPaths = nil;
}

- (BOOL)isValid	// the observation is invalid if and only if it has been deregistered
{
    return _target != nil;
}

- (void)remove
{
    [self deregister];
}

@end

/******************************************************************************/
@interface HLSMAKVONotificationCenter ()

- (void)_swizzleObjectClassIfNeeded:(id)object;

@end

@implementation HLSMAKVONotificationCenter

+ (void)initialize
{
    static dispatch_once_t				onceToken = 0;
    
    dispatch_once(&onceToken, ^ { HLSMAKVONotificationCenter_swizzledClasses = [NSMutableSet set]; });
}

+ (id)defaultCenter
{
    static HLSMAKVONotificationCenter		*center = nil;
    static dispatch_once_t				onceToken = 0;
    
    // I really wanted to keep Mike's old way of doing this with
    //	OSAtomicCompareAndSwapPtrBarrier(); that was just cool! Unfortunately,
    //	pragmatism says always hand thread-safety off to the OS when possible as
    //	a matter of prudence, not that I can imagine the old way ever breaking.
    //	Also, this way is, while much less cool, a bit more readable.
    dispatch_once(&onceToken, ^ {
        center = [[HLSMAKVONotificationCenter alloc] init];
    });
    return center;
}

#if NS_BLOCKS_AVAILABLE

- (id<HLSMAKVOObservation>)addObserver:(id)observer
                             object:(id)target
                            keyPath:(id<HLSMAKVOKeyPathSet>)keyPath
                            options:(NSKeyValueObservingOptions)options
                              block:(void (^)(HLSMAKVONotification *notification))block
{
    return [self addObserver:observer object:target keyPath:keyPath selector:NULL userInfo:[block copy] options:options];
}

#endif

- (id<HLSMAKVOObservation>)addObserver:(id)observer
                             object:(id)target
                            keyPath:(id<HLSMAKVOKeyPathSet>)keyPath
                           selector:(SEL)selector
                           userInfo:(id)userInfo
                            options:(NSKeyValueObservingOptions)options;
{
    if (!(options & HLSMAKeyValueObservingOptionUnregisterManually))
    {
        [self _swizzleObjectClassIfNeeded:observer];
        [self _swizzleObjectClassIfNeeded:target];
    }
    
    NSMutableSet				*keyPaths = [NSMutableSet set];
    
    for (NSString *path in [keyPath hlsma_keyPathsAsSetOfStrings])
        [keyPaths addObject:path];
    
    _HLSMAKVONotificationHelper	*helper = [[_HLSMAKVONotificationHelper alloc] initWithObserver:observer object:target keyPaths:keyPaths
                                                                                    selector:selector userInfo:userInfo options:options];
    
    // RAIAIROFT: Resource Acquisition Is Allocation, Initialization, Registration, and Other Fun Tricks.
    return helper;
}

- (void)removeObserver:(id)observer object:(id)target keyPath:(id<HLSMAKVOKeyPathSet>)keyPath selector:(SEL)selector
{
    NSParameterAssert(observer || target);	// at least one of observer or target must be non-nil
    
    @autoreleasepool
    {
        NSMutableSet				*observerHelpers = objc_getAssociatedObject(observer, &HLSMAKVONotificationCenter_HelpersKey) ?: [NSMutableSet set],
                                    *targetHelpers = objc_getAssociatedObject(target, &HLSMAKVONotificationCenter_HelpersKey) ?: [NSMutableSet set],
                                    *allHelpers = [NSMutableSet set],
                                    *keyPaths = [NSMutableSet set];
    
        for (NSString *path in [keyPath hlsma_keyPathsAsSetOfStrings])
            [keyPaths addObject:path];
        @synchronized (observerHelpers) { [allHelpers unionSet:observerHelpers]; }
        @synchronized (targetHelpers) { [allHelpers unionSet:targetHelpers]; }
        
        for (_HLSMAKVONotificationHelper *helper in allHelpers)
        {
            if ((!observer || helper->_observer == observer) &&
                (!target || helper->_target == target) &&
                (!keyPath || [helper->_keyPaths isEqualToSet:keyPaths]) &&
                (!selector || helper->_selector == selector))
            {
                [helper deregister];
            }
        }
    }
}

- (void)removeObservation:(id<HLSMAKVOObservation>)observation
{
    [observation remove];
}

- (void)_swizzleObjectClassIfNeeded:(id)object
{
    if (!object)
        return;
    @synchronized (HLSMAKVONotificationCenter_swizzledClasses)
    {
        Class			class = [object class];//object_getClass(object);

        if ([HLSMAKVONotificationCenter_swizzledClasses containsObject:class])
            return;
//NSLog(@"Swizzling class %@", class);
        SEL				deallocSel = NSSelectorFromString(@"dealloc");/*@selector(dealloc)*/
        Method			dealloc = class_getInstanceMethod(class, deallocSel);
        IMP				origImpl = method_getImplementation(dealloc),
        #if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0 || __MAC_OS_X_VERSION_MAX_ALLOWED < __MAC_10_8
                        newImpl = imp_implementationWithBlock(^ (void *obj)
        #else
                        newImpl = imp_implementationWithBlock((__bridge void *)^ (void *obj)
        #endif
                                                              
        {
//NSLog(@"Auto-deregistering any helpers (%@) on object %@ of class %@", objc_getAssociatedObject((__bridge id)obj, &HLSMAKVONotificationCenter_HelpersKey), obj, class);
            @autoreleasepool
            {
                for (_HLSMAKVONotificationHelper *observation in [objc_getAssociatedObject((__bridge id)obj, &HLSMAKVONotificationCenter_HelpersKey) copy])
                {
                    // It's necessary to check the option here, as a particular
                    //	observation may want manual deregistration while others
                    //	on objects of the same class (or even the same object)
                    //	don't.
                    if (!(observation->_options & HLSMAKeyValueObservingOptionUnregisterManually))
                        [observation deregister];
                }
            }
            ((void (*)(void *, SEL))origImpl)(obj, deallocSel);
        });
        
        class_replaceMethod(class, deallocSel, newImpl, method_getTypeEncoding(dealloc));
        
        [HLSMAKVONotificationCenter_swizzledClasses addObject:class];
    }
}

@end

/******************************************************************************/
@implementation NSObject (HLSMAKVONotification)

- (id<HLSMAKVOObservation>)addObserver:(id)observer keyPath:(id<HLSMAKVOKeyPathSet>)keyPath selector:(SEL)selector userInfo:(id)userInfo
                            options:(NSKeyValueObservingOptions)options
{
    return [[HLSMAKVONotificationCenter defaultCenter] addObserver:observer object:self keyPath:keyPath selector:selector userInfo:userInfo options:options];
}

- (id<HLSMAKVOObservation>)observeTarget:(id)target keyPath:(id<HLSMAKVOKeyPathSet>)keyPath selector:(SEL)selector userInfo:(id)userInfo
                              options:(NSKeyValueObservingOptions)options
{
    return [[HLSMAKVONotificationCenter defaultCenter] addObserver:self object:target keyPath:keyPath selector:selector userInfo:userInfo options:options];
}

#if NS_BLOCKS_AVAILABLE

- (id<HLSMAKVOObservation>)addObservationKeyPath:(id<HLSMAKVOKeyPathSet>)keyPath
                                      options:(NSKeyValueObservingOptions)options
                                        block:(void (^)(HLSMAKVONotification *notification))block
{
    return [[HLSMAKVONotificationCenter defaultCenter] addObserver:nil object:self keyPath:keyPath options:options block:block];
}

- (id<HLSMAKVOObservation>)addObserver:(id)observer keyPath:(id<HLSMAKVOKeyPathSet>)keyPath options:(NSKeyValueObservingOptions)options
                              block:(void (^)(HLSMAKVONotification *notification))block
{
    return [[HLSMAKVONotificationCenter defaultCenter] addObserver:observer object:self keyPath:keyPath options:options block:block];
}

- (id<HLSMAKVOObservation>)observeTarget:(id)target keyPath:(id<HLSMAKVOKeyPathSet>)keyPath options:(NSKeyValueObservingOptions)options
                                block:(void (^)(HLSMAKVONotification *notification))block
{
    return [[HLSMAKVONotificationCenter defaultCenter] addObserver:self object:target keyPath:keyPath options:options block:block];
}

#endif

- (void)removeAllObservers
{
    [[HLSMAKVONotificationCenter defaultCenter] removeObserver:nil object:self keyPath:nil selector:NULL];
}

- (void)stopObservingAllTargets
{
    [[HLSMAKVONotificationCenter defaultCenter] removeObserver:self object:nil keyPath:nil selector:NULL];
}

- (void)removeObserver:(id)observer keyPath:(id<HLSMAKVOKeyPathSet>)keyPath
{
    [[HLSMAKVONotificationCenter defaultCenter] removeObserver:observer object:self keyPath:keyPath selector:NULL];
}

- (void)stopObserving:(id)target keyPath:(id<HLSMAKVOKeyPathSet>)keyPath
{
    [[HLSMAKVONotificationCenter defaultCenter] removeObserver:self object:target keyPath:keyPath selector:NULL];
}

- (void)removeObserver:(id)observer keyPath:(id<HLSMAKVOKeyPathSet>)keyPath selector:(SEL)selector
{
    [[HLSMAKVONotificationCenter defaultCenter] removeObserver:observer object:self keyPath:keyPath selector:selector];
}

- (void)stopObserving:(id)target keyPath:(id<HLSMAKVOKeyPathSet>)keyPath selector:(SEL)selector
{
    [[HLSMAKVONotificationCenter defaultCenter] removeObserver:self object:target keyPath:keyPath selector:selector];
}

@end

/******************************************************************************/
@implementation NSString (HLSMAKeyPath)

- (id<NSFastEnumeration>)hlsma_keyPathsAsSetOfStrings
{
    return [NSSet setWithObject:self];
}

@end

@implementation NSArray (HLSMAKeyPath)

- (id<NSFastEnumeration>)hlsma_keyPathsAsSetOfStrings
{
    return self;
}

@end

@implementation NSSet (HLSMAKeyPath)

- (id<NSFastEnumeration>)hlsma_keyPathsAsSetOfStrings
{
    return self;
}

@end

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_7
@implementation NSOrderedSet (HLSMAKeyPath)

- (id<NSFastEnumeration>)hlsma_keyPathsAsSetOfStrings
{
    return self;
}

@end
#endif
