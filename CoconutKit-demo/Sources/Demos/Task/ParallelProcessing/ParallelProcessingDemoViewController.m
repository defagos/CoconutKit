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

@implementation ParallelProcessingDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
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
    
    self.taskStartButton = nil;
    self.taskStopButton = nil;
    self.taskProgressView = nil;
    self.taskRemainingTimeEstimateLabel = nil;
    self.taskRemainingTimeLabel = nil;
    
    self.taskGroupStartButton = nil;
    self.taskGroupStopButton = nil;
    self.taskGroupProgressView = nil;
    self.taskGroupRemainingTimeEstimateLabel = nil;
    self.taskGroupRemainingTimeLabel = nil;
    
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

#pragma mark Accessors and mutators

@synthesize taskStartButton = m_taskStartButton;

@synthesize taskStopButton = m_taskStopButton;

@synthesize taskProgressView = m_taskProgressView;

@synthesize taskRemainingTimeEstimateLabel = m_taskRemainingTimeEstimateLabel;

@synthesize taskRemainingTimeLabel = m_taskRemainingTimeLabel;

@synthesize taskGroupStartButton = m_taskGroupStartButton;

@synthesize taskGroupStopButton = m_taskGroupStopButton;

@synthesize taskGroupProgressView = m_taskGroupProgressView;

@synthesize taskGroupRemainingTimeEstimateLabel = m_taskGroupRemainingTimeEstimateLabel;

@synthesize taskGroupRemainingTimeLabel = m_taskGroupRemainingTimeLabel;

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

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Task    
    self.taskStopButton.hidden = YES;
    
    self.taskProgressView.hidden = YES;
    self.taskRemainingTimeEstimateLabel.hidden = YES;
    self.taskRemainingTimeLabel.hidden = YES;
    
    // Task group
    self.taskGroupStopButton.hidden = YES;
    
    self.taskGroupProgressView.hidden = YES;
    self.taskGroupRemainingTimeEstimateLabel.hidden = YES;
    self.taskGroupRemainingTimeLabel.hidden = YES;
    
    // Sub-task 1
    self.subTask1StopButton.hidden = YES;
    
    self.subTask1ProgressView.hidden = YES;
    self.subTask1RemainingTimeEstimateLabel.hidden = YES;
    self.subTask1RemainingTimeLabel.hidden = YES;
    
    // Sub-task 2
    self.subTask2StopButton.hidden = YES;
    
    self.subTask2ProgressView.hidden = YES;
    self.subTask2RemainingTimeEstimateLabel.hidden = YES;
    self.subTask2RemainingTimeLabel.hidden = YES;
    
    // Sub-task 3
    self.subTask3StopButton.hidden = YES;
    
    self.subTask3ProgressView.hidden = YES;
    self.subTask3RemainingTimeEstimateLabel.hidden = YES;
    self.subTask3RemainingTimeLabel.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Parallel processing", @"Parallel processing");
}

#pragma mark HLSTaskDelegate protocol implementation

- (void)taskDidStart:(HLSTask *)task
{
    if ([task.tag isEqualToString:@"T_task"]) {
        self.taskStopButton.hidden = NO;
        self.taskProgressView.hidden = NO;
        self.taskRemainingTimeEstimateLabel.hidden = NO;
        self.taskRemainingTimeLabel.hidden = NO;
        
        NSLog(@"%@", [task.progressTrackerInfo description]);
        
        self.taskProgressView.progress = task.progressTrackerInfo.progress;
        self.taskRemainingTimeLabel.text = [task.progressTrackerInfo remainingTimeEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask1"]) {
        self.subTask1StopButton.hidden = NO;
        self.subTask1ProgressView.hidden = NO;
        self.subTask1RemainingTimeEstimateLabel.hidden = NO;
        self.subTask1RemainingTimeLabel.hidden = NO;
        
        self.subTask1ProgressView.progress = task.progressTrackerInfo.progress;
        self.subTask1RemainingTimeLabel.text = [task.progressTrackerInfo remainingTimeEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask2"]) {
        self.subTask2StopButton.hidden = NO;
        self.subTask2ProgressView.hidden = NO;
        self.subTask2RemainingTimeEstimateLabel.hidden = NO;
        self.subTask2RemainingTimeLabel.hidden = NO;
        
        self.subTask2ProgressView.progress = task.progressTrackerInfo.progress;
        self.subTask2RemainingTimeLabel.text = [task.progressTrackerInfo remainingTimeEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask3"]) {
        self.subTask3StopButton.hidden = NO;
        self.subTask3ProgressView.hidden = NO;
        self.subTask3RemainingTimeEstimateLabel.hidden = NO;
        self.subTask3RemainingTimeLabel.hidden = NO;
        
        self.subTask3ProgressView.progress = task.progressTrackerInfo.progress;
        self.subTask3RemainingTimeLabel.text = [task.progressTrackerInfo remainingTimeEstimateLocalizedString];
    }
}

- (void)taskDidProgress:(HLSTask *)task
{
    if ([task.tag isEqualToString:@"T_task"]) {
        self.taskProgressView.progress = task.progressTrackerInfo.progress;
        self.taskRemainingTimeLabel.text = [task.progressTrackerInfo remainingTimeEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask1"]) {
        self.subTask1ProgressView.progress = task.progressTrackerInfo.progress;
        self.subTask1RemainingTimeLabel.text = [task.progressTrackerInfo remainingTimeEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask2"]) {
        self.subTask2ProgressView.progress = task.progressTrackerInfo.progress;
        self.subTask2RemainingTimeLabel.text = [task.progressTrackerInfo remainingTimeEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask3"]) {
        self.subTask3ProgressView.progress = task.progressTrackerInfo.progress;
        self.subTask3RemainingTimeLabel.text = [task.progressTrackerInfo remainingTimeEstimateLocalizedString];
    }    
}

- (void)taskDidFinish:(HLSTask *)task
{
    if ([task.tag isEqualToString:@"T_task"]) {
        self.taskProgressView.hidden = YES;
        self.taskRemainingTimeEstimateLabel.hidden = YES;
        self.taskRemainingTimeLabel.hidden = YES;
        self.taskStartButton.hidden = NO;
        self.taskStopButton.hidden = YES;
    } 
    else if ([task.tag isEqualToString:@"T_subTask1"]) {
        self.subTask1ProgressView.hidden = YES;
        self.subTask1RemainingTimeEstimateLabel.hidden = YES;
        self.subTask1RemainingTimeLabel.hidden = YES;
        self.subTask1StopButton.hidden = YES;
    } 
    else if ([task.tag isEqualToString:@"T_subTask2"]) {
        self.subTask2ProgressView.hidden = YES;
        self.subTask2RemainingTimeEstimateLabel.hidden = YES;
        self.subTask2RemainingTimeLabel.hidden = YES;
        self.subTask2StopButton.hidden = YES;
    }
    else if ([task.tag isEqualToString:@"T_subTask3"]) {
        self.subTask3ProgressView.hidden = YES;
        self.subTask3RemainingTimeEstimateLabel.hidden = YES;
        self.subTask3RemainingTimeLabel.hidden = YES;
        self.subTask3StopButton.hidden = YES;
    }
}

- (void)taskDidCancel:(HLSTask *)task
{
    if ([task.tag isEqualToString:@"T_task"]) {
        self.taskProgressView.hidden = YES;
        self.taskRemainingTimeEstimateLabel.hidden = YES;
        self.taskRemainingTimeLabel.hidden = YES;        
        self.taskStartButton.hidden = NO;
        self.taskStopButton.hidden = YES;
    }
    else if ([task.tag isEqualToString:@"T_subTask1"]) {
        self.subTask1ProgressView.hidden = YES;
        self.subTask1RemainingTimeEstimateLabel.hidden = YES;
        self.subTask1RemainingTimeLabel.hidden = YES;        
        self.subTask1StopButton.hidden = YES;
    }
    else if ([task.tag isEqualToString:@"T_subTask2"]) {
        self.subTask2ProgressView.hidden = YES;
        self.subTask2RemainingTimeEstimateLabel.hidden = YES;
        self.subTask2RemainingTimeLabel.hidden = YES;        
        self.subTask2StopButton.hidden = YES;
    }
    else if ([task.tag isEqualToString:@"T_subTask3"]) {
        self.subTask3ProgressView.hidden = YES;
        self.subTask3RemainingTimeEstimateLabel.hidden = YES;
        self.subTask3RemainingTimeLabel.hidden = YES;        
        self.subTask3StopButton.hidden = YES;
    }
}

#pragma mark TaskGroupDelegate protocol implementation

- (void)taskGroupDidStart:(HLSTaskGroup *)taskGroup
{
    if ([taskGroup.tag isEqualToString:@"TG_taskGroup"]) {
        self.taskGroupProgressView.hidden = NO;
        self.taskGroupStopButton.hidden = NO;
        self.taskGroupRemainingTimeEstimateLabel.hidden = NO;
        self.taskGroupRemainingTimeLabel.hidden = NO;
        
        self.taskGroupProgressView.progress = taskGroup.progressTracker.progress;
        self.taskGroupRemainingTimeLabel.text = [taskGroup.progressTracker remainingTimeEstimateLocalizedString];
    }
}

- (void)taskGroupDidProgress:(HLSTaskGroup *)taskGroup
{
    if ([taskGroup.tag isEqualToString:@"TG_taskGroup"]) {
        self.taskGroupProgressView.progress = taskGroup.progressTracker.progress;
        self.taskGroupRemainingTimeLabel.text = [taskGroup.progressTracker remainingTimeEstimateLocalizedString];
    }
}

- (void)taskGroupDidFinish:(HLSTaskGroup *)taskGroup
{
    if ([taskGroup.tag isEqualToString:@"TG_taskGroup"]) {
        // Failures could be tested here using [taskGroup numberOfFailures]. This is not made here since we already
        // manage failures at the task level
        
        self.taskGroupProgressView.hidden = YES;
        self.taskGroupRemainingTimeEstimateLabel.hidden = YES;
        self.taskGroupRemainingTimeLabel.hidden = YES;
        self.taskGroupStartButton.hidden = NO;
        self.taskGroupStopButton.hidden = YES;
    } 
}

- (void)taskGroupDidCancel:(HLSTaskGroup *)taskGroup
{
    if ([taskGroup.tag isEqualToString:@"TG_taskGroup"]) {
        self.taskGroupProgressView.hidden = YES;
        self.taskGroupRemainingTimeEstimateLabel.hidden = YES;
        self.taskGroupRemainingTimeLabel.hidden = YES;        
        self.taskGroupStartButton.hidden = NO;
        self.taskGroupStopButton.hidden = YES;
    }
}

#pragma mark Event callbacks

- (IBAction)startTask:(id)sender
{
    self.taskStartButton.hidden = YES;
    
    SleepTask *sleepTask = [[[SleepTask alloc] initWithSecondsToSleep:130] autorelease];
    sleepTask.tag = @"T_task";
    [[HLSTaskManager defaultManager] registerDelegate:self forTask:sleepTask];
    [[HLSTaskManager defaultManager] submitTask:sleepTask];
}

- (IBAction)stopTask:(id)sender
{
    self.taskStopButton.hidden = YES;
    
    [[HLSTaskManager defaultManager] cancelTasksWithTag:@"T_task"];
}

- (IBAction)startTaskGroup:(id)sender
{
    self.taskGroupStartButton.hidden = YES;
    
    SleepTask *sleepSubTask1 = [[[SleepTask alloc] initWithSecondsToSleep:10] autorelease];
    sleepSubTask1.tag = @"T_subTask1";
    [[HLSTaskManager defaultManager] registerDelegate:self forTask:sleepSubTask1];
    
    SleepTask *sleepSubTask2 = [[[SleepTask alloc] initWithSecondsToSleep:480] autorelease];
    sleepSubTask2.tag = @"T_subTask2";
    [[HLSTaskManager defaultManager] registerDelegate:self forTask:sleepSubTask2];
    
    SleepTask *sleepSubTask3 = [[[SleepTask alloc] initWithSecondsToSleep:60] autorelease];
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

- (IBAction)stopTaskGroup:(id)sender
{
    self.taskGroupStopButton.hidden = YES;
    
    [[HLSTaskManager defaultManager] cancelTaskGroupsWithTag:@"TG_taskGroup"];
}

- (IBAction)stopSubTask1:(id)sender
{
    self.subTask1StopButton.hidden = YES;
    
    [[HLSTaskManager defaultManager] cancelTasksWithTag:@"T_subTask1"];
}

- (IBAction)stopSubTask2:(id)sender
{
    self.subTask2StopButton.hidden = YES;
    
    [[HLSTaskManager defaultManager] cancelTasksWithTag:@"T_subTask2"];    
}

- (IBAction)stopSubTask3:(id)sender
{
    self.subTask3StopButton.hidden = YES;
    
    [[HLSTaskManager defaultManager] cancelTasksWithTag:@"T_subTask3"];    
}

@end
