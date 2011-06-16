//
//  CursorDemoViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 10.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Designated initializer: init
 */
@interface CursorDemoViewController : HLSViewController <HLSCursorDataSource, HLSCursorDelegate> {
@private
    HLSCursor *m_weekDaysCursor;
    UIButton *m_moveWeekDaysPointerButton;
    UILabel *m_weekDayIndexLabel;
    HLSCursor *m_monthDaysCursor;
}

@property (nonatomic, retain) IBOutlet HLSCursor *weekDaysCursor;
@property (nonatomic, retain) IBOutlet UIButton *moveWeekDaysPointerButton;
@property (nonatomic, retain) IBOutlet UILabel *weekDayIndexLabel;
@property (nonatomic, retain) IBOutlet HLSCursor *monthDaysCursor;

- (IBAction)moveWeekDaysPointerToNextDay;

@end
