//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Provide the same storyboard, nib instantiation and localization abilities as HLSViewController, but for UITableViewController
 * subclasses
 */
@interface HLSTableViewController : UITableViewController

/**
 * Refer to the corresponding HLSViewController documentation
 */
- (instancetype)initWithStoryboardName:(nullable NSString *)storyboardName bundle:(nullable NSBundle *)bundle NS_REQUIRES_SUPER;
- (instancetype)initWithBundle:(nullable NSBundle *)bundle NS_REQUIRES_SUPER;

/**
 * See -[HLSViewController localize] documentation
 */
- (void)localize NS_REQUIRES_SUPER;

@end

@interface HLSTableViewController (HLSRequiresSuper)

- (instancetype)initWithNibName:(nullable NSString *)nibName bundle:(nullable NSBundle *)bundle NS_REQUIRES_SUPER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_REQUIRES_SUPER;
- (void)viewDidLoad NS_REQUIRES_SUPER;
- (void)viewWillAppear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewDidAppear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewWillDisappear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewDidDisappear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)didReceiveMemoryWarning NS_REQUIRES_SUPER;
- (void)willMoveToParentViewController:(UIViewController *)parent NS_REQUIRES_SUPER;
- (void)didMoveToParentViewController:(UIViewController *)parent NS_REQUIRES_SUPER;
- (BOOL)shouldAutorotate NS_REQUIRES_SUPER;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
