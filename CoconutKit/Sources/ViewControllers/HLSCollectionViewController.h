//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <UIKit/UIKit.h>

/**
 * Provide the same storyboard, nib instantiation and localization abilities as HLSViewController, but for UICollectionViewController
 * subclasses
 */
@interface HLSCollectionViewController : UICollectionViewController

/**
 * Refer to the corresponding HLSViewController documentation
 */
- (instancetype)initWithStoryboardName:(NSString *)storyboardName bundle:(NSBundle *)bundle NS_REQUIRES_SUPER;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_REQUIRES_SUPER;

/**
 * See -[HLSViewController localize] documentation
 */
- (void)localize NS_REQUIRES_SUPER;

@end

@interface UICollectionViewController (HLSRequiresSuper)

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
