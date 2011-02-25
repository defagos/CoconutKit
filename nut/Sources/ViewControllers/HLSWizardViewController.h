//
//  HLSWizardViewController.h
//  nut
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSPlaceholderViewController.h"

// Forward declarations
@protocol HLSWizardViewControllerDelegate;

/**
 * Controller made of pages building a wizard interface. Each page is a separate view controller you must
 * provide. The appearance of the view controller (as well as its behavior under rotation) is customized by 
 * inheriting from it. As for UIViewController, this class is therefore not meant to be instantiated directly.
 *
 * As for UIViewController, if init is called instead of the designated initalizer, a xib with the same name
 * as the derived class will be searched in the main bundle (the interface can also be created programmatically,
 * of course).
 *
 * The appearance of the wizard is freely customized using the IBOutlets defined by its public interface,
 * either hooking them using Interface Builder or programmatically. No cancel mechanism is provided, the subclass 
 * can decide whether it wants to display such a button or whether this button will appear in a navigation bar (if
 * any is available) or on its own view.
 *
 * When trying to move to a next page, and if the view controller currently displayed implements the
 * HLSValidable protocol, the page is checked for validity before displaying the next one. Similarly
 * when clicking on the "done" button. If the page does not implement this protocol, the page is
 * always assumed to be valid.
 *
 * Designated initializer: initWithNibName:bundle:
 */
@interface HLSWizardViewController : HLSPlaceholderViewController <HLSReloadable> {
@private
    UIButton *m_previousButton;
    UIButton *m_nextButton;
    UIButton *m_doneButton;
    NSArray *m_viewControllers;
    NSInteger m_currentPage;
}

@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;

@property (nonatomic, retain) NSArray *viewControllers;

/**
 * Go to some page; hopping in forward direction will block if some page in between is not valid
 */
- (void)moveToPage:(NSUInteger)page;

@end

@protocol HLSWizardViewControllerDelegate <NSObject>
@optional

- (void)wizardViewController:(HLSWizardViewController *)wizardViewController
              didDisplayPage:(NSUInteger)page;
- (void)wizardViewControllerHasClickedDoneButton:(HLSWizardViewController *)wizardViewController;

@end
