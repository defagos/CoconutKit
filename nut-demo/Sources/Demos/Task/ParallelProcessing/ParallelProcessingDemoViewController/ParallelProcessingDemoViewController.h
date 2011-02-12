//
//  ParallelProcessingDemoViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface ParallelProcessingDemoViewController : UIViewController <HLSTaskDelegate, HLSTaskGroupDelegate> {
@private
    UILabel *m_taskLabel;
    UIButton *m_taskStartButton;
    UIButton *m_taskStopButton;
    UIProgressView *m_taskProgressView;
    UILabel *m_taskRemainingTimeEstimateLabel;
    UILabel *m_taskRemainingTimeLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *taskLabel;
@property (nonatomic, retain) IBOutlet UIButton *taskStartButton;
@property (nonatomic, retain) IBOutlet UIButton *taskStopButton;
@property (nonatomic, retain) IBOutlet UIProgressView *taskProgressView;
@property (nonatomic, retain) IBOutlet UILabel *taskRemainingTimeEstimateLabel;
@property (nonatomic, retain) IBOutlet UILabel *taskRemainingTimeLabel;

@end
