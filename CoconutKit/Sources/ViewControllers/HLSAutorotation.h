//
//  HLSAutorotation.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Define the several way for a container view controller to behave when interface rotation occurs. This means:
 *   - which view controllers decide whether rotation can occur or not
 *   - which view controllers receive rotation events (for children, this always occur from the topmost to the bottommost
 *     view controller, if they are involved)
 *
 * The default values are currently:
 *   - for iOS 4 and 5: HLSAutorotationModeContainerAndVisibleChildren
 *   - for iOS 6: HLSAutorotationModeContainer
 */
typedef enum {
    HLSAutorotationModeEnumBegin = 0,
    HLSAutorotationModeContainer = HLSAutorotationModeEnumBegin,            // Default: The container implementation decides which view controllers are involved
                                                                            // and which ones receive events (for UIKit containers this might vary between iOS
                                                                            // versions)
    HLSAutorotationModeContainerAndVisibleChildren,                         // The container and its visible children decide and receive events
    HLSAutorotationModeContainerAndChildren,                                // The container and all its children (even those not visible) decide and receive events
    HLSAutorotationModeEnumEnd,
    HLSAutorotationModeEnumSize = HLSAutorotationModeEnumEnd - HLSAutorotationModeEnumBegin
} HLSAutorotationMode;


#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000

// Enum available starting with the iOS 6 SDK, here made available for previous SDK versions as well
typedef enum {
    UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    UIInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    UIInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    UIInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
} UIInterfaceOrientationMask;

#endif

@protocol HLSAutorotationPreSDK6Compatibility <NSObject>

@optional

/**
 * On iOS 4 and 5 (as well of course on iOS 6), implement this method to set whether the view controller should
 * autorotate or not
 *
 * When building an application for iOS 4 or 5, this method is NOT implemented. If both -shouldAutorotate and
 * -supportedInterfaceOrientations are implemented for a view controller on iOS 4 or 5, the older
 * -shouldAutorotateToInterfaceOrientation: method is automatically derived and should not be implemented
 * (if it is implemented, it is ignored, except if compatibleWithNewAutorotationMethods is set to NO)
 */
- (BOOL)shouldAutorotate;

/**
 * On iOS 4 and 5 (as well of course on iOS 6), implement this method to set the orientations which a view
 * controller is compatible with
 *
 * When building an application for iOS 4 or 5, this method is NOT implemented. If both -shouldAutorotate and
 * -supportedInterfaceOrientations are implemented for a view controller on iOS 4 or 5, the older
 * -shouldAutorotateToInterfaceOrientation: method is automatically derived and should not be implemented
 * (if it is implemented, it is ignored, except if compatibleWithNewAutorotationMethods is set to NO)
 */
- (NSUInteger)supportedInterfaceOrientations;

@end

/**
 * Starting with iOS 6, new methods must be implemented to define the set of orientations supported by a view 
 * controller:
 *   -shouldAutorotate
 *   -supportedInterfaceOrientations
 *
 * To avoid having to redundantly implement the old -shouldAutorotateToInterfaceOrientation: if your application 
 * must target both iOS 4 / 5 and 6, CoconutKit lets you implement the new iOS 6 methods also on iOS 4 and 5,
 * even if they are officially not available for these versions.
 *
 * In general, if you use CoconutKit in your application, you should / must therefore never have to implement the
 * old -shouldAutorotateToInterfaceOrientation: method anymore. Implement the new iOS 6 rotation methods only, and 
 * your application will readily be compatible with iOS 4 to 6. You can still implement the old method if you want,
 * but this would be a waste of time and energy.
 *
 * There is only an exception to this rule: If you are using a view controller which you do not control the 
 * implementation of (e.g. a view controller made available by a static library), and whose implementation has
 * been made compatible with iOS 4, 5 and 6 (i.e. which implements all three rotation methods internally), 
 * you should disable the above mechanism by setting the value of the compatibleWithNewAutorotationMethods property
 * to NO for this view controller. Since this should be quite rare, the backwards iOS 6 optional compatibility 
 * mechanism is enabled by default.
 *
 * As a quick reference, when using CoconutKit, keep in mind that:
 *    -shouldAutorotateToInterfaceOrientation: is called on iOS 4 and 5 by UIKit, never by UIKit on iOS 6. It can
 *     still be called by client code on iOS 6, of course, though this does not really make sense. The CoconutKit
 *     implementation of -shouldAutorotateToInterfaceOrientation: in turns calls the -shouldAutorotate and 
 *     -supportedInterfaceOrientations if both are available
 *    -shouldAutorotate and -supportedInterfaceOrientations are never called by UIKit directly on iOS 4 and 5 (they
 *     are called by CoconutKit, and maybe by client code), and are only available if explicitly implemented by
 *     a view controller. Both are always called starting with iOS 6
 *
 * The following category just declares the iOS 6 rotation methods so that CoconutKit can be compiled against
 * the iOS 5 SDK without warnings.
 */
@interface UIViewController (HLSAutorotationPreSDK6Compatibility) <HLSAutorotationPreSDK6Compatibility>

/**
 * Enable the optional use of iOS 6 rotation methods on older versions of iOS (this method is ignored when running
 * an application built with iOS 6 SDK on iOS 6). Set it to NO if you are inheriting from a view controller which
 * you do not control the implementation of
 *
 * Default value is YES
 */
@property (nonatomic, assign, getter=isCompatibleWithNewAutorotationMethods) BOOL compatibleWithNewAutorotationMethods;

@end
