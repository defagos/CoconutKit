//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewController.h"

#import <objc/runtime.h>
#import "HLSAutorotation.h"
#import "HLSLogger.h"
#import "HLSTransformer.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSObject+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"
#import "UIViewController+HLSInstantiation.h"

static void commonInit(HLSViewController *self);

@implementation HLSViewController

#pragma mark Object creation and destruction

- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    if (self = [super initWithNibName:nibName bundle:bundle]) {
        commonInit(self);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        commonInit(self);
    }
    return self;
}

- (instancetype)initWithStoryboardName:(NSString *)storyboardName bundle:(NSBundle *)bundle
{
    return [self instanceWithStoryboardName:storyboardName inBundle:bundle];
}

- (instancetype)initWithBundle:(NSBundle *)bundle
{
    return [self instanceInBundle:bundle];
}

- (instancetype)init
{
    return [self initWithBundle:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localize];
}

#pragma mark Localization

- (void)localize
{
    IMP selfIMP = class_getMethodImplementation([self class], _cmd);
    IMP superIMP = class_getMethodImplementation([self superclass], _cmd);
    BOOL isOverriden = (selfIMP != superIMP);
    if (! isOverriden && [[[NSBundle mainBundle] localizations] count] > 1) {
        HLSLoggerDebug(@"%@ is not localized", [self class]);
    }
}

#pragma mark Notifications

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    [self localize];
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

#pragma mark Functions

static void commonInit(HLSViewController *self)
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocalizationDidChange:) name:HLSCurrentLocalizationDidChangeNotification object:nil];
    [self localize];
}
