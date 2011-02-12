//
//  ParallelProcessingDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "ParallelProcessingDemoViewController.h"

#import "SleepTask.h"

@interface ParallelProcessingDemoViewController ()

- (void)releaseViews;

- (void)taskStartButtonClicked:(id)sender;
- (void)taskStopButtonClicked:(id)sender;

@end

@implementation ParallelProcessingDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.title = NSLocalizedString(@"Parallel processing", @"Parallel processing");
    }
    return self;
}

- (void)dealloc
{
    // Just to be sure we do not let a dying object listen to task events; this would not be needed here since
    // this is also done when the view disappears, but it is still a good practice
    [[HLSTaskManager defaultManager] cancelTasksWithDelegate:self];
    
    [self releaseViews];
    [super dealloc];
}

- (void)releaseViews
{
    self.taskLabel = nil;
    self.taskStartButton = nil;
    self.taskStopButton = nil;
    self.taskProgressView = nil;
    self.taskRemainingTimeEstimateLabel = nil;
    self.taskRemainingTimeLabel = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.taskLabel.text = NSLocalizedString(@"Task", @"Task");
    self.taskRemainingTimeEstimateLabel.text = NSLocalizedString(@"Remaining time estimate", @"Remaining time estimate");
    
    [self.taskStartButton setTitle:NSLocalizedString(@"Start", @"Start")
                          forState:UIControlStateNormal];
    [self.taskStartButton addTarget:self 
                             action:@selector(taskStartButtonClicked:) 
                   forControlEvents:UIControlEventTouchUpInside];
    
    [self.taskStopButton setTitle:NSLocalizedString(@"Stop", @"Stop")
                         forState:UIControlStateNormal];
    [self.taskStopButton addTarget:self 
                            action:@selector(taskStopButtonClicked:) 
                  forControlEvents:UIControlEventTouchUpInside];
    self.taskStopButton.hidden = YES;
    
    self.taskProgressView.hidden = YES;
    self.taskRemainingTimeEstimateLabel.hidden = YES;
    self.taskRemainingTimeLabel.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // We do not want to let tasks run when we leave the screen
    [[HLSTaskManager defaultManager] cancelTasksWithDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViews];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Accessors and mutators

@synthesize taskLabel = m_taskLabel;

@synthesize taskStartButton = m_taskStartButton;

@synthesize taskStopButton = m_taskStopButton;

@synthesize taskProgressView = m_taskProgressView;

@synthesize taskRemainingTimeEstimateLabel = m_taskRemainingTimeEstimateLabel;

@synthesize taskRemainingTimeLabel = m_taskRemainingTimeLabel;

#pragma mark HLSTaskDelegate protocol implementation

- (void)taskHasStartedProcessing:(HLSTask *)task
{
    if ([task.tag isEqual:@"T_task"]) {
        self.taskProgressView.hidden = NO;
        self.taskRemainingTimeEstimateLabel.hidden = NO;
        self.taskRemainingTimeLabel.hidden = NO;

        self.taskProgressView.progress = task.progress;
        self.taskRemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
}

- (void)taskProgressUpdated:(HLSTask *)task
{
    if ([task.tag isEqual:@"T_task"]) {
        self.taskProgressView.progress = task.progress;
        self.taskRemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
}

- (void)taskHasBeenProcessed:(HLSTask *)task
{
    if ([task.tag isEqual:@"T_task"]) {
        // Failure?
        if ([task error]) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                 message:NSLocalizedString(@"Houston, we've got a problem", @"Houston, we've got a problem")
                                                                delegate:nil 
                                                       cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
                                                       otherButtonTitles:nil]
                                      autorelease];
            [alertView show];
        
        }
        self.taskProgressView.hidden = YES;
        self.taskRemainingTimeEstimateLabel.hidden = YES;
        self.taskRemainingTimeLabel.hidden = YES;
        self.taskStartButton.hidden = NO;
        self.taskStopButton.hidden = YES;
    }    
}

- (void)taskHasBeenCancelled:(HLSTask *)task

{
    if ([task.tag isEqual:@"T_task"]) {
        self.taskProgressView.hidden = YES;
        self.taskRemainingTimeEstimateLabel.hidden = YES;
        self.taskRemainingTimeLabel.hidden = YES;        
        self.taskStartButton.hidden = NO;
        self.taskStopButton.hidden = YES;
    }
}

#pragma mark Event callbacks

- (void)taskStartButtonClicked:(id)sender
{
    self.taskStartButton.hidden = YES;
    self.taskStopButton.hidden = NO;
    
    SleepTask *sleepTask = [[[SleepTask alloc] initWithSecondsToSleep:10] autorelease];
    sleepTask.tag = @"T_task";
    [[HLSTaskManager defaultManager] registerDelegate:self forTask:sleepTask];
    [[HLSTaskManager defaultManager] submitTask:sleepTask];
}

- (void)taskStopButtonClicked:(id)sender
{
    [[HLSTaskManager defaultManager] cancelTasksWithTag:@"T_task"];
}
      
      // TODO: Also play with dependencies!

@end
