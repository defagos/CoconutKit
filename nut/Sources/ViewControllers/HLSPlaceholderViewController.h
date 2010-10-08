//
//  HLSPlaceholderViewController.h
//  nut
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSReloadable.h"

/**
 * View controllers which must be able to embed another view controller as subview can inherit from this class
 * to benefit from correct event propagation (e.g. viewDidLoad, rotation events, etc.). Moreover, this class
 * also supports view controller different depending on the orientation (see HLSOrientationCloner protocol).
 * The inherited class must create a placeholder view instance, either using a xib or by implementing the viewDidLoad
 * method.
 * 
 * The reason this class exists is that embedding view controllers by directly adding a view controller's
 * view as subview of another view controller's view does not work correctly out of the box. Most view controller
 * events will be fired up correctly (e.g viewDidLoad or rotation events), but other simply won't (e.g. viewWillAppear:).
 * This means that when adding a view controller's view directly as subview, the viewWillAppear: message has to be sent
 * manually, which is disturbing and awkward (the same has to be done when removing the view).
 *
 * The wrapped view controller can be swapped with another one at any time. Simply update the viewController property. 
 * This makes pages or tabs easy to code.
 *
 * When you derive from HLSPlaceholderViewController, it is especially important not to forget to call the super
 * view lifecycle methods first, otherwise the behaviour will be undefined. Similarly for methods related to interface
 * orientation:
 *   - viewWill...
 *   - viewDid...
 *   - shouldAutorotateToInterfaceOrientation: : If the call to the super method returns NO, return NO immediately (this
 *                                               means that the inset cannot rotate).
 *   - willRotateToInterfaceOrientation:duration:
 *   - willAnimate...
 *   - didRotateFromInterfaceOrientation:
 *
 * Designated initializer: initWithNibName:bundle:
 */
@interface HLSPlaceholderViewController : UIViewController <HLSReloadable> {
@private
    UIViewController *m_insetViewController;
    UIView *m_placeholderView;
}

@property (nonatomic, retain) UIViewController *insetViewController;
@property (nonatomic, retain) IBOutlet UIView *placeholderView;

@end
