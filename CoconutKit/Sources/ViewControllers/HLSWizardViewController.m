//
//  HLSWizardViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSWizardViewController.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSValidable.h"

static const NSInteger kWizardViewControllerNoPage = -1;

@interface HLSWizardViewController ()

- (void)hlsWizardViewControllerInit;

@property (nonatomic, assign) NSInteger currentPage;

- (void)refreshWizardInterface;

- (BOOL)validatePage:(NSInteger)page;

- (void)previousPage:(id)sender;
- (void)nextPage:(id)sender;
- (void)done:(id)sender;

@end

@implementation HLSWizardViewController

#pragma mark Object creation and destruction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self hlsWizardViewControllerInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsWizardViewControllerInit];
    }
    return self;
}

// Common initialization code
- (void)hlsWizardViewControllerInit
{
    m_currentPage = kWizardViewControllerNoPage;
    m_wizardTransitionStyle = HLSWizardTransitionStyleNone;
}

- (void)dealloc
{
    self.viewControllers = nil;
    self.delegate = nil;
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    // Release views in cache (since view controllers are retained by a wizard view controller object, so are their view)
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isViewLoaded]) {
            viewController.view = nil;
            [viewController viewDidUnload];
        }
    }
    
    self.previousButton = nil;
    self.nextButton = nil;
    self.doneButton = nil;
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

#pragma mark Memory warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Free all views in cache (except the visible one of course!)
    NSInteger page = 0;
    for (UIViewController *viewController in self.viewControllers) {
        if (page == self.currentPage) {
            continue;
        }
        
        if ([viewController isViewLoaded]) {
            viewController.view = nil;
            [viewController viewDidUnload];            
        }
        
        ++page;
    }
}

#pragma mark Accessors and mutators

@synthesize previousButton = m_previousButton;

@synthesize nextButton = m_nextButton;

@synthesize doneButton = m_doneButton;

@synthesize viewControllers = m_viewControllers;

- (void)setViewControllers:(NSArray *)viewControllers
{
    HLSAssertObjectsInEnumerationAreKindOfClass(viewControllers, UIViewController);
    
    // Check for self-assignment
    if (m_viewControllers == viewControllers) {
        return;
    }
    
    // Update the value
    [m_viewControllers release];
    m_viewControllers = [viewControllers retain];
    
    // Start with the first page
    if ([m_viewControllers count] > 0) {
        self.currentPage = 0;   
    }    
}

@synthesize wizardTransitionStyle = m_wizardTransitionStyle;

@synthesize currentPage = m_currentPage;

- (void)setCurrentPage:(NSInteger)currentPage
{
    // If no change, nothing to do
    if (currentPage == m_currentPage) {
        return;
    }
    
    // Update the value and refresh the UI accordingly
    NSInteger oldCurrentPage = m_currentPage;
    m_currentPage = currentPage;
    [self refreshWizardInterface];
    
    // If no page selected, done
    if (m_currentPage == kWizardViewControllerNoPage) {
        return;
    }
    
    // Sanitize input
    if (currentPage < 0 || currentPage >= [self.viewControllers count]) {
        HLSLoggerError(@"Incorrect page number %d, must lie between 0 and %d", currentPage, [self.viewControllers count]);
        return;
    }
    
    // Find the transition effect to apply
    HLSTransitionStyle transitionStyle;
    switch (self.wizardTransitionStyle) {
        case HLSWizardTransitionStyleNone: {
            transitionStyle = HLSTransitionStyleNone;
            break;
        }
            
        case HLSWizardTransitionStyleCrossDissolve: {
            transitionStyle = HLSTransitionStyleCrossDissolve;
            break;
        }
            
        case HLSWizardTransitionStylePushHorizontally: {
            if (m_currentPage > oldCurrentPage) {
                transitionStyle = HLSTransitionStylePushFromRight;
            }
            else {
                transitionStyle = HLSTransitionStylePushFromLeft;
            }
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown transition style");
            transitionStyle = HLSTransitionStyleNone;
            break;
        }            
    }
    
    // Display the current page
    UIViewController *viewController = [self.viewControllers objectAtIndex:m_currentPage];
    [self setInsetViewController:viewController atIndex:0 withTransitionStyle:transitionStyle];
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    // Reload the current page content (if supported)
    UIViewController *viewController = [self.viewControllers objectAtIndex:self.currentPage];
    if ([viewController conformsToProtocol:@protocol(HLSReloadable)]) {
        [(UIViewController<HLSReloadable>*)viewController reloadData];
    }
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
        HLSLoggerError(@"Incorrect page number %d, must lie between 0 and %d", self.currentPage, [self.viewControllers count]);
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
        HLSLoggerError(@"Incorrect page number %d, must lie between 0 and %d", page, [self.viewControllers count]);
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
        HLSLoggerError(@"Incorrect page number %d, must lie between 0 and %d", page, [self.viewControllers count]);
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
