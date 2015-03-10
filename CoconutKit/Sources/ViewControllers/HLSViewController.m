//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HLSViewController.h"

#import <objc/runtime.h>
#import "HLSAutorotation.h"
#import "HLSLogger.h"
#import "HLSTransformer.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSBundle+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

@implementation HLSViewController

#pragma mark Object creation and destruction

- (instancetype)initWithStoryboardName:(NSString *)storyboardName bundle:(NSBundle *)bundle
{
    if (! bundle) {
        bundle = [NSBundle principalBundle];
    }
    
    return [self viewControllerFromStoryboardWithName:storyboardName inBundle:bundle];
}

- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    if (self = [super initWithNibName:nibName bundle:bundle]) {
        [self hlsViewControllerInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self hlsViewControllerInit];
    }
    return self;
}

- (instancetype)initWithBundle:(NSBundle *)bundle
{
    if (! bundle) {
        bundle = [NSBundle principalBundle];
    }
    
    HLSViewController *viewController = [self viewControllerFromStoryboardWithName:nil inBundle:bundle];
    if (viewController) {
        return viewController;
    }
    
    NSString *nibName = [self nibNameInBundle:bundle];
    return [self initWithNibName:nibName bundle:bundle];
}

- (instancetype)init
{
    return [self initWithBundle:nil];
}

// Common initialization code
- (void)hlsViewControllerInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocalizationDidChange:) name:HLSCurrentLocalizationDidChangeNotification object:nil];
    [self localize];
    HLSLoggerDebug(@"View controller %@ initialized", self);
}

- (void)dealloc
{
    HLSLoggerDebug(@"View controller %@ deallocated", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HLSCurrentLocalizationDidChangeNotification object:nil];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localize];
    HLSLoggerDebug(@"View controller %@: view did load", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    HLSLoggerDebug(@"View controller %@: view will appear, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    HLSLoggerDebug(@"View controller %@: view did appear, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    HLSLoggerDebug(@"View controller %@: view will disappear, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    HLSLoggerDebug(@"View controller %@: view did disappear, animated = %@", self, HLSStringFromBool(animated));
}

#pragma mark Localization

- (void)localize
{
    IMP selfIMP = class_getMethodImplementation([self class], _cmd);
    IMP superIMP = class_getMethodImplementation([self superclass], _cmd);
    BOOL isOverriden = (selfIMP != superIMP);
    if (! isOverriden && [[[NSBundle principalBundle] localizations] count] > 1) {
        HLSLoggerDebug(@"%@ is not localized", [self class]);
    }
}

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    [self localize];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    // This fixes an inconsistency of UIViewController, see HLSViewController.h documentation
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    HLSLoggerDebug(@"View controller %@ will rotate to interface orientation %@", self, HLSStringFromInterfaceOrientation(toInterfaceOrientation));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    HLSLoggerDebug(@"View controller %@ will animated rotation to interface orientation %@", self, HLSStringFromInterfaceOrientation(toInterfaceOrientation));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    HLSLoggerDebug(@"View controller %@ did rotate from interface orientation %@", self, HLSStringFromInterfaceOrientation(fromInterfaceOrientation));
}

#pragma mark Memory warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    HLSLoggerDebug(@"View controller %@ did receive a memory warning", self);
}

#pragma mark View controller resource lookup

- (NSString *)nibNameInBundle:(NSBundle *)bundle
{
    NSParameterAssert(bundle);
    
    Class class = [self class];
    while (class != Nil) {
        NSString *className = NSStringFromClass(class);
        if ([bundle pathForResource:className ofType:@"nib"]) {
            return className;
        }
        class = class_getSuperclass(class);
    }
    return nil;
}

- (HLSViewController *)viewControllerFromStoryboardWithName:(NSString *)storyboardName inBundle:(NSBundle *)bundle
{
    NSParameterAssert(bundle);
    
    Class class = [self class];
    while (class != Nil) {
        NSString *storyboardLookupName = storyboardName ?: NSStringFromClass(class);
        HLSViewController *viewController = [HLSViewController viewControllerFromStoryboardWithName:storyboardLookupName class:class inBundle:bundle];
        if (viewController) {
            return viewController;
        }
        class = class_getSuperclass(class);
    }
    return nil;
}

+ (HLSViewController *)viewControllerFromStoryboardWithName:(NSString *)storyboardName class:(Class)class inBundle:(NSBundle *)bundle
{
    NSParameterAssert(storyboardName);
    NSParameterAssert(class);
    NSParameterAssert(bundle);
    
    NSString *identifier = NSStringFromClass(class);
    if (! [bundle pathForResource:identifier ofType:@"storyboardc"]) {
        return nil;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:identifier bundle:bundle];
    
    // Throws an exception if no view controller is found for the specified identifier
    @try {
        HLSViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
        if (! [viewController isKindOfClass:class]) {
            return nil;
        }
        
        return viewController;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; view: %@; superview: %@>",
            [self class],
            self,
            self.viewIfLoaded,
            self.viewIfLoaded.superview];
}

@end
