//
//  HLSWizardViewController.m
//  nut
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSWizardViewController.h"

#import "HLSValidable.h"

#define WIZARD_VIEW_CONTROLLER_NO_PAGE                 -1

@interface HLSWizardViewController ()

- (void)releaseViews;

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
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        m_currentPage = WIZARD_VIEW_CONTROLLER_NO_PAGE;
    }
    return self;
}

- (void)dealloc
{
    [self releaseViews];
    self.viewControllers = nil;
    self.busyManager = nil;
    self.delegate = nil;
    [super dealloc];
}

- (void)releaseViews
{
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
    BUSY_MANAGER_ASK_FOR_UPDATE();
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.delegate wizardViewController:self didDisplayPage:self.currentPage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViews];
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
    self.currentPage = WIZARD_VIEW_CONTROLLER_NO_PAGE;
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
    [self.delegate wizardViewController:self didDisplayPage:m_currentPage];
}

SYNTHESIZE_BUSY_MANAGER();

@synthesize delegate = m_delegate;

#pragma mark HLSBusy protocol implementation

- (void)enterBusyMode
{
    self.previousButton.enabled = NO;
    self.nextButton.enabled = NO;
    self.doneButton.enabled = NO;
    
    // If no page currently selected, we are done
    if (self.currentPage < 0 || self.currentPage >= [self.viewControllers count]) {
        return;
    }
        
    // Forward the message to the currently displayed view controller (if it understands it)
    UIViewController *viewController = [self.viewControllers objectAtIndex:self.currentPage];
    if ([viewController conformsToProtocol:@protocol(HLSBusy)]) {
        UIViewController<HLSBusy> *busyViewController = viewController;
        [busyViewController enterBusyMode];
    }
}

- (void)exitBusyMode
{
    self.previousButton.enabled = YES;
    self.nextButton.enabled = YES;
    self.doneButton.enabled = YES;    
    
    // If no page currently selected, we are done
    if (self.currentPage < 0 || self.currentPage >= [self.viewControllers count]) {
        return;
    }
    
    // Forward the message to the currently displayed view controller (if it understands it)
    UIViewController *viewController = [self.viewControllers objectAtIndex:self.currentPage];
    if ([viewController conformsToProtocol:@protocol(HLSBusy)]) {
        UIViewController<HLSBusy> *busyViewController = viewController;
        [busyViewController exitBusyMode];
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
    [self.delegate wizardViewControllerHasClickedDoneButton:self];
}

@end
