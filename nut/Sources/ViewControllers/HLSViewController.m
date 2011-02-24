//
//  HLSViewController.m
//  nut
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewController.h"

@implementation HLSViewController

#pragma mark Object creation and destruction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseInitialized;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseInitialized;
    }
    return self;
}

- (void)dealloc
{
    [self releaseViews];
    [super dealloc];
}

- (void)releaseViews
{
}

#pragma mark Accessors and mutators

- (HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    return m_lifeCyclePhase;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidLoad;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewWillAppear;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidAppear;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewWillDisappear;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidDisappear;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViews];
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidUnload;
}

#pragma mark View management

/**
 * Remark: We have NOT overridden the view property to perform the viewDidUnload, and on purpose. This would have been
 *         very convenient, but this would have been unusual and in most cases the viewDidUnload would have
 *         been sent twice (when a container controller nils a view it manages, it is likely it will set the view
 *         to nil and send it the viewDidUnload afterwards. If all view controller containers of the world knew
 *         about HLSViewController, this would work, but since they don't this would lead to viewDidUnload be
 *         called twice in most cases)! */
- (void)unloadView
{
    self.view = nil;
    [self viewDidUnload];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // This fixes an inconsistency of UIViewController, see HLSViewController.h documentation
    return YES;
}

@end
