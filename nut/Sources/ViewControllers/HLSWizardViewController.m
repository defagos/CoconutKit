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

- (BOOL)validateCurrentPage;

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

@synthesize delegate = m_delegate;

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    // Sanitize input (deals with the "no page" case)
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

- (BOOL)validateCurrentPage
{
    // Sanitize input (deals with the "no page" case)
    if (self.currentPage < 0 || self.currentPage >= [self.viewControllers count]) {
        return YES;
    }
    
    // Validate the current page if it implements a validation mechanism
    UIViewController *viewController = [self.viewControllers objectAtIndex:self.currentPage];
    if ([viewController conformsToProtocol:@protocol(HLSValidable)]) {
        UIViewController<HLSValidable> *validableViewController = viewController;
        return [validableViewController validate];
    }
    // Else assume it is always valid
    else {
        return YES;
    }
}

#pragma mark Event callbacks

- (void)previousButtonClicked:(id)sender
{
    --self.currentPage;
}

- (void)nextButtonClicked:(id)sender
{
    if (! [self validateCurrentPage]) {
        return;
    }
    ++self.currentPage;
}

- (void)doneButtonClicked:(id)sender
{
    if (! [self validateCurrentPage]) {
        return;
    }
    [self.delegate wizardViewControllerHasClickedDoneButton:self];
}

@end
