//
//  HLSPageController.h
//  Paging
//
//  Created by Samuel Défago on 7/22/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSContainerControllerLoader.h"
#import "HLSReloadable.h"

#define PAGE_CONTROLLER_NO_PAGE         -1

// Forward declarations
@protocol HLSPageControllerDelegate;

/**
 * Remark: The interface is similar to the one of UITabBarController. But since the number of pages can often be quite large 
 * (which is rarely the case with a tab bar controller), this class makes optionally use of the HLSContainerControllerLoader 
 * protocol:
 *   - if the number of view controllers to display is small and they can be created fast, then simply set the
 *     view controllers to display directly using setViewControllers
 *   - if the number of view controlllers to display is large and / or they are slow to create, then create a
 *     view controller loader by implementing the HLSContainerControllerLoader protocol and setting it as loader
 * The behavior is undefined if you attempt to do both.
 *
 * Designated initializer: init:
 */
@interface HLSPageController : UIViewController <HLSContainerControllerLoader, UIScrollViewDelegate, HLSReloadable> {
@private
    NSInteger m_currentPage;
    NSInteger m_initialPage;
    UIView *m_backgroundView;
    UIScrollView *m_scrollView;
    UIPageControl *m_pageControl;
    NSMutableArray *m_pageViewControllers;             // contains UIViewController objects (with proper orientation)
    BOOL m_scrollingProgrammatically;
    NSInteger m_pageControlPreviousPage;
    BOOL m_maximizedPortrait;
    BOOL m_maximizedLandscape;
    BOOL m_firstAppearance;
    CGFloat m_pageControlHeight;
    id<HLSPageControllerDelegate> m_delegate;
    id<HLSContainerControllerLoader> m_loader;
}

- (id)init;

- (void)setInitialPage:(NSInteger)initialPage;

/**
 * Setting the height of the page control. Currently this has to be done before the view is loaded (ideally after HLSPageController
 * creation). If you need to be able to change the height of the page control after the view has been loaded, ask and it might
 * be implemented :-)
 */
- (void)setPageControlHeight:(CGFloat)height;

/**
 * If you are using the loader approach, those view controllers which have not been loaded will be [NSNull null].
 */
- (NSArray *)viewControllers;

/**
 * Retains the view controllers inside the array. Do not set all view controllers at once if their number
 * large, set a loader instead
 */
- (void)setViewControllers:(NSArray *)viewControllers;

/**
 * Return the current page index (starting at 0), or PAGE_CONTROLLER_NO_PAGE if none (should in general not
 * happen except if called before the page controller has been displayed)
 */
@property (nonatomic, readonly, assign) NSInteger currentPage;

/**
 * Only use this accessor for skinning purposes
 */
@property (nonatomic, readonly, retain) UIView *backgroundView;

/**
 * Only use this accessor for skinning purposes
 */
@property (nonatomic, readonly, retain) UIScrollView *scrollView;

/**
 * Only use this accessor for page control skinning purposes. Especially do not alter the UIPageControl
 * currentPage property, which would lead to undefined behavior
 */
@property (nonatomic, readonly, retain) UIPageControl *pageControl;

/**
 * View controller loader to be set if the number of view controllers to display is large.
 */
@property (nonatomic, assign) id<HLSContainerControllerLoader> loader;

/**
 * Set these properties to TRUE to maximize the page controller size for the specified layout
 */
// TODO: Still buggy (does not work for initial orientation; in general portrait)
@property (nonatomic, assign, getter=isMaximizedPortrait) BOOL maximizedPortrait;
@property (nonatomic, assign, getter=isMaximizedLandscape) BOOL maximizedLandscape;

@property (nonatomic, assign) id<HLSPageControllerDelegate> delegate;

@end

@protocol HLSPageControllerDelegate <NSObject>

- (void)pageController:(HLSPageController *)pageController movedToPage:(NSUInteger)page;

@end

