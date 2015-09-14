//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSAssert.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Lightweight view controller subclass adding useful stuff to UIViewController, and which should be always used as 
 * base class when creating view controller subclasses in projects using CoconutKit (provided you do not have to 
 * subclass an existing view controller subclass which does not inherit from HLSViewController, of course).
 *
 * HLSViewController provides you with the following features:
 *   - localization is isolated in a single method. This is not only convenient to have a single place for localization code, 
 *     but this also makes HLSViewController compatible with the NSBundle+HLSDynamicLocalization.h class extension, making
 *     it possible to change a view controller localization at runtime (if this is not needed, HLSViewController of course
 *     remains compatible with the usual way of changing localization via system preferences, but it is stil good practice
 *     to collect localization code in a single method anyway)
 *   - instead of the default nib resolution mechanism of -[UIViewController init] (for @class MyViewController, first
 *     locate MyView.nib, then MyViewController.nib), HLSViewController subclasses look for either a storyboard or a nib 
 *     bearing the same name as the class or one of its superclasses (if no match is found the view controller is assumed 
 *     to be instantiated programmatically). This promotes a consistent naming scheme between source and interface design 
 *     files
 *   - the way how methods must be overridden is clean and consistent: The rule is now "Always call the super implementation
 *     first" (if failing to do so, the behavior is undefined). This includes all view lifecycle methods, rotation methods,
 *     as well as -localize and -didReceiveMemoryWarning
 *
 * The HLSViewController class is not meant to be instantiated directly, you should subclass it to define your own view
 * controllers.
 *
 * The current Apple recommended way to instantiate view controllers is using storyboards. Though they let you define your
 * view hierarchy on a single screen, storyboards have a few drawbacks:
 *   - they tend to scatter code around, most notably when you want to want to tweak how segues connect view controllers
 *   - even if you break your hierarchy into several storyboards, a single storyboard containing usually contains several 
 *     view controllers. Such a file can be a hot spot when working within a team of developers, and can lead to nightmares
 *     when merging changes
 *
 * This is why you might prefer view instantiation using nib files associated with each view controllers, an approach which
 * has its own drawbacks as well:
 *   - you cannot use prototype cells
 *   - you cannot layout your views using top and bottom layout guides
 *
 * CoconutKit instantiation mechanism solves these issues by letting you instantiate a view controller from an associated
 * storyboard. This still lets you have a separate interface design file for each view controller, while letting you use
 * prototype cells and layout guides.
 */
@interface HLSViewController : UIViewController

/**
 * Instantiate a view controller from a storyboard, looking for a storyboard file with the the specified name, containing 
 * a view controller with the name of the class or one of its superclasses as identifier (if none is found, the initial
 * view controller is used), and belonging to this class. Lookup is performed in the specified bundle or, if nil, in the 
 * main bundle.
 *
 * If no storyboard name is provided, a storyboard file with the name of the class or one of its superclasses is searched,
 * containing a view controller with this name as identifier (if none is found, the initial view controller is used), and 
 * belonging to the associated class.
 */
- (instancetype)initWithStoryboardName:(NSString *)storyboardName bundle:(NSBundle *)bundle NS_REQUIRES_SUPER;

/**
 * Instantiate a view controller, looking for a storyboard or a nib in the specified bundle. If no bundle is specified, lookup
 * is performed in the main bundle.
 *
 * Storyboard lookup is performed first with no storyboard name provided (read above how this is achieved). If no match is
 * found, a nib bearing the same name as the class or one of its superclasses is searched instead.
 */
- (instancetype)initWithBundle:(NSBundle *)bundle NS_REQUIRES_SUPER;

/**
 * In your subclass, use this method to collect your localization code. You must not call this method directly, it is automatically
 * called when needed. The method body itself should not contain any logic, only localization code (e.g. setting outlets using
 * NSLocalizedString macros, reloading table views containing localized strings, etc.)
 *
 * When overriding the method, be sure to call the super method first, otherwise the behavior is undefined
 *
 * To ensure that your application is properly localized - even when the localization changes at runtime using +[NSBundle setLocalization:]
 * (from NSBundle+HLSDynamicLocalization.h) - you must access localized resources only from within this method
 *
 * You do not need to bind outlets just for the purpose of label or bugtton localization in nib files. Refer to UILabel+HLSDynamicLocalization
 * for more information
 */
- (void)localize NS_REQUIRES_SUPER;

@end

@interface HLSViewController (HLSRequiresSuper)

- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle NS_REQUIRES_SUPER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_REQUIRES_SUPER;
- (void)viewDidLoad NS_REQUIRES_SUPER;
- (void)viewWillAppear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewDidAppear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewWillDisappear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewDidDisappear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewWillUnload NS_REQUIRES_SUPER;
- (void)viewDidUnload NS_REQUIRES_SUPER;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration NS_REQUIRES_SUPER;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation NS_REQUIRES_SUPER;
- (void)didReceiveMemoryWarning NS_REQUIRES_SUPER;
- (void)willMoveToParentViewController:(UIViewController *)parent NS_REQUIRES_SUPER;
- (void)didMoveToParentViewController:(UIViewController *)parent NS_REQUIRES_SUPER;
- (BOOL)shouldAutorotate NS_REQUIRES_SUPER;
- (NSUInteger)supportedInterfaceOrientations NS_REQUIRES_SUPER;

@end
