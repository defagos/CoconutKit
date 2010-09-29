//
//  HLSPageController.m
//  Paging
//
//  Created by Samuel Défago on 7/22/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSPageController.h"

#import "HLSLogger.h"
#import "HLSOrientationCloner.h"
#import "HLSStandardWidgetConstants.h"

#define MAX_NBR_DOTS_PAGE_CONTROLLER_PORTRAIT                   19
#define MAX_NBR_DOTS_PAGE_CONTROLLER_LANDSCAPE                  28

@interface HLSPageController ()

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *pageViewControllers;

/**
 * When the current page is changed using this property, neighbouring pages are loaded lazily, but no scrolling occurs to display
 * the new current page. If you need to scroll to the newly set page, call programmaticallScrollToCurrentPageAnimated: after you
 * have set the new current page
 */
@property (nonatomic, assign) NSInteger currentPage;

- (void)setMaximized:(BOOL)maximized;

- (void)maximizeForOrientation:(UIInterfaceOrientation)orientation;
- (void)minimize;

- (void)refreshPageControl;

- (void)updateDimensions;

- (CGRect)frameForPage:(NSInteger)page;

- (void)loadPage:(NSInteger)page;

- (void)programmaticallyScrollToCurrentPageAnimated:(BOOL)animated;

- (void)pageControlValueChanged:(id)sender;

- (void)statusBarFrameChanged:(NSNotification *)notification;

- (UIViewController *)viewControllerObjectAtIndex:(NSUInteger)index;

@end

@implementation HLSPageController

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        // Start with no current page
        m_currentPage = PAGE_CONTROLLER_NO_PAGE;
        m_initialPage = PAGE_CONTROLLER_NO_PAGE;
        m_pageControlPreviousPage = PAGE_CONTROLLER_NO_PAGE;
        m_maximizedPortrait = NO;
        m_maximizedLandscape = NO;
        m_firstAppearance = YES;
        m_pageControlHeight = PAGE_CONTROL_STD_HEIGHT;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarFrameChanged:) 
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.backgroundView = nil;
    self.scrollView = nil;
    self.pageControl = nil;
    self.pageViewControllers = nil;
    self.delegate = nil;
    self.loader = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize currentPage = m_currentPage;

- (void)setCurrentPage:(NSInteger)currentPage
{
    // If the page is not being changed, nothing to do
    if (m_currentPage == currentPage) {
        return;
    }
    
    // If out-of-bounds, nothing to do
    if (currentPage < 0 || currentPage >= [self viewControllerCount]) {
        return;
    }
    
    // We keep things easy by dealing with view appearance in a simple manner: We do not create events when the view
    // really appears or disappears, but when it becomes the current one or is not the current one anymore. This way
    // we avoid complications due to the fact that other views on the left or the right are visible. This is of course
    // not perfect, but time will tell if we really need to implement the perfect behavior. The reason is that the user 
    // interacts only with the current view, and when it is stable in the middle of the screen. If some views resize
    // in an awkward way, then maybe we will need to do something more clever here, but in the meantime this should
    // be perfectly sufficient for almost all purposes. The clever solution would scatter more code across this
    // implementation (or require a refactoring), and this might not be worth the price / needed.
    // TODO: Maybe improve if this does not work in some cases
    UIViewController *prevCurrentViewController; 
    if (m_currentPage != PAGE_CONTROLLER_NO_PAGE) {
        prevCurrentViewController = [self viewControllerObjectAtIndex:m_currentPage];
    }
    else {
        prevCurrentViewController = nil;
    }

    UIViewController *currentViewController; 
    if (currentPage != PAGE_CONTROLLER_NO_PAGE) {
        currentViewController = [self viewControllerObjectAtIndex:currentPage];
    }
    else {
        currentViewController = nil;
    }
    
    // Set current page
    m_currentPage = currentPage;
    
    // Sync the page control
    [self refreshPageControl];
    
    // Notify the views about the change that will happen
    [prevCurrentViewController viewWillDisappear:YES];
    [currentViewController viewWillAppear:YES];
    
    // Refresh the display
    [self reloadData];
    
    // Notify the views about the change that happened
    [prevCurrentViewController viewDidDisappear:YES];
    [currentViewController viewDidAppear:YES];
    
    // Forward the title of the wrapped view controller currently displayed
    self.title = currentViewController.title;
    
    // Notify the delegate of the page change
    [self.delegate pageController:self movedToPage:m_currentPage];
}

- (void)setInitialPage:(NSInteger)initialPage
{
    // Sanitize input
    if (initialPage < 0 || initialPage >= [self viewControllerCount]) {
        return;
    }
    
    m_initialPage = initialPage;
}

- (void)setPageControlHeight:(CGFloat)height
{
    m_pageControlHeight = height;
}

- (NSArray *)viewControllers
{
    return [NSArray arrayWithArray:self.pageViewControllers];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    self.pageViewControllers = [NSMutableArray arrayWithArray:viewControllers];
}

@synthesize backgroundView = m_backgroundView;

@synthesize scrollView = m_scrollView;

@synthesize pageControl = m_pageControl;

@synthesize pageViewControllers = m_pageViewControllers;

- (void)setPageViewControllers:(NSMutableArray *)pageViewControllers
{
    // Check for self-assignment
    if (m_pageViewControllers == pageViewControllers) {
        return;
    }
    
    // Release all previously displayed views (if any) and associated controllers
    for (UIViewController *viewController in m_pageViewControllers) {
        // Nothing to do if not loaded
        if ([viewController isEqual:[NSNull null]]) {
            continue;
        }
        
        // Remove the wrapper (since it owns the wrapped view, this also cleans it)
        UIView *wrapperView = [viewController.view superview];
        [wrapperView removeFromSuperview];
    }
    
    // Update value
    [m_pageViewControllers release];
    m_pageViewControllers = [pageViewControllers retain];
    
    // Retain the new view controllers (will be displayed lazily)
    for (UIViewController *viewController in m_pageViewControllers) {
        if ([viewController isEqual:[NSNull null]]) {
            continue;
        }
    }
    
    [self updateDimensions];
}

@synthesize maximizedPortrait = m_maximizedPortrait;

@synthesize maximizedLandscape = m_maximizedLandscape;

@synthesize delegate = m_delegate;

@synthesize loader = m_loader;

#pragma mark View lifecycle

- (void)loadView
{
    // Always build views as if they take the whole space (size is then adjusted by the parent view depending
    // on the autoresize property)
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    // Background
    self.backgroundView = [[[UIView alloc] initWithFrame:applicationFrame] autorelease];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.autoresizesSubviews = YES;
    
    // When adding subviews, always work in parent coordinate system
    CGRect backgroundBounds = self.backgroundView.bounds;
    
    // Scroll view
    CGRect scrollViewFrame = CGRectMake(0.f, 
                                        0.f,
                                        backgroundBounds.size.width,
                                        backgroundBounds.size.height - m_pageControlHeight);
    self.scrollView = [[[UIScrollView alloc] initWithFrame:scrollViewFrame] autorelease];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    
    // Enable paging behavior
    self.scrollView.pagingEnabled = YES;
    
    // Remove scroll bars (consistent with common Apple design)
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    // Disable scrolling to the top by clicking the status bar
    self.scrollView.scrollsToTop = NO;
    
    [self.backgroundView addSubview:self.scrollView];
    
    // Page control
    CGRect pageControlFrame = CGRectMake(0.f, 
                                         backgroundBounds.size.height - m_pageControlHeight,
                                         backgroundBounds.size.width,
                                         m_pageControlHeight);
    self.pageControl = [[[UIPageControl alloc] initWithFrame:pageControlFrame] autorelease];
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.pageControl.backgroundColor = [UIColor clearColor];
    
    // Attach events
    [self.pageControl addTarget:self 
                         action:@selector(pageControlValueChanged:) 
               forControlEvents:UIControlEventValueChanged];
    
    [self.backgroundView addSubview:self.pageControl];
    
    // Set root view
    self.view = self.backgroundView;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Only if first time the page controller appears
    if (m_firstAppearance) {
        // Start with the initial page if set
        if (m_initialPage != PAGE_CONTROLLER_NO_PAGE) {
            self.currentPage = m_initialPage;
        }
        // Else start with the first
        else {
            self.currentPage = 0;
        }
        
        m_firstAppearance = NO;
    }
    
    // Display the page
    [self programmaticallyScrollToCurrentPageAnimated:NO];
    
    // Ensure that the interface appears maximized if desired
    [self maximizeForOrientation:self.interfaceOrientation];
    
    // Forward to currently displayed view controller as well
    UIViewController *currentViewController = [self viewControllerObjectAtIndex:self.currentPage];
    [currentViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Calculate all sizes (now that the view has appeared, all UI elements are displayed, therefore
    // we can calculate them correctly)
    [self updateDimensions];
    
    // Sync the page control
    [self refreshPageControl];
    
    // Forward to currently displayed view controller as well
    UIViewController *currentViewController = [self viewControllerObjectAtIndex:self.currentPage];
    [currentViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Forward to currently displayed view controller as well
    UIViewController *currentViewController = [self viewControllerObjectAtIndex:self.currentPage];
    [currentViewController viewWillDisappear:animated];
    
    // Must be neutral for orientation, i.e. must not affect view controllers loaded before or after
    [self minimize];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Forward to currently displayed view controller as well
    UIViewController *currentViewController = [self viewControllerObjectAtIndex:self.currentPage];
    [currentViewController viewDidDisappear:animated];
}

#pragma mark Orientation management

/**
 * We must only check if an orientation is allowed here. The process of changing the views itself must NOT be done
 * here since the rotation has of course not occurred (and we need the new layout to get autoresizing right). Moreover,
 * this function is also called when the view is loaded for the first time (to check that its initial orientation
 * is correct), another reason why we must not alter any views here.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // Check if this orientation is supported
    if (! [self allViewControllersShouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    // When this function has been called and is returning YES, the orientation is known for sure. Depending on the
    // orientation, we display a maximum number of dots in the page controller
    if (UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
        self.pageControl.numberOfPages = MIN(MAX_NBR_DOTS_PAGE_CONTROLLER_PORTRAIT, [self viewControllerCount]);
    }
    else {
        self.pageControl.numberOfPages = MIN(MAX_NBR_DOTS_PAGE_CONTROLLER_LANDSCAPE, [self viewControllerCount]);
    }
    
    return YES;
}

/**
 * Container view controllers MUST forward ALL rotation messages to the currently displayed view controller so that
 * it can responds to these events properly as well
 * (see http://developer.apple.com/iphone/library/featuredarticles/ViewControllerPGforiPhoneOS/BasicViewControllers/BasicViewControllers.html)
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Forward to the currently displayed view controller first    
    UIViewController *currentViewController = [self viewControllerObjectAtIndex:self.currentPage];
    [currentViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Maximize if desired; this must be done by the page controller itself to be able to properly size the views
    // it manages
    [self maximizeForOrientation:toInterfaceOrientation];
}

/**
 * We swap the view controllers early in the animation cycle. This way, the animation transition is nice. We could have swapped
 * them at the end of the animation (in didRotateFromInterfaceOrientation:), but the result would have been less appealing
 * since all rotation would have occurred with the old view controller visible, swapping with the new one at the very end
 * of the animation.
 */
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Forward to the currently displayed view controller first    
    UIViewController *currentViewController = [self viewControllerObjectAtIndex:self.currentPage];
    [currentViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // We will replace the view controller list with view controllers with the new orientation (if we arrive here,
    // shouldAutorotateToInterfaceOrientation: has returned YES), therefore they all support the new orientation
    // (at least they were advertised to if we are using lazy loading)
    NSMutableArray *orientedViewControllers = [NSMutableArray arrayWithCapacity:[self viewControllerCount]];
    
    // Get all rotated versions of the view controllers
    for (UIViewController *viewController in self.pageViewControllers) {
        // If not loaded, put a non-loaded controller as well
        if ([viewController isEqual:[NSNull null]]) {
            [orientedViewControllers addObject:[NSNull null]];
            continue;
        }
        
        // If the view controller can autorotate, just keep it (it will deal with its own orientation). Note that controllers
        // which can autorotate by generating another view does implement shouldAutorotateToInterfaceOrientation:,
        // but return NO for this orientation
        if ([viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            [orientedViewControllers addObject:viewController];
            continue;
        }
        
        // If the view controller can rotate by cloning, create and use the clone for the new orientation
        if ([viewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
            UIViewController<HLSOrientationCloner> *clonableViewController = viewController;
            UIViewController *clonedViewController = [clonableViewController viewControllerCloneWithOrientation:toInterfaceOrientation];
            
            // Special case: If the currently displayed view controller rotates by cloning, we must generate corresponding 
            // view lifecycle notifications that views will change
            if (clonableViewController == currentViewController) {
                [clonableViewController viewWillDisappear:YES];
                [clonedViewController viewWillAppear:YES];
            }
            
            // Refresh the display
            [self reloadData];
            
            // Special case of currently displayed view controller: views have been swapped
            if (clonableViewController == currentViewController) {
                [clonableViewController viewDidDisappear:YES];
                [clonedViewController viewDidAppear:YES];
            }
            
            // In the case of lazy loading, it is the responsibility of the caller to ensure that all view controllers
            // support the new orientation. Check and log if programming error
            if (! clonableViewController) {
                logger_error(@"A view controller does not support the new orientation");
            }
            
            [orientedViewControllers addObject:clonedViewController];
            continue;
        }
        
        // No oriented version available, caller has lied to us in lazy loading mode
        logger_error(@"A view controller does not support the new orientation");
    }
    
    // We replace the view controllers
    self.pageViewControllers = orientedViewControllers;
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Forward to the currently displayed view controller first    
    UIViewController *currentViewController = [self viewControllerObjectAtIndex:self.currentPage];
    [currentViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // Forward to the currently displayed view controller first
    UIViewController *currentViewController = [self viewControllerObjectAtIndex:self.currentPage];
    [currentViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];    
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Forward to the currently displayed view controller first
    UIViewController *currentViewController = [self viewControllerObjectAtIndex:self.currentPage];
    [currentViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Forward to the currently displayed view controller first
    UIViewController *currentViewController = [self viewControllerObjectAtIndex:self.currentPage];
    [currentViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // Sync page control
    [self refreshPageControl];
    
    // Pages have been automatically unloaded when updating the view controllers. Reload the current one (and its
    // neighbours), and make sure it is visible
    [self reloadData];
    [self programmaticallyScrollToCurrentPageAnimated:NO];
}

#pragma mark Maximization and minimization

- (void)setMaximized:(BOOL)maximized
{
    // iOS 3.2 and above
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
        [[UIApplication sharedApplication] setStatusBarHidden:maximized withAnimation:UIStatusBarAnimationSlide];
    }
    // Below
    else {
        // The (id) just suppresses deprecation warnings here
        [(id)[UIApplication sharedApplication] setStatusBarHidden:maximized animated:YES];
    }
    
    // Even hides the navigation bar if wrapped into a navigation controller
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:maximized animated:YES];
    }
}

- (void)maximizeForOrientation:(UIInterfaceOrientation)orientation
{
    if ((UIDeviceOrientationIsPortrait(orientation) && self.maximizedPortrait)
        || (UIDeviceOrientationIsLandscape(orientation) && self.maximizedLandscape)) {
        [self setMaximized:YES];
    }
    else {
        [self setMaximized:NO];
    }
}

- (void)minimize
{
    [self setMaximized:NO];
}

#pragma mark Display methods

- (void)refreshPageControl
{
    // To deal with more pages that can fit within a page controller, we must use a ratio so that all pages
    // can be represented using the maximal number of dots in the page control (integer division here!)
    self.pageControl.currentPage = m_currentPage * self.pageControl.numberOfPages / [self viewControllerCount];
    
    // Save this previous value to be able to detect in which direction the page control is clicked the next time
    m_pageControlPreviousPage = self.pageControl.currentPage;
}

- (void)updateDimensions
{
    NSUInteger nbrPages = [self viewControllerCount];
    CGRect scrollViewBounds = [self.scrollView bounds];
    
    // Resize to display all controllers
    self.scrollView.contentSize = CGSizeMake(scrollViewBounds.size.width * nbrPages, scrollViewBounds.size.height);
}

- (CGRect)frameForPage:(NSInteger)page
{
    // Get the visible area rectangle
    CGRect scrollViewBounds = [self.scrollView bounds];
    
    return CGRectMake(scrollViewBounds.size.width * page,
                      0.f, 
                      scrollViewBounds.size.width, 
                      scrollViewBounds.size.height);
}

- (void)loadPage:(NSInteger)page
{
    // Sanitize input
    if (page < 0 || page >= [self viewControllerCount]) {
        return;
    }
    
    // If not aleady loaded, load it; the autoresize behavior for views added to a scroll view is relative to the
    // scroll view content area, not to the visible scrollable frame. For a page controller, this behavior is
    // undesirable since the maningful area is the visible scrollable frame, not the content area. To ensure that
    // the autoresize behavior works as expected, we do not add views directly but add them into wrapper views
    // with proper autoresize mask first. This way, the views we add will autoresize relative to the wrapper (i.e.
    // the visible area), not relative to the content area
    UIViewController *viewController = [self viewControllerObjectAtIndex:page];
    if (! viewController.view.superview) {
        // Create the wrapper view and add it first
        UIView *wrapperView = [[[UIView alloc] initWithFrame:[self frameForPage:page]] 
                               autorelease];
        wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        wrapperView.autoresizesSubviews = YES;
        [self.scrollView addSubview:wrapperView];
        
        // Add the view controller's view to the wrapper (sets size properly so that autoresizing occurs): extremely
        // important!!
        viewController.view.frame = wrapperView.bounds;
        [wrapperView addSubview:viewController.view];
    }
    
    // Reload it if it supports the HLSReloadable protocol
    if ([viewController conformsToProtocol:@protocol(HLSReloadable)]) {
        UIViewController<HLSReloadable> *reloadableViewController = viewController;
        [reloadableViewController reloadData];
    }
}

#pragma mark Scrolling programatically

- (void)programmaticallyScrollToCurrentPageAnimated:(BOOL)animated
{
    [self.scrollView scrollRectToVisible:[self frameForPage:self.currentPage] animated:animated];
    m_scrollingProgrammatically = YES;
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    // Refresh current and neighbouring pages
    [self loadPage:self.currentPage];
    [self loadPage:self.currentPage + 1];
    [self loadPage:self.currentPage - 1];
}

#pragma mark Convenience function for retrieving view controllers properly oriented

- (UIViewController *)viewControllerObjectAtIndex:(NSUInteger)index
{
    return [self viewControllerObjectAtIndex:index withOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

#pragma mark HLSContainerControllerLoader protocol implementation

- (NSUInteger)viewControllerCount
{
    // If a loader has been defined, use it
    if (self.loader) {
        return [self.loader viewControllerCount];
    }
    // Else the view controllers have been explicitly set
    else {
        return [self.pageViewControllers count];
    }
}

- (UIViewController *)viewControllerObjectAtIndex:(NSUInteger)index withOrientation:(UIInterfaceOrientation)orientation
{
    // If a loader has been defined, use it
    if (self.loader) {
        // If the view controller array does not exist, create it
        if (! self.pageViewControllers) {
            self.pageViewControllers = [NSMutableArray array];
            // All slots must be available since we do not know which ones will be loaded first
            for (NSUInteger i = 0; i < [self viewControllerCount]; ++i) {
                [self.pageViewControllers addObject:[NSNull null]];
            }
        }
        
        // If view controller not created, create it lazily
        UIViewController *viewController = [self.pageViewControllers objectAtIndex:index];
        if ([viewController isEqual:[NSNull null]]) {
            viewController = [self.loader viewControllerObjectAtIndex:index withOrientation:orientation];
            [self.pageViewControllers replaceObjectAtIndex:index withObject:viewController];
        }
        
        return viewController;
    }
    // Else the view controllers have been explicitly set
    else {
        return [self.pageViewControllers objectAtIndex:index];
    }
}

- (BOOL)allViewControllersShouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // If a loader has been defined, use it (and trust it... We will only know if this orientation is supported
    // when the HLSPageController actually tries to load the containers)
    if (self.loader) {
        return [self.loader allViewControllersShouldAutorotateToInterfaceOrientation:orientation];
    }
    // Else the view controllers have been explicitly set
    else {
        for (UIViewController *viewController in self.pageViewControllers) {
            // No need to test against [NSNull null], cannot happen when all view controllers set at the beginning
            
            // Check if sub view controller can autorotate
            if ([viewController shouldAutorotateToInterfaceOrientation:orientation]) {
                continue;
            }
            
            // Check if the view controller can generate a rotated clone
            if ([viewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
                continue;
            }
            
            // This view controller does not support rotation; cannot rotate the HLSPageController
            return NO;
        }
        
        return YES;
    }
}

#pragma mark UIScrollViewDelegate protocol implementation

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Only if scrolling interactively
    if (! m_scrollingProgrammatically) {
        //Calculate which page index is the most visible one, and make it the current page
        CGFloat pageWidth = self.scrollView.frame.size.width;
        NSInteger mostVisiblePage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.currentPage = mostVisiblePage;    
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Whether or not we were scrolling programmatically, we sure aren't anymore
    m_scrollingProgrammatically = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Whether or not we were scrolling programmatically, we sure aren't anymore
    m_scrollingProgrammatically = NO;
}

#pragma mark Events

- (void)pageControlValueChanged:(id)sender
{
    // Check in which direction the click occured
    if (self.pageControl.currentPage > m_pageControlPreviousPage) {
        ++self.currentPage;
    }
    else {
        --self.currentPage;
    }
    
    [self programmaticallyScrollToCurrentPageAnimated:YES];
}

#pragma mark Notification callbacks

- (void)statusBarFrameChanged:(NSNotification *)notification
{
    [self updateDimensions];
}

@end
