//
//  HLSViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewController.h"

#import "HLSConverters.h"
#import "HLSLogger.h"

@interface HLSViewController ()

- (void)initialize;

@end

@implementation HLSViewController

#pragma mark Object creation and destruction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}

// Common initialization code
- (void)initialize
{
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseInitialized;
    HLSLoggerDebug(@"View controller %@ initialized", self);
}

- (void)dealloc
{
    HLSLoggerDebug(@"View controller %@ deallocated", self);
    [self releaseViews];
    [super dealloc];
}

- (void)releaseViews
{
    HLSLoggerDebug(@"Views released for view controller %@", self);
}

#pragma mark Accessors and mutators

- (void)setView:(UIView *)view
{
    [super setView:view];
    if (! view) {
        HLSLoggerDebug(@"View controller %@: view set to nil", self);
    }
}

- (HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    return m_lifeCyclePhase;
}

- (BOOL)isViewVisible
{
    return m_lifeCyclePhase == HLSViewControllerLifeCyclePhaseViewDidAppear;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidLoad;
    HLSLoggerDebug(@"View controller %@: view did load", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewWillAppear;
    HLSLoggerDebug(@"View controller %@: view will appear", self);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidAppear;
    HLSLoggerDebug(@"View controller %@: view did appear", self);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewWillDisappear;
    HLSLoggerDebug(@"View controller %@: view will disappear", self);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidDisappear;
    HLSLoggerDebug(@"View controller %@: view did disappear", self);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViews];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidUnload;
    HLSLoggerDebug(@"View controller %@: view did unload", self);
}

#pragma mark View management

/**
 * Remark: We have NOT overridden the view property to perform the viewDidUnload, and on purpose. This would have been
 *         very convenient, but this would have been unusual and in most cases the viewDidUnload would have
 *         been sent twice (when a container controller nils a view it manages, it is likely it will set the view
 *         to nil and send it the viewDidUnload afterwards. If all view controller containers of the world knew
 *         about HLSViewController, this would work, but since they don't this would lead to viewDidUnload be
 *         called twice in most cases)! 
 */
- (void)unloadViews
{
    if ([self isViewLoaded]) {
        self.view = nil;
        [self viewDidUnload];        
    }
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // This fixes an inconsistency of UIViewController, see HLSViewController.h documentation
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    HLSLoggerDebug(@"View controller %@ will rotate to interface orientation %@", self, HLSStringFromInterfaceOrientation(toInterfaceOrientation));
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

@end
