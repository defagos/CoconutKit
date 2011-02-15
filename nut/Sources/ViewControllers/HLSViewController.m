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

#pragma mark Accessors and mutators

- (HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    return m_lifeCyclePhase;
}

@end
