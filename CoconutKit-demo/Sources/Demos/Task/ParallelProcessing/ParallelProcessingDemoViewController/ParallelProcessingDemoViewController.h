//
//  ParallelProcessingDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface ParallelProcessingDemoViewController : HLSViewController <HLSTaskDelegate, HLSTaskGroupDelegate> {
@private
    UILabel *m_taskLabel;
    UIButton *m_taskStartButton;
    UIButton *m_taskStopButton;
    UIProgressView *m_taskProgressView;
    UILabel *m_taskRemainingTimeEstimateLabel;
    UILabel *m_taskRemainingTimeLabel;
    
    UILabel *m_taskGroupLabel;
    UIButton *m_taskGroupStartButton;
    UIButton *m_taskGroupStopButton;
    UIProgressView *m_taskGroupProgressView;
    UILabel *m_taskGroupRemainingTimeEstimateLabel;
    UILabel *m_taskGroupRemainingTimeLabel;
    
    UILabel *m_subTasksLabel;
    
    UIButton *m_subTask1StopButton;
    UIProgressView *m_subTask1ProgressView;
    UILabel *m_subTask1RemainingTimeEstimateLabel;
    UILabel *m_subTask1RemainingTimeLabel;
    
    UIButton *m_subTask2StopButton;
    UIProgressView *m_subTask2ProgressView;
    UILabel *m_subTask2RemainingTimeEstimateLabel;
    UILabel *m_subTask2RemainingTimeLabel;

    UIButton *m_subTask3StopButton;
    UIProgressView *m_subTask3ProgressView;
    UILabel *m_subTask3RemainingTimeEstimateLabel;
    UILabel *m_subTask3RemainingTimeLabel;    
}

@property (nonatomic, retain) IBOutlet UILabel *taskLabel;
@property (nonatomic, retain) IBOutlet UIButton *taskStartButton;
@property (nonatomic, retain) IBOutlet UIButton *taskStopButton;
@property (nonatomic, retain) IBOutlet UIProgressView *taskProgressView;
@property (nonatomic, retain) IBOutlet UILabel *taskRemainingTimeEstimateLabel;
@property (nonatomic, retain) IBOutlet UILabel *taskRemainingTimeLabel;

@property (nonatomic, retain) IBOutlet UILabel *taskGroupLabel;
@property (nonatomic, retain) IBOutlet UIButton *taskGroupStartButton;
@property (nonatomic, retain) IBOutlet UIButton *taskGroupStopButton;
@property (nonatomic, retain) IBOutlet UIProgressView *taskGroupProgressView;
@property (nonatomic, retain) IBOutlet UILabel *taskGroupRemainingTimeEstimateLabel;
@property (nonatomic, retain) IBOutlet UILabel *taskGroupRemainingTimeLabel;

@property (nonatomic, retain) IBOutlet UILabel *subTasksLabel;

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

@end
