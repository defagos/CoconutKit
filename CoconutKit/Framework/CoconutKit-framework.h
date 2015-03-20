//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

//! Project version number for CoconutKit-framework.
FOUNDATION_EXPORT double CoconutKit_VersionNumber;

//! Project version string for CoconutKit-framework.
FOUNDATION_EXPORT const unsigned char CoconutKit_VersionString[];

#import <CoconutKit/CALayer+HLSExtensions.h>
#import <CoconutKit/CAMediaTimingFunction+HLSExtensions.h>
#import <CoconutKit/HLSAnimation.h>
#import <CoconutKit/HLSAnimationStep.h>
#import <CoconutKit/HLSApplicationInformation.h>
#import <CoconutKit/HLSAssert.h>
#import <CoconutKit/HLSAutorotation.h>
#import <CoconutKit/HLSCollectionViewController.h>
#import <CoconutKit/HLSConnection.h>
#import <CoconutKit/HLSContainerStack.h>
#import <CoconutKit/HLSCoreError.h>
#import <CoconutKit/HLSCursor.h>
#import <CoconutKit/HLSFakeConnection.h>
#import <CoconutKit/HLSFileManager.h>
#import <CoconutKit/HLSFileURLConnection.h>
#import <CoconutKit/HLSGeometry.h>
#import <CoconutKit/HLSGoogleChromeActivity.h>
#import <CoconutKit/HLSInMemoryFileManager.h>
#import <CoconutKit/HLSKeyboardInformation.h>
#import <CoconutKit/HLSLabel.h>
#import <CoconutKit/HLSLayerAnimation.h>
#import <CoconutKit/HLSLayerAnimationStep.h>
#import <CoconutKit/HLSLogger.h>
#import <CoconutKit/HLSManagedObjectCopying.h>
#import <CoconutKit/HLSModelManager.h>
#import <CoconutKit/HLSNibView.h>
#import <CoconutKit/HLSNotifications.h>
#import <CoconutKit/HLSObjectAnimation.h>
#import <CoconutKit/HLSOptionalFeatures.h>
#import <CoconutKit/HLSPlaceholderInsetSegue.h>
#import <CoconutKit/HLSPlaceholderViewController.h>
#import <CoconutKit/HLSPreviewItem.h>
#import <CoconutKit/HLSRestrictedInterfaceProxy.h>
#import <CoconutKit/HLSRuntime.h>
#import <CoconutKit/HLSSafariActivity.h>
#import <CoconutKit/HLSSlideshow.h>
#import <CoconutKit/HLSStackController.h>
#import <CoconutKit/HLSStackPushSegue.h>
#import <CoconutKit/HLSStandardFileManager.h>
#import <CoconutKit/HLSSubtitleTableViewCell.h>
#import <CoconutKit/HLSTableSearchDisplayViewController.h>
#import <CoconutKit/HLSTableViewCell.h>
#import <CoconutKit/HLSTableViewController.h>
#import <CoconutKit/HLSTask.h>
#import <CoconutKit/HLSTaskGroup.h>
#import <CoconutKit/HLSTaskManager.h>
#import <CoconutKit/HLSTaskOperation.h>
#import <CoconutKit/HLSTaskOperation+Protected.h>
#import <CoconutKit/HLSTransformer.h>
#import <CoconutKit/HLSTransition.h>
#import <CoconutKit/HLSURLConnection.h>
#import <CoconutKit/HLSUserInterfaceLock.h>
#import <CoconutKit/HLSValidable.h>
#import <CoconutKit/HLSValidators.h>
#import <CoconutKit/HLSValue1TableViewCell.h>
#import <CoconutKit/HLSValue2TableViewCell.h>
#import <CoconutKit/HLSVector.h>
#import <CoconutKit/HLSViewAnimation.h>
#import <CoconutKit/HLSViewAnimationStep.h>
#import <CoconutKit/HLSViewBindingDelegate.h>
#import <CoconutKit/HLSViewBindingError.h>
#import <CoconutKit/HLSViewController.h>
#import <CoconutKit/HLSWebViewController.h>
#import <CoconutKit/HLSWizardViewController.h>
#import <CoconutKit/NSArray+HLSExtensions.h>
#import <CoconutKit/NSBundle+HLSExtensions.h>
#import <CoconutKit/NSBundle+HLSDynamicLocalization.h>
#import <CoconutKit/NSCalendar+HLSExtensions.h>
#import <CoconutKit/NSData+HLSExtensions.h>
#import <CoconutKit/NSDate+HLSExtensions.h>
#import <CoconutKit/NSDateFormatter+HLSExtensions.h>
#import <CoconutKit/NSDictionary+HLSExtensions.h>
#import <CoconutKit/NSError+HLSExtensions.h>
#import <CoconutKit/NSManagedObject+HLSExtensions.h>
#import <CoconutKit/NSManagedObject+HLSValidation.h>
#import <CoconutKit/NSMutableArray+HLSExtensions.h>
#import <CoconutKit/NSNumber+HLSExtensions.h>
#import <CoconutKit/NSObject+HLSExtensions.h>
#import <CoconutKit/NSStream+HLSExtensions.h>
#import <CoconutKit/NSString+HLSExtensions.h>
#import <CoconutKit/NSTimeZone+HLSExtensions.h>
#import <CoconutKit/UIActionSheet+HLSExtensions.h>
#import <CoconutKit/UIActivityIndicatorView+HLSViewBinding.h>
#import <CoconutKit/UIApplication+HLSExtensions.h>
#import <CoconutKit/UIColor+HLSExtensions.h>
#import <CoconutKit/UIControl+HLSExclusiveTouch.h>
#import <CoconutKit/UIDatePicker+HLSViewBinding.h>
#import <CoconutKit/UIFont+HLSExtensions.h>
#import <CoconutKit/UIImage+HLSExtensions.h>
#import <CoconutKit/UIImageView+HLSViewBinding.h>
#import <CoconutKit/UILabel+HLSDynamicLocalization.h>
#import <CoconutKit/UILabel+HLSViewBinding.h>
#import <CoconutKit/UINavigationController+HLSExtensions.h>
#import <CoconutKit/UIPageControl+HLSViewBinding.h>
#import <CoconutKit/UIPopoverController+HLSExtensions.h>
#import <CoconutKit/UIProgressView+HLSViewBinding.h>
#import <CoconutKit/UIScrollView+HLSExtensions.h>
#import <CoconutKit/UISegmentedControl+HLSViewBinding.h>
#import <CoconutKit/UISlider+HLSViewBinding.h>
#import <CoconutKit/UISplitViewController+HLSExtensions.h>
#import <CoconutKit/UIStepper+HLSViewBinding.h>
#import <CoconutKit/UISwitch+HLSViewBinding.h>
#import <CoconutKit/UITabBarController+HLSExtensions.h>
#import <CoconutKit/UITextField+HLSExtensions.h>
#import <CoconutKit/UITextField+HLSViewBinding.h>
#import <CoconutKit/UITextView+HLSCursorVisibility.h>
#import <CoconutKit/UITextView+HLSExtensions.h>
#import <CoconutKit/UITextView+HLSViewBinding.h>
#import <CoconutKit/UIView+HLSExtensions.h>
#import <CoconutKit/UIView+HLSViewBinding.h>
#import <CoconutKit/UIView+HLSViewBindingImplementation.h>
#import <CoconutKit/UIViewController+HLSExtensions.h>
#import <CoconutKit/UIViewController+HLSViewBinding.h>
#import <CoconutKit/UIWebView+HLSExtensions.h>
#import <CoconutKit/UIWindow+HLSExtensions.h>
