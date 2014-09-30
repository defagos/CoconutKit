//
//  HLSViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSAssert.h"

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
 *     locate MyView.nib, then MyViewController.nib), HLSViewController subclasses look for a nib bearing the same name
 *     as the class or one of its superclasses only (otherwise the view controller is assumed to be instantiated 
 *     programmatically). This promotes a consistent naming scheme between source and nib files
 *   - the way how methods must be overridden is clean and consistent: The rule is now "Always call the super implementation 
 *     first" (if failing to do so, the behavior is undefined). This includes all view lifecycle methods, rotation methods,
 *     as well as -localize and -didReceiveMemoryWarning
 *
 * The HLSViewController class is not meant to be instantiated directly, you should subclass it to define your own view 
 * controllers.
 *
 * Otherwise, HLSViewController is used exactly like UIViewController. There is only one major difference with 
 * UIViewController: HLSViewController supports all interface orientations by default. This choice was made so that 
 * the "Always call the super implementation first" rule can be applied. This also makes sense from a user's perspective 
 * since view controllers tend to support more and more orientations (especially since the iPad was launched, or more 
 * with the autorotation behavior introduced in iOS 6).
 *
 * This class also provides a way to debug view controller events (lifecycle, rotation, memory warnings). You must
 * set the logger level of your application to DEBUG (see HLSLogger.h to know how this is achieved). Then use the 
 * console when running your application to have a look at view controller events. This most notably can help you 
 * discover incorrect view controller hierarchies or poorly implemented view controller containers.
 */
@interface HLSViewController : UIViewController

/**
 * Instantiate a view controller, looking for a nib bearing the same name as the class or one of its superclasses in the 
 * given bundle. If the specified bundle is nil, lookup is performed in the main bundle
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
 * You do not need to bind outlets just for the purpose of label or button localization in nib files. Refer to UILabel+HLSDynamicLocalization
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
