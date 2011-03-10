//
//  UIResponder+HLSInjection.m
//  nut
//
//  Created by Samuel Défago on 3/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import <objc/runtime.h> 
#import <objc/message.h>

#import "HLSLogger.h"

// No threading issues here, UIKit is not to be used by multiple threads
static UIControl *s_currentControl;
static NSMutableSet *s_inhibitedControls;

// Original implementation of the methods we swizzle
static IMP s_initWithFrame$Imp;
static IMP s_initWithCoder$Imp;
static IMP s_addTarget$action$forControlEvents$Imp;
static IMP s_removeTarget$action$forControlEvents$Imp;
static IMP s_actionsForTarget$forControlEvent$Imp;

// Sentinel selectors
static SEL s_sentinelTouchDownActionSel;
static SEL s_sentinelTouchUpActionSel;

// Static methods
static void swizzleSelector(Class class, SEL origSel, SEL newSel);

static void sentinelTouchDownActionImp(id self, SEL sel, id sender);
static void sentinelTouchUpActionImp(id self, SEL sel, id sender);

static void wrapperTouchDownActionImp(id self, SEL sel, id sender);
static void wrapperTouchUpActionImp(id self, SEL sel, id sender);

/** 
 * In UIKit, nothing prevents quasi-simulatenous taps on several buttons. Such taps can lead to very annoying issues.
 * For example, if two buttons opening two different view controllers modally are clicked quasi simultaenously, and 
 * if both of them respond to a touch up event to show their respective view controller, then you might end up stacking 
 * two view controllers modally. In such cases, your intention was of course to always present one modal view controller 
 * at a time.
 *
 * In general, you can fix such issues by littering your code with boolean variables and testing them in each button
 * action method. This is ugly, error-prone and painful.
 *
 * To avoid such issues, the category below globally injects some code to disable quasi-simulatenous taps. If such events 
 * occur, only the first tap will be executed, not the other ones. Double taps on the same button are of course not affected,
 * since they are simultaneous, not quasi. This code has been injected directly into UIControl. IMHO, you never want quasi
 * simultaneous taps to occur. Either you handle gestures involving several fingers for real simultaneous taps, or you
 * respond to single actions. The time interval between taps for quasi-simultaneity is undetermined, therefore
 * quasi-simultaneous taps are of no use.
 *
 * The code works as follows: We replace the usual UIControl event / target methods by wrappers using swizzling (the
 * implementations we replace are still called internally, the original behavior is therefore preserved). To track touch
 * events (up and down events), we then register two "sentinel" actions for touch up and down events:
 *   - touch down event (must stay the first action in the list of touch down actions): to begin tracking a control if 
 *     none was currently active. If a control is already active, any control receiving a touch down event is marked as 
 *     inhibited, and will remain so until this flag is removed (see below)
 *   - touch up event (must stay the last action in the list of touch up actions): to end tracking of the current active 
 *     control
 * To be able to track touch up / down events registered by the user, the addTarget:action:forControlEvents: method is
 * then swizzled to register a wrapper for the action instead of the action itself. This wrapper simply executes the 
 * original action if the control is active, but immediately returns if the control is inhibited. The other target / action
 * methods must be swizzled as well to make the injection trick invisible to the caller.
 *
 * The order of touch up / down events for quasi simultaneous taps is often as follows:
 *   - touch down on first control; becomes currently active control
 *   - touch down on second control; first control already active, the second control is therefore flagged as inhibited
 *   - touch up on first control: not active anymore
 *   - touch up on second control
 * Since the touch up event on the first control occurs before the touch up even on the second control, the first
 * control touch up wrapper cannot decide to flag the second control as not inhibited anymore (otherwise the corresponding
 * touch up event would be triggered, which is what we want to prevent). The responsibility of removing the inhibited
 * flag is therefore given to the inhibited control itself: When it is done processing the events we track (i.e. when
 * touch up is called for it), it simply unflags itself. There is a small issue, though: If the the inhibited control 
 * somehow vanishes (e.g. if a view a button sits on disappears), this last event might not be triggered, and the control 
 * might stay flagged as inhibited. For this reason:
 *   - the touch down sentinel clears the inhibited control list when a new control becomes active
 *   - the list of inhibited controls is not a set (which retains its elements), but a list of NSValue objects
 *     containing the inhibited control pointers. This avoids keeping controls alive unnecessarily
 */
@interface UIControl (HLSInjection)

+ (void)load;

- (id)swizzledInitWithFrame:(CGRect)frame;
- (id)swizzledInitWithCoder:(NSCoder *)aDecoder;
- (void)swizzledAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)swizzledRemoveTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (NSArray *)swizzledActionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent;

- (void)addSentinelActions;

@end

@implementation UIControl (HLSInjection)

#pragma mark Class methods

+ (void)load
{
    // Get the original implementations we want to swizzle
    s_initWithFrame$Imp = method_getImplementation(class_getInstanceMethod([self class], 
                                                                           @selector(initWithFrame:)));
    s_initWithCoder$Imp = method_getImplementation(class_getInstanceMethod([self class], 
                                                                           @selector(initWithCoder:)));
    s_addTarget$action$forControlEvents$Imp = method_getImplementation(class_getInstanceMethod([self class], 
                                                                                               @selector(addTarget:action:forControlEvents:)));
    s_removeTarget$action$forControlEvents$Imp = method_getImplementation(class_getInstanceMethod([self class], 
                                                                                                  @selector(removeTarget:action:forControlEvents:)));
    s_actionsForTarget$forControlEvent$Imp = method_getImplementation(class_getInstanceMethod([self class], 
                                                                                              @selector(actionsForTarget:forControlEvent:)));    
    // Swizzle with custom wrappers
    swizzleSelector([self class], @selector(initWithFrame:), @selector(swizzledInitWithFrame:));
    swizzleSelector([self class], @selector(initWithCoder:), @selector(swizzledInitWithCoder:));
    swizzleSelector([self class], @selector(addTarget:action:forControlEvents:), @selector(swizzledAddTarget:action:forControlEvents:));
    swizzleSelector([self class], @selector(removeTarget:action:forControlEvents:), @selector(swizzledRemoveTarget:action:forControlEvents:));
    swizzleSelector([self class], @selector(actionsForTarget:forControlEvent:), @selector(swizzledActionsForTarget:forControlEvent:));
    
    // Create and inject sentinel methods
    s_sentinelTouchDownActionSel = sel_registerName("sentinelTouchDownAction");
    class_addMethod([self class],
                    s_sentinelTouchDownActionSel,
                    (IMP)sentinelTouchDownActionImp,
                    "v@:@");
    s_sentinelTouchUpActionSel = sel_registerName("sentinelTouchUpAction");
    class_addMethod([self class],
                    s_sentinelTouchUpActionSel,
                    (IMP)sentinelTouchUpActionImp,
                    "v@:@");    
    
    // Set for tracking inhibited controls
    s_inhibitedControls = [[NSMutableSet alloc] init];
}

#pragma mark Methods injected by swizzling

- (id)swizzledInitWithFrame:(CGRect)frame
{
    HLSLoggerDebug(@"Called swizzled initWithFrame:");
    
    // Call the original implementation
    if ((self = (*s_initWithFrame$Imp)(self, @selector(initWithFrame:), frame))) {
        [self addSentinelActions];
    }
    return self;
}

- (id)swizzledInitWithCoder:(NSCoder *)aDecoder
{
    HLSLoggerDebug(@"Called swizzled initWithCoder:");
    
    // Call the original implementation
    if ((self = (*s_initWithCoder$Imp)(self, @selector(initWithCoder:), aDecoder))) {
        [self addSentinelActions];
    }
    return self;
}

- (void)swizzledAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    HLSLoggerDebug(@"Called swizzled addTarget:action:forControlEvents:");
    
    // Register action wrappers for touch down actions (if any)
    UIControlEvents touchDownFlags = UIControlEventTouchDown | UIControlEventTouchDownRepeat;
    if (controlEvents & touchDownFlags) {
        // Wrapper name is simply original name with prefix
        NSString *wrapperTouchDownActionName = [@"wrapper_down_" stringByAppendingString:[NSString stringWithUTF8String:sel_getName(action)]];
        
        // Create the method dynamically and add it to the target class
        SEL wrapperTouchDownActionSel = sel_registerName([wrapperTouchDownActionName UTF8String]);
        class_addMethod([target class],
                        wrapperTouchDownActionSel,
                        (IMP)wrapperTouchDownActionImp,
                        "v@:@");            // Same prototype as action, i.e. - (void)methodName:(id)sender
        
        // Register the new target / action
        (*s_addTarget$action$forControlEvents$Imp)(self, 
                                                   @selector(addTarget:action:forControlEvents:), 
                                                   target, 
                                                   wrapperTouchDownActionSel, 
                                                   controlEvents & touchDownFlags); 
        
        // Already dealt with these events specifically; remove them from the mask
        controlEvents &= ~touchDownFlags;
    }
    
    // Register action wrappers for touch up actions (if any)
    UIControlEvents touchUpFlags = UIControlEventTouchUpInside | UIControlEventTouchUpOutside;
    if (controlEvents & touchUpFlags) {
        // Wrapper name is simply original name with prefix
        NSString *wrapperTouchUpActionName = [@"wrapper_up_" stringByAppendingString:[NSString stringWithUTF8String:sel_getName(action)]];
        
        // Create the method dynamically and add it to the UIControl class
        SEL wrapperTouchUpActionSel = sel_registerName([wrapperTouchUpActionName UTF8String]);
        class_addMethod([target class],
                        wrapperTouchUpActionSel,
                        (IMP)wrapperTouchUpActionImp,
                        "v@:@");            // Same prototype as action, i.e. - (void)methodName:(id)sender 
        
        // We want the touch up sentinel method to be always the last one to be called; remove the one already installed
        (*s_removeTarget$action$forControlEvents$Imp)(self,
                                                      @selector(removeTarget:action:forControlEvents:),
                                                      target,
                                                      s_sentinelTouchUpActionSel,
                                                      controlEvents & touchUpFlags);
        
        // Register the new target / action
        (*s_addTarget$action$forControlEvents$Imp)(self, 
                                                   @selector(addTarget:action:forControlEvents:), 
                                                   target, 
                                                   wrapperTouchUpActionSel, 
                                                   controlEvents & touchUpFlags); 
        
        // Re-install the sentinel method as last action
        (*s_addTarget$action$forControlEvents$Imp)(self, 
                                                   @selector(addTarget:action:forControlEvents:), 
                                                   self, 
                                                   s_sentinelTouchUpActionSel, 
                                                   controlEvents & touchUpFlags);       
        
        // Already dealt with these events specifically; remove them from the mask
        controlEvents &= ~touchUpFlags;
    }
    
    // For all other events (if any remain) simply register the action we receive
    if (controlEvents != 0) {
        (*s_addTarget$action$forControlEvents$Imp)(self, 
                                                   @selector(addTarget:action:forControlEvents:), 
                                                   target, 
                                                   action, 
                                                   controlEvents);         
    }
}

- (void)swizzledRemoveTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    HLSLoggerDebug(@"Called swizzled removeTarget:action:forControlEvents:");
    
    // Touch down event: Remove the wrapper
    UIControlEvents touchDownFlags = UIControlEventTouchDown | UIControlEventTouchDownRepeat;
    if (controlEvents & touchDownFlags) {
        // Wrapper name is simply original name with prefix
        NSString *wrapperTouchDownActionName = [@"wrapper_down_" stringByAppendingString:[NSString stringWithUTF8String:sel_getName(action)]];
        SEL wrapperTouchDownActionSel = sel_registerName([wrapperTouchDownActionName UTF8String]);
        
        (*s_removeTarget$action$forControlEvents$Imp)(self, 
                                                      @selector(removeTarget:action:forControlEvents:), 
                                                      target, 
                                                      wrapperTouchDownActionSel, 
                                                      controlEvents & touchDownFlags);        
        
        // Already dealt with these events specifically; remove them from the mask
        controlEvents &= ~touchDownFlags;
    }
    
    // Touch up event: Remove the wrapper
    UIControlEvents touchUpFlags = UIControlEventTouchUpInside | UIControlEventTouchUpOutside;
    if (controlEvents & touchUpFlags) {
        // Wrapper name is simply original name with prefix
        NSString *wrapperTouchUpActionName = [@"wrapper_up_" stringByAppendingString:[NSString stringWithUTF8String:sel_getName(action)]];
        SEL wrapperTouchUpActionSel = sel_registerName([wrapperTouchUpActionName UTF8String]);
        
        (*s_removeTarget$action$forControlEvents$Imp)(self, 
                                                      @selector(removeTarget:action:forControlEvents:), 
                                                      target, 
                                                      wrapperTouchUpActionSel, 
                                                      controlEvents & touchUpFlags);       
        
        // Already dealt with these events specifically; remove them from the mask
        controlEvents &= ~touchUpFlags;
    }
    
    // Remove directly if registrations for other events remain
    if (controlEvents != 0) {
        (*s_removeTarget$action$forControlEvents$Imp)(self, 
                                                      @selector(removeTarget:action:forControlEvents:), 
                                                      target, 
                                                      action, 
                                                      controlEvents);        
    }
}

- (NSArray *)swizzledActionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent
{   
    HLSLoggerDebug(@"Called swizzled actionsForTarget:forControlEvent:");
    
    // Call the original implementation
    NSArray *internalActionNames = (*s_actionsForTarget$forControlEvent$Imp)(self,
                                                                             @selector(actionsForTarget:forControlEvent:),
                                                                             target,
                                                                             controlEvent);
    
    // Returned wrapped methods, not wrappers. This way, our wrapper injection remains completely invisible
    NSMutableArray *actionNames = [NSMutableArray array];
    for (NSString *actionName in internalActionNames) {
        // Cleanup wrapper prefixes (if any)
        NSString *originalActionName = [actionName stringByReplacingOccurrencesOfString:@"wrapper_down_" withString:@""];
        originalActionName = [originalActionName stringByReplacingOccurrencesOfString:@"wrapper_up_" withString:@""];
        [actionNames addObject:originalActionName];
    }
    
    return [NSArray arrayWithArray:actionNames];
}

#pragma mark Miscellaneous methods

- (void)addSentinelActions
{   
    (*s_addTarget$action$forControlEvents$Imp)(self, 
                                               @selector(addTarget:action:forControlEvents:), 
                                               self, 
                                               s_sentinelTouchDownActionSel, 
                                               UIControlEventTouchDown | UIControlEventTouchDownRepeat);  
    
    (*s_addTarget$action$forControlEvents$Imp)(self, 
                                               @selector(addTarget:action:forControlEvents:), 
                                               self, 
                                               s_sentinelTouchUpActionSel, 
                                               UIControlEventTouchUpInside | UIControlEventTouchUpOutside); 
}

@end

#pragma mark Swizzler

static void swizzleSelector(Class class, SEL origSel, SEL newSel)
{
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method newMethod = class_getInstanceMethod(class, newSel);
    if (class_addMethod(class, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, origSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

#pragma mark Sentinel action implementations

static void sentinelTouchDownActionImp(id self, SEL sel, id sender)
{
    HLSLoggerDebug(@"Sentinel touch down action called");
    
    // Other control pressed while one is active. Inhibit
    if (s_currentControl && s_currentControl != self) {
        // Store a weak ref to the object using an NSValue
        [s_inhibitedControls addObject:[NSValue valueWithPointer:self]];
        return;
    }
    
    // Cleanup inhibited list; some controls might not have had the time to unflag them in some situations
    [s_inhibitedControls removeAllObjects];
    
    s_currentControl = self;
}

static void sentinelTouchUpActionImp(id self, SEL sel, id sender)
{
    HLSLoggerDebug(@"Sentinel touch up action called");
    
    // Last event; if current control, done protecting it
    if (s_currentControl == self) {
        s_currentControl = nil;
    }
    // Other control: stop inhibiting it, the control reached the end of the event cycle we protect
    else {
        [s_inhibitedControls removeObject:[NSValue valueWithPointer:self]];
    }
}

#pragma mark Wrapper action implementations

static void wrapperTouchDownActionImp(id self, SEL sel, id sender)
{
    HLSLoggerDebug(@"Wrapper down action %s called", sel_getName(sel));
    
    if ([s_inhibitedControls containsObject:[NSValue valueWithPointer:self]]) {
        return;
    }
    
    // Remove the prefix
    NSString *selectorName = [[NSString stringWithUTF8String:sel_getName(sel)] stringByReplacingOccurrencesOfString:@"wrapper_down_"
                                                                                                         withString:@""];
    
    // Call the original selector
    SEL originalSel = sel_registerName([selectorName UTF8String]);
    IMP originalImp = method_getImplementation(class_getInstanceMethod([self class], originalSel));
    (*originalImp)(self, originalSel, sender);
}

static void wrapperTouchUpActionImp(id self, SEL sel, id sender)
{
    HLSLoggerDebug(@"Wrapper up action %s called", sel_getName(sel));
    
    if ([s_inhibitedControls containsObject:[NSValue valueWithPointer:sender]]) {
        return;
    }
    
    // Remove the prefix
    NSString *selectorName = [[NSString stringWithUTF8String:sel_getName(sel)] stringByReplacingOccurrencesOfString:@"wrapper_up_"
                                                                                                         withString:@""];
    
    // Call the original selector
    SEL originalSel = sel_registerName([selectorName UTF8String]);
    IMP originalImp = method_getImplementation(class_getInstanceMethod([self class], originalSel));
    (*originalImp)(self, originalSel, sender);
}
