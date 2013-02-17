//
//  ParallelProcessingDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "ParallelProcessingDemoViewController.h"

#import "SleepTask.h"

@interface ParallelProcessingDemoViewController ()

@property (nonatomic, retain) IBOutlet UIButton *taskStartButton;
@property (nonatomic, retain) IBOutlet UIButton *taskStopButton;
@property (nonatomic, retain) IBOutlet UIProgressView *taskProgressView;
@property (nonatomic, retain) IBOutlet UILabel *taskRemainingTimeEstimateLabel;
@property (nonatomic, retain) IBOutlet UILabel *taskRemainingTimeLabel;

@property (nonatomic, retain) IBOutlet UIButton *taskGroupStartButton;
@property (nonatomic, retain) IBOutlet UIButton *taskGroupStopButton;
@property (nonatomic, retain) IBOutlet UIProgressView *taskGroupProgressView;
@property (nonatomic, retain) IBOutlet UILabel *taskGroupRemainingTimeEstimateLabel;
@property (nonatomic, retain) IBOutlet UILabel *taskGroupRemainingTimeLabel;

@property (nonatomic, retain) IBOutlet UIButton *subTask1StopButton;
@property (nonatomic, retain) IBOutlet UIProgressView *subTask1ProgressView;
@property (nonatomic, retain) IBOutlet UILabel *subTask1RemainingTimeEstimateLabel;
@property (nonatomic, retain) IBOutlet UILabel *subTask1RemainingTimeLabel;

@property (nonatomic, retain) IBOutlet UIButton *subTask2StopButton;
@property (nonatomic, retain) IBOutlet UIProgressView *subTask2ProgressView;
@property (nonatomic, retain) IBOutlet UILabel *subTask2RemainingTimeEstimateLabel;
@property (nonatomic, retain) IBOutlet UILabel *subTask2RemainingTimeLabel;

@property (nonatomic, retain) IBOutlet UIButton *subTask3StopButton;
@property (nonatomic, retain) IBOutlet UIProgressView *subTask3ProgressView;
@property (nonatomic, retain) IBOutlet UILabel *subTask3RemainingTimeEstimateLabel;
@property (nonatomic, retain) IBOutlet UILabel *subTask3RemainingTimeLabel;

- (IBAction)startTask:(id)sender;
- (IBAction)stopTask:(id)sender;

- (IBAction)startTaskGroup:(id)sender;
- (IBAction)stopTaskGroup:(id)sender;

- (IBAction)stopSubTask1:(id)sender;
- (IBAction)stopSubTask2:(id)sender;
- (IBAction)stopSubTask3:(id)sender;

@end

// Remark:
// Please apologize for the copy-paste code, but this is a sample and this was the fastest option. Your production
// code should always be more cleverly written

@implementation ParallelProcessingDemoViewController

#pragma mark Object creation and destruction

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

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark HLSTaskDelegate protocol implementation

- (void)taskHasStartedProcessing:(HLSTask *)task
{
    if ([task.tag isEqualToString:@"T_task"]) {
        self.taskStopButton.hidden = NO;
        self.taskProgressView.hidden = NO;
        self.taskRemainingTimeEstimateLabel.hidden = NO;
        self.taskRemainingTimeLabel.hidden = NO;
        
        self.taskProgressView.progress = task.progress;
        self.taskRemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask1"]) {
        self.subTask1StopButton.hidden = NO;
        self.subTask1ProgressView.hidden = NO;
        self.subTask1RemainingTimeEstimateLabel.hidden = NO;
        self.subTask1RemainingTimeLabel.hidden = NO;
        
        self.subTask1ProgressView.progress = task.progress;
        self.subTask1RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask2"]) {
        self.subTask2StopButton.hidden = NO;
        self.subTask2ProgressView.hidden = NO;
        self.subTask2RemainingTimeEstimateLabel.hidden = NO;
        self.subTask2RemainingTimeLabel.hidden = NO;
        
        self.subTask2ProgressView.progress = task.progress;
        self.subTask2RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask3"]) {
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
    if ([task.tag isEqualToString:@"T_task"]) {
        self.taskProgressView.progress = task.progress;
        self.taskRemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask1"]) {
        self.subTask1ProgressView.progress = task.progress;
        self.subTask1RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask2"]) {
        self.subTask2ProgressView.progress = task.progress;
        self.subTask2RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }
    else if ([task.tag isEqualToString:@"T_subTask3"]) {
        self.subTask3ProgressView.progress = task.progress;
        self.subTask3RemainingTimeLabel.text = [task remainingTimeIntervalEstimateLocalizedString];
    }    
}

- (void)taskHasBeenProcessed:(HLSTask *)task
{
    if ([task.tag isEqualToString:@"T_task"]) {
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
    else if ([task.tag isEqualToString:@"T_subTask1"]) {
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
    else if ([task.tag isEqualToString:@"T_subTask2"]) {
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
    else if ([task.tag isEqualToString:@"T_subTask3"]) {
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

- (void)taskGroupHasStartedProcessing:(HLSTaskGroup *)taskGroup
{
    if ([taskGroup.tag isEqualToString:@"TG_taskGroup"]) {
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
    if ([taskGroup.tag isEqualToString:@"TG_taskGroup"]) {
        self.taskGroupProgressView.progress = taskGroup.progress;
        self.taskGroupRemainingTimeLabel.text = [taskGroup remainingTimeIntervalEstimateLocalizedString];
    }
}

- (void)taskGroupHasBeenProcessed:(HLSTaskGroup *)taskGroup
{
    if ([taskGroup.tag isEqualToString:@"TG_taskGroup"]) {
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
    
    SleepTask *sleepTask = [[[SleepTask alloc] initWithSecondsToSleep:10] autorelease];
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

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Parallel processing", @"Parallel processing");
}

@end
