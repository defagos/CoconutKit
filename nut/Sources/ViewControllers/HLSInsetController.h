//
//  HLSInsetController.h
//  nut
//
//  Created by Samuel Défago on 9/28/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSReloadable.h"
#import "HLSViewPlaceholder.h"

/**
 * Container view controller for displaying a view controller inset within another view controller exhibiting some
 * placeholder view as insertion point.
 * 
 * The reason this class exists is that embedding view controllers by directly adding a view controller's
 * view as subview of another view controller's view does not work correctly out of the box. Most view controller
 * events will be fired up correctly (e.g viewDidLoad or rotation events), but other simply won't (e.g. viewWillAppear:).
 * This means that when adding a view controller's view directly as subview, the viewWillAppear: message has to be sent
 * manually, which is disturbing and awkward (the same has to be done when removing the view). By having a container
 * which manages the composition of two view controllers, we can guarantee that events are always properly
 * forwarded between view controllers.
 *
 * The view controller's view to which the other one will be added must have a placeholder view. This is guaranteed
 * by the mandatory HLSViewPlaceholder protocol implementation.
 *
 * The view controller can be swapped with another one at any time. Simply update the viewController property. This makes 
 * embedded pages / tabs easy to code. Moreover, the inset view controller mirrors the properties of the placeholder
 * view controller when wrapped into a navigation controller (navigation bar, title, toolbar). In other words,
 * customize those elements in the placeholder view controller itself, not by subclassing HLSInsetController: As for
 * the container controllers UITabBarController and UINavigationController, HLSInsetController is namely not meant
 * to be subclassed.
 *
 * Designated initializer: initWithPlaceholderViewController:
 */
@interface HLSInsetController : UIViewController <HLSReloadable> {
@private
    UIViewController *m_placeholderViewController;
    UIViewController *m_insetViewController;
}

- (id)initWithPlaceholderViewController:(UIViewController<HLSViewPlaceholder> *)placeholderViewController;

@property (nonatomic, readonly, retain) UIViewController *placeholderViewController;
@property (nonatomic, retain) UIViewController *insetViewController;

@end

