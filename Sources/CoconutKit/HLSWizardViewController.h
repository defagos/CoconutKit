//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSPlaceholderViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Forward declarations
@protocol HLSWizardViewControllerDelegate;

typedef NS_ENUM(NSInteger, HLSWizardTransitionStyle) {
    HLSWizardTransitionStyleEnumBegin = 0,
    HLSWizardTransitionStyleNone = HLSWizardTransitionStyleEnumBegin,
    HLSWizardTransitionStyleCrossDissolve,
    HLSWizardTransitionStylePushHorizontally,
    HLSWizardTransitionStyleEnumEnd,
    HLSWizardTransitionStyleEnumSize = HLSWizardTransitionStyleEnumEnd - HLSWizardTransitionStyleEnumBegin
};

/**
 * Controller made of pages building a wizard interface. Each page is a separate view controller you must
 * provide. The appearance of the view controller (as well as its behavior under rotation) is customized by 
 * inheriting from it. As for UIViewController, this class is therefore not meant to be instantiated directly.
 *
 * As for UIViewController, if -init is called instead of the designated initalizer, a xib with the same name
 * as the derived class will be searched in the main bundle (the interface can also be created programmatically,
 * of course).
 *
 * The appearance of the wizard is freely customized using the IBOutlets defined by its public interface,
 * either hooking them using Interface Builder or programmatically. No cancel mechanism is provided, the 
 * subclass is responsible of implementing one if needed.
 *
 * When trying to move to a next page, and if the view controller currently displayed implements the
 * HLSValidable protocol, the page is checked for validity before displaying the next one. Similarly
 * when clicking on the "done" button. If the page does not implement this protocol, the page is
 * always assumed to be valid.
 */
@interface HLSWizardViewController : HLSPlaceholderViewController

/**
 * The wizard buttons. Create them either using Interface Builder or by implementing a loadview. Do not attempt
 * to replace the callback method registered for UIControlEventTouchUpInside, or the behavior will be undefined
 */
@property (nonatomic, weak, nullable) IBOutlet UIButton *previousButton;
@property (nonatomic, weak, nullable) IBOutlet UIButton *nextButton;
@property (nonatomic, weak, nullable) IBOutlet UIButton *doneButton;

/**
 * The view controllers to display as pages
 */
@property (nonatomic) NSArray<UIViewController *> *viewControllers;

/**
 * The transition style to use when changing pages. Default is HLSWizardTransitionStyleNone
 */
@property (nonatomic) HLSWizardTransitionStyle wizardTransitionStyle;

/**
 * Go to some page; hopping in forward direction will block if some page in between is not valid
 */
- (void)moveToPage:(NSInteger)page;

@end

@protocol HLSWizardViewControllerDelegate <HLSPlaceholderViewControllerDelegate>
@optional

- (void)wizardViewControllerHasClickedDoneButton:(HLSWizardViewController *)wizardViewController;

@end

NS_ASSUME_NONNULL_END
