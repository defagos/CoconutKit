//
//  HLSWizardViewController.m
//  nut
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSWizardViewController.h"

#import "HLSValidable.h"

const NSInteger kWizardViewControllerNoPage = -1;

@interface HLSWizardViewController ()

@property (nonatomic, assign) NSInteger currentPage;

- (BOOL)validatePage:(NSInteger)page;

- (void)previousButtonClicked:(id)sender;
- (void)nextButtonClicked:(id)sender;
- (void)doneButtonClicked:(id)sender;

@end

@implementation HLSWizardViewController

#pragma mark Object creation and destruction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        m_currentPage = kWizardViewControllerNoPage;
    }
    return self;
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
    
    self.previousButton = nil;
    self.nextButton = nil;
    self.doneButton = nil;
}

#pragma mark View lifecycle management

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.previousButton addTarget:self 
                            action:@selector(previousButtonClicked:) 
                  forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton addTarget:self 
                        action:@selector(nextButtonClicked:) 
              forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton addTarget:self 
                        action:@selector(doneButtonClicked:) 
              forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.delegate respondsToSelector:@selector(wizardViewController:didDisplayPage:)]) {
        id<HLSWizardViewControllerDelegate> delegate = (id<HLSWizardViewControllerDelegate>)self.delegate;
        [delegate wizardViewController:self didDisplayPage:self.currentPage];
    }
}

#pragma mark Accessors and mutators

@synthesize previousButton = m_previousButton;

@synthesize nextButton = m_nextButton;

@synthesize doneButton = m_doneButton;

@synthesize viewControllers = m_viewControllers;

- (void)setViewControllers:(NSArray *)viewControllers
{
    // Check for self-assignment
    if (m_viewControllers == viewControllers) {
        return;
    }
    
    // Update the value
    [m_viewControllers release];
    m_viewControllers = [viewControllers retain];
    
    // Start with the first page again (need to reset to no page first so that displayPage always can detect
    // that the page has changed)
    self.currentPage = kWizardViewControllerNoPage;
    self.currentPage = 0;
}

@synthesize currentPage = m_currentPage;

- (void)setCurrentPage:(NSInteger)currentPage
{
    // If no change, nothing to do
    if (currentPage == m_currentPage) {
        return;
    }
    
    m_currentPage = currentPage;
    
    // Sanitize input (deals with the "no page" case)
    if (currentPage < 0 || currentPage >= [self.viewControllers count]) {
        return;
    }
    
    // Refresh the display
    [self reloadData];
    
    // Notify the delegate
    if ([self.delegate respondsToSelector:@selector(wizardViewController:didDisplayPage:)]) {
        id<HLSWizardViewControllerDelegate> delegate = (id<HLSWizardViewControllerDelegate>)self.delegate;
        [delegate wizardViewController:self didDisplayPage:m_currentPage];
    }
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    // Check that a page is currently selected
    if (self.currentPage < 0 || self.currentPage >= [self.viewControllers count]) {
        self.insetViewController = nil;
        self.doneButton.hidden = YES;
        self.previousButton.hidden = YES;
        self.nextButton.hidden = YES;
        return;
    }
    
    // Display the current page
    self.insetViewController = [self.viewControllers objectAtIndex:self.currentPage];
    
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
    
    // Reload the current page content (if supported)
    UIViewController *viewController = [self.viewControllers objectAtIndex:self.currentPage];
    if ([viewController conformsToProtocol:@protocol(HLSReloadable)]) {
        UIViewController<HLSReloadable> *reloadableViewController = viewController;
        [reloadableViewController reloadData];
    }
}

#pragma mark Handling pages

- (BOOL)validatePage:(NSInteger)page
{
    // Sanitize input (deals with the "no page" case)
    if (page < 0 || page >= [self.viewControllers count]) {
        return YES;
    }
    
    // Validate the current page if it implements a validation mechanism
    UIViewController *viewController = [self.viewControllers objectAtIndex:page];
    if ([viewController conformsToProtocol:@protocol(HLSValidable)]) {
        UIViewController<HLSValidable> *validableViewController = viewController;
        return [validableViewController validate];
    }
    // Else assume it is always valid
    else {
        return YES;
    }
}

- (void)moveToPage:(NSUInteger)page
{
    // Sanitize input (unsigned value, no < 0 test here)
    if (page > [self.viewControllers count]) {
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

- (void)previousButtonClicked:(id)sender
{
    --self.currentPage;
}

- (void)nextButtonClicked:(id)sender
{
    if (! [self validatePage:self.currentPage]) {
        return;
    }
    ++self.currentPage;
}

- (void)doneButtonClicked:(id)sender
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
