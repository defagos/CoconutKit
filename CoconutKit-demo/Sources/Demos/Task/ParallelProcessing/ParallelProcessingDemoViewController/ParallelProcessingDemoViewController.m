//
//  ParallelProcessingDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "ParallelProcessingDemoViewController.h"

#import "SleepTask.h"

// Remark:
// Please apologize for the copy-paste code, but this is a sample and this was the fastest option. Your production
// code should always be more cleverly written

@interface ParallelProcessingDemoViewController ()

- (void)taskStartButtonClicked:(id)sender;
- (void)taskStopButtonClicked:(id)sender;

- (void)taskGroupStartButtonClicked:(id)sender;
- (void)taskGroupStopButtonClicked:(id)sender;

- (void)subTask1StopButtonClicked:(id)sender;
- (void)subTask2StopButtonClicked:(id)sender;
- (void)subTask3StopButtonClicked:(id)sender;

@end

@implementation ParallelProcessingDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Parallel processing", @"Parallel processing");
    }
    return self;
}

- (void)dealloc
{
    // Just to be sure we do not let a dying object listen to task events; this would not be needed here since
    // this is also done when the view disappears, but it is still a good practice
    [[HLSTaskManager defaultManager] cancelTasksWithDelegate:self];
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.taskLabel = nil;
    self.taskStartButton = nil;
    self.taskStopButton = nil;
    self.taskProgressView = nil;
    self.taskRemainingTimeEstimateLabel = nil;
    self.taskRemainingTimeLabel = nil;
    
    self.taskGroupLabel = nil;
    self.taskGroupStartButton = nil;
    self.taskGroupStopButton = nil;
    self.taskGroupProgressView = nil;
    self.taskGroupRemainingTimeEstimateLabel = nil;
    self.taskGroupRemainingTimeLabel = nil;
    
    self.subTasksLabel = nil;
    
    self.subTask1StopButton = nil;
    self.subTask1ProgressView = nil;
    self.subTask1RemainingTimeEstimateLabel = nil;
    self.subTask1RemainingTimeLabel = nil;
    
    self.subTask2StopButton = nil;
    self.subTask2ProgressView = nil;
    self.subTask2RemainingTimeEstimateLabel = nil;
    self.subTask2RemainingTimeLabel = nil;
    
    self.subTask3StopButton = nil;
    self.subTask3ProgressView = nil;
    self.subTask3RemainingTimeEstimateLabel = nil;
    self.subTask3RemainingTimeLabel = nil;    
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Task
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
    
    // Task group
    self.taskGroupLabel.text = NSLocalizedString(@"Task group", @"Task group");
    self.taskGroupRemainingTimeEstimateLabel.text = NSLocalizedString(@"Remaining time estimate", @"Remaining time estimate");
    
    [self.taskGroupStartButton setTitle:NSLocalizedString(@"Start", @"Start")
                               forState:UIControlStateNormal];
    [self.taskGroupStartButton addTarget:self 
                                  action:@selector(taskGroupStartButtonClicked:) 
                        forControlEvents:UIControlEventTouchUpInside];
    
    [self.taskGroupStopButton setTitle:NSLocalizedString(@"Stop", @"Stop")
                              forState:UIControlStateNormal];
    [self.taskGroupStopButton addTarget:self 
                                 action:@selector(taskGroupStopButtonClicked:) 
                       forControlEvents:UIControlEventTouchUpInside];
    self.taskGroupStopButton.hidden = YES;
    
    self.taskGroupProgressView.hidden = YES;
    self.taskGroupRemainingTimeEstimateLabel.hidden = YES;
    self.taskGroupRemainingTimeLabel.hidden = YES;
    
    // Sub-tasks
    self.subTasksLabel.text = NSLocalizedString(@"Sub-tasks", @"Sub-tasks");
    
    // Sub-task 1
    self.subTask1RemainingTimeEstimateLabel.text = NSLocalizedString(@"Remaining time estimate", @"Remaining time estimate");
    
    [self.subTask1StopButton setTitle:NSLocalizedString(@"Stop", @"Stop")
                             forState:UIControlStateNormal];
    [self.subTask1StopButton addTarget:self 
                                action:@selector(subTask1StopButtonClicked:) 
                      forControlEvents:UIControlEventTouchUpInside];
    self.subTask1StopButton.hidden = YES;
    
    self.subTask1ProgressView.hidden = YES;
    self.subTask1RemainingTimeEstimateLabel.hidden = YES;
    self.subTask1RemainingTimeLabel.hidden = YES;
    
    // Sub-task 2
    self.subTask2RemainingTimeEstimateLabel.text = NSLocalizedString(@"Remaining time estimate", @"Remaining time estimate");
    
    [self.subTask2StopButton setTitle:NSLocalizedString(@"Stop", @"Stop")
                             forState:UIControlStateNormal];
    [self.subTask2StopButton addTarget:self 
                                action:@selector(subTask2StopButtonClicked:) 
                      forControlEvents:UIControlEventTouchUpInside];
    self.subTask2StopButton.hidden = YES;
    
    self.subTask2ProgressView.hidden = YES;
    self.subTask2RemainingTimeEstimateLabel.hidden = YES;
    self.subTask2RemainingTimeLabel.hidden = YES;
    
    // Sub-task 3
    self.subTask3RemainingTimeEstimateLabel.text = NSLocalizedString(@"Remaining time estimate", @"Remaining time estimate");
    
    [self.subTask3StopButton setTitle:NSLocalizedString(@"Stop", @"Stop")
                             forState:UIControlStateNormal];
    [self.subTask3StopButton addTarget:self 
                                action:@selector(subTask3StopButtonClicked:) 
                      forControlEvents:UIControlEventTouchUpInside];
    self.subTask3StopButton.hidden = YES;
    
    self.subTask3ProgressView.hidden = YES;
    self.subTask3RemainingTimeEstimateLabel.hidden = YES;
    self.subTask3RemainingTimeLabel.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // We do not want to let tasks run when we leave the screen
    [[HLSTaskManager defaultManager] cancelTasksWithDelegate:self];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Accessors and mutators

@synthesize taskLabel = m_taskLabel;

@synthesize taskStartButton = m_taskStartButton;

@synthesize taskStopButton = m_taskStopButton;

@synthesize taskProgressView = m_taskProgressView;

@synthesize taskRemainingTimeEstimateLabel = m_taskRemainingTimeEstimateLabel;

@synthesize taskRemainingTimeLabel = m_taskRemainingTimeLabel;

@synthesize taskGroupLabel = m_taskGroupLabel;

@synthesize taskGroupStartButton = m_taskGroupStartButton;

@synthesize taskGroupStopButton = m_taskGroupStopButton;

@synthesize taskGroupProgressView = m_taskGroupProgressView;

@synthesize taskGroupRemainingTimeEstimateLabel = m_taskGroupRemainingTimeEstimateLabel;

@synthesize taskGroupRemainingTimeLabel = m_taskGroupRemainingTimeLabel;

@synthesize subTasksLabel = m_subTasksLabel;

@synthesize subTask1StopButton = m_subTask1StopButton;

@synthesize subTask1ProgressView = m_subTask1ProgressView;

@synthesize subTask1RemainingTimeEstimateLabel = m_subTask1RemainingTimeEstimateLabel;

@synthesize subTask1RemainingTimeLabel = m_subTask1RemainingTimeLabel;

@synthesize subTask2StopButton = m_subTask2StopButton;

@synthesize subTask2ProgressView = m_subTask2ProgressView;

@synthesize subTask2RemainingTimeEstimateLabel = m_subTask2RemainingTimeEstimateLabel;

@synthesize subTask2RemainingTimeLabel = m_subTask2RemainingTimeLabel;

@synthesize subTask3StopButton = m_subTask3StopButton;

@synthesize subTask3ProgressView = m_subTask3ProgressView;

@synthesize subTask3RemainingTimeEstimateLabel = m_subTask3RemainingTimeEstimateLabel;

@synthesize subTask3RemainingTimeLabel = m_subTask3RemainingTimeLabel;

#pragma mark HLSTaskDelegate protocol implementation

- (void)taskHasStartedProcessing:(HLSTask *)task
{
    if ([task.tag isEqual:@"T_task"]) {
        self.taskStopButton.hidden = NO;
        self.taskProgressView.hidden = NO;
        self.taskRemainingTimeEstimateLabel.hidden = NO;
        self.taskRemainingTimeLabel.hidden = NO;
        
        self.taskProgressView.progress = task.progress;
        self.taskRemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqual:@"T_subTask1"]) {
        self.subTask1StopButton.hidden = NO;
        self.subTask1ProgressView.hidden = NO;
        self.subTask1RemainingTimeEstimateLabel.hidden = NO;
        self.subTask1RemainingTimeLabel.hidden = NO;
        
        self.subTask1ProgressView.progress = task.progress;
        self.subTask1RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqual:@"T_subTask2"]) {
        self.subTask2StopButton.hidden = NO;
        self.subTask2ProgressView.hidden = NO;
        self.subTask2RemainingTimeEstimateLabel.hidden = NO;
        self.subTask2RemainingTimeLabel.hidden = NO;
        
        self.subTask2ProgressView.progress = task.progress;
        self.subTask2RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqual:@"T_subTask3"]) {
        self.subTask3StopButton.hidden = NO;
        self.subTask3ProgressView.hidden = NO;
        self.subTask3RemainingTimeEstimateLabel.hidden = NO;
        self.subTask3RemainingTimeLabel.hidden = NO;
        
        self.subTask3ProgressView.progress = task.progress;
        self.subTask3RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
}

- (void)taskProgressUpdated:(HLSTask *)task
{
    if ([task.tag isEqual:@"T_task"]) {
        self.taskProgressView.progress = task.progress;
        self.taskRemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqual:@"T_subTask1"]) {
        self.subTask1ProgressView.progress = task.progress;
        self.subTask1RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqual:@"T_subTask2"]) {
        self.subTask2ProgressView.progress = task.progress;
        self.subTask2RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqual:@"T_subTask3"]) {
        self.subTask3ProgressView.progress = task.progress;
        self.subTask3RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
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
    else if ([task.tag isEqual:@"T_subTask1"]) {
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
        self.subTask1ProgressView.hidden = YES;
        self.subTask1RemainingTimeEstimateLabel.hidden = YES;
        self.subTask1RemainingTimeLabel.hidden = YES;
        self.subTask1StopButton.hidden = YES;
    } 
    else if ([task.tag isEqual:@"T_subTask2"]) {
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
        self.subTask2ProgressView.hidden = YES;
        self.subTask2RemainingTimeEstimateLabel.hidden = YES;
        self.subTask2RemainingTimeLabel.hidden = YES;
        self.subTask2StopButton.hidden = YES;
    }
    else if ([task.tag isEqual:@"T_subTask3"]) {
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
        self.subTask3ProgressView.hidden = YES;
        self.subTask3RemainingTimeEstimateLabel.hidden = YES;
        self.subTask3RemainingTimeLabel.hidden = YES;
        self.subTask3StopButton.hidden = YES;
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
    else if ([task.tag isEqual:@"T_subTask1"]) {
        self.subTask1ProgressView.hidden = YES;
        self.subTask1RemainingTimeEstimateLabel.hidden = YES;
        self.subTask1RemainingTimeLabel.hidden = YES;        
        self.subTask1StopButton.hidden = YES;
    }
    else if ([task.tag isEqual:@"T_subTask2"]) {
        self.subTask2ProgressView.hidden = YES;
        self.subTask2RemainingTimeEstimateLabel.hidden = YES;
        self.subTask2RemainingTimeLabel.hidden = YES;        
        self.subTask2StopButton.hidden = YES;
    }
    else if ([task.tag isEqual:@"T_subTask3"]) {
        self.subTask3ProgressView.hidden = YES;
        self.subTask3RemainingTimeEstimateLabel.hidden = YES;
        self.subTask3RemainingTimeLabel.hidden = YES;        
        self.subTask3StopButton.hidden = YES;
    }
}

#pragma mark TaskGroupDelegate protocol implementation

- (void)taskGroupHasStartedProcessing:(HLSTaskGroup *)taskGroup
{
    if ([taskGroup.tag isEqual:@"TG_taskGroup"]) {
        self.taskGroupProgressView.hidden = NO;
        self.taskGroupStopButton.hidden = NO;
        self.taskGroupRemainingTimeEstimateLabel.hidden = NO;
        self.taskGroupRemainingTimeLabel.hidden = NO;
        
        self.taskGroupProgressView.progress = taskGroup.progress;
        self.taskGroupRemainingTimeLabel.text = [taskGroup remainingTimeIntervalEstimateLocalizedString];
    }
}

- (void)taskGroupProgressUpdated:(HLSTaskGroup *)taskGroup
{
    if ([taskGroup.tag isEqual:@"TG_taskGroup"]) {
        self.taskGroupProgressView.progress = taskGroup.progress;
        self.taskGroupRemainingTimeLabel.text = [taskGroup remainingTimeIntervalEstimateLocalizedString];
    }
}

- (void)taskGroupHasBeenProcessed:(HLSTaskGroup *)taskGroup
{
    if ([taskGroup.tag isEqual:@"TG_taskGroup"]) {
        // Failures could be tested here using [taskGroup nbrFailures]. This is not made here since we already
        // manage failures at the task level
        
        self.taskGroupProgressView.hidden = YES;
        self.taskGroupRemainingTimeEstimateLabel.hidden = YES;
        self.taskGroupRemainingTimeLabel.hidden = YES;
        self.taskGroupStartButton.hidden = NO;
        self.taskGroupStopButton.hidden = YES;
    } 
}

- (void)taskGroupHasBeenCancelled:(HLSTaskGroup *)taskGroup
{
    if ([taskGroup.tag isEqual:@"TG_taskGroup"]) {
        self.taskGroupProgressView.hidden = YES;
        self.taskGroupRemainingTimeEstimateLabel.hidden = YES;
        self.taskGroupRemainingTimeLabel.hidden = YES;        
        self.taskGroupStartButton.hidden = NO;
        self.taskGroupStopButton.hidden = YES;
    }
}

#pragma mark Event callbacks

- (void)taskStartButtonClicked:(id)sender
{
    self.taskStartButton.hidden = YES;
    
    SleepTask *sleepTask = [[[SleepTask alloc] initWithSecondsToSleep:10] autorelease];
    sleepTask.tag = @"T_task";
    [[HLSTaskManager defaultManager] registerDelegate:self forTask:sleepTask];
    [[HLSTaskManager defaultManager] submitTask:sleepTask];
}

- (void)taskStopButtonClicked:(id)sender
{
    self.taskStopButton.hidden = YES;
    
    [[HLSTaskManager defaultManager] cancelTasksWithTag:@"T_task"];
}

- (void)taskGroupStartButtonClicked:(id)sender
{
    self.taskGroupStartButton.hidden = YES;
    
    SleepTask *sleepSubTask1 = [[[SleepTask alloc] initWithSecondsToSleep:5] autorelease];
    sleepSubTask1.tag = @"T_subTask1";
    [[HLSTaskManager defaultManager] registerDelegate:self forTask:sleepSubTask1];
    
    SleepTask *sleepSubTask2 = [[[SleepTask alloc] initWithSecondsToSleep:10] autorelease];
    sleepSubTask2.tag = @"T_subTask2";
    [[HLSTaskManager defaultManager] registerDelegate:self forTask:sleepSubTask2];
    
    // Tasks during more than 20 seconds fail (see SleepTaskOperation.m), allowing us to simulate... well... failures
    SleepTask *sleepSubTask3 = [[[SleepTask alloc] initWithSecondsToSleep:25] autorelease];
    sleepSubTask3.tag = @"T_subTask3";
    [[HLSTaskManager defaultManager] registerDelegate:self forTask:sleepSubTask3];
    
    HLSTaskGroup *taskGroup = [[[HLSTaskGroup alloc] init] autorelease];
    taskGroup.tag = @"TG_taskGroup";
    [taskGroup addTask:sleepSubTask1];
    [taskGroup addTask:sleepSubTask2];
    [taskGroup addTask:sleepSubTask3];
    [[HLSTaskManager defaultManager] registerDelegate:self forTaskGroup:taskGroup];
    
    // Task 2 will only start after task 1 is complete and successful
    [taskGroup addDependencyForTask:sleepSubTask2 onTask:sleepSubTask1 strong:YES];
    
    [[HLSTaskManager defaultManager] submitTaskGroup:taskGroup];
}

- (void)taskGroupStopButtonClicked:(id)sender
{
    self.taskGroupStopButton.hidden = YES;
    
    [[HLSTaskManager defaultManager] cancelTaskGroupsWithTag:@"TG_taskGroup"];
}

- (void)subTask1StopButtonClicked:(id)sender
{
    self.subTask1StopButton.hidden = YES;
    
    [[HLSTaskManager defaultManager] cancelTasksWithTag:@"T_subTask1"];
}

- (void)subTask2StopButtonClicked:(id)sender
{
    self.subTask2StopButton.hidden = YES;
    
    [[HLSTaskManager defaultManager] cancelTasksWithTag:@"T_subTask2"];    
}

- (void)subTask3StopButtonClicked:(id)sender
{
    self.subTask3StopButton.hidden = YES;
    
    [[HLSTaskManager defaultManager] cancelTasksWithTag:@"T_subTask3"];    
}

@end
