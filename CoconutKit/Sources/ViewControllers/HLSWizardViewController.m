//
//  HLSWizardViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSWizardViewController.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSValidable.h"
#import "UIViewController+HLSExtensions.h"

static const NSInteger kWizardViewControllerNoPage = -1;

@interface HLSWizardViewController ()

@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation HLSWizardViewController {
@private
    HLSWizardTransitionStyle _wizardTransitionStyle;
    NSInteger _currentPage;
}

#pragma mark Object creation and destruction

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self hlsWizardViewControllerInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self hlsWizardViewControllerInit];
    }
    return self;
}

// Common initialization code
- (void)hlsWizardViewControllerInit
{
    _currentPage = kWizardViewControllerNoPage;
    _wizardTransitionStyle = HLSWizardTransitionStyleNone;
}

#pragma mark View lifecycle management

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.previousButton addTarget:self 
                            action:@selector(previousPage:) 
                  forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton addTarget:self 
                        action:@selector(nextPage:) 
              forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton addTarget:self 
                        action:@selector(done:) 
              forControlEvents:UIControlEventTouchUpInside];
    
    [self refreshWizardInterface];
}

#pragma mark Accessors and mutators

- (void)setViewControllers:(NSArray *)viewControllers
{
    HLSAssertObjectsInEnumerationAreKindOfClass(viewControllers, UIViewController);
    
    if (_viewControllers == viewControllers) {
        return;
    }
    
    _viewControllers = viewControllers;
    
    // Start with the first page
    if ([_viewControllers count] > 0) {
        self.currentPage = 0;   
    }    
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    if (currentPage == _currentPage) {
        return;
    }
    
    // Update the value and refresh the UI accordingly
    NSInteger oldCurrentPage = _currentPage;
    _currentPage = currentPage;
    [self refreshWizardInterface];
    
    // If no page selected, done
    if (_currentPage == kWizardViewControllerNoPage) {
        return;
    }
    
    // Sanitize input
    if (currentPage < 0 || currentPage >= [self.viewControllers count]) {
        HLSLoggerError(@"Incorrect page number %ld, must lie between 0 and %lu", (long)currentPage, (unsigned long)[self.viewControllers count]);
        return;
    }
    
    // Find the transition effect to apply
    Class transitionClass;
    switch (self.wizardTransitionStyle) {
        case HLSWizardTransitionStyleNone: {
            transitionClass = [HLSTransitionNone class];
            break;
        }
            
        case HLSWizardTransitionStyleCrossDissolve: {
            transitionClass = [HLSTransitionCrossDissolve class];
            break;
        }
            
        case HLSWizardTransitionStylePushHorizontally: {
            if (_currentPage > oldCurrentPage) {
                transitionClass = [HLSTransitionPushFromRight class];
            }
            else {
                transitionClass = [HLSTransitionPushFromLeft class];
            }
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown transition style");
            transitionClass = [HLSTransitionNone class];
            break;
        }            
    }
    
    // Display the current page
    UIViewController *viewController = [self.viewControllers objectAtIndex:_currentPage];
    [self setInsetViewController:viewController atIndex:0 withTransitionClass:transitionClass];
}

#pragma mark Refreshing the UI

- (void)refreshWizardInterface
{
    // Reset UI elements
    self.doneButton.hidden = YES;
    self.previousButton.hidden = YES;
    self.nextButton.hidden = YES;            
    
    // If no page selected, done
    if (self.currentPage == kWizardViewControllerNoPage) {
        return;
    }
    
    // Sanitize input
    if (self.currentPage < 0 || self.currentPage >= [self.viewControllers count]) {
        HLSLoggerError(@"Incorrect page number %ld, must lie between 0 and %lu", (long)self.currentPage, (unsigned long)[self.viewControllers count]);
        return;
    }
    
    // Done button on last page only
    if (self.currentPage == [self.viewControllers count] - 1) {
        self.doneButton.hidden = NO;
    }
    else {
        self.doneButton.hidden = YES;
    }
    
    // Previous button on all but the first page
    if (self.currentPage > 0) {
        self.previousButton.hidden = NO;
    }
    else {
        self.previousButton.hidden = YES;
    }
    
    // Next button on all but the last page
    if (self.currentPage < [self.viewControllers count] - 1) {
        self.nextButton.hidden = NO;
    }
    else {
        self.nextButton.hidden = YES;
    }    
}

#pragma mark Handling pages

- (BOOL)validatePage:(NSInteger)page
{
    // Sanitize input (deals with the "no page" case)
    if (page < 0 || page >= [self.viewControllers count]) {
        HLSLoggerError(@"Incorrect page number %ld, must lie between 0 and %lu", (long)page, (unsigned long)[self.viewControllers count]);
        return YES;
    }
    
    // Validate the current page if it implements a validation mechanism
    UIViewController *viewController = [self.viewControllers objectAtIndex:page];
    if ([viewController conformsToProtocol:@protocol(HLSValidable)]) {
        return [(UIViewController<HLSValidable>*)viewController validate];
    }
    // Else assume it is always valid
    else {
        return YES;
    }
}

- (void)moveToPage:(NSInteger)page
{
    // Sanitize input
    if (page < 0 || page >= [self.viewControllers count]) {
        HLSLoggerError(@"Incorrect page number %ld, must lie between 0 and %lu", (long)page, (unsigned long)[self.viewControllers count]);
        return;
    }
    
    // If not moving, nothing to do
    if (page == self.currentPage) {
        return;
    }
    
    // Going forward, check pages in between and stops on a page if it is not valid
    if (page > self.currentPage) {
        for (NSInteger i = self.currentPage; i < page; ++i) {
            self.currentPage = i;
            if (! [self validatePage:i]) {
                return;
            }
        }
    }
    
    self.currentPage = page;
}

#pragma mark Event callbacks

- (void)previousPage:(id)sender
{
    --self.currentPage;
}

- (void)nextPage:(id)sender
{
    if (! [self validatePage:self.currentPage]) {
        return;
    }
    ++self.currentPage;
}

- (void)done:(id)sender
{
    if (! [self validatePage:self.currentPage]) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(wizardViewControllerHasClickedDoneButton:)]) {
        id<HLSWizardViewControllerDelegate> delegate = (id<HLSWizardViewControllerDelegate>)self.delegate;
        [delegate wizardViewControllerHasClickedDoneButton:self];
    }
}

@end
