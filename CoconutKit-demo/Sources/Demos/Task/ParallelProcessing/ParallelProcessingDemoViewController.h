//
//  ParallelProcessingDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface ParallelProcessingDemoViewController : HLSViewController <HLSTaskDelegate, HLSTaskGroupDelegate>

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
