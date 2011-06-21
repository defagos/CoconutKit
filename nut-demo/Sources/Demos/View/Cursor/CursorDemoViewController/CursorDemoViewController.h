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
    UILabel *m_weekDayIndexLabel;
    UIButton *m_nextWeekDayButton;
    HLSCursor *m_randomRangeCursor;
    UILabel *m_randomRangeIndexLabel;
    UIButton *m_randomRangeCursorReloadButton;
    HLSCursor *m_timeScalesCursor;
    HLSCursor *m_foldersCursor;
    HLSCursor *m_mixedFoldersCursor;
    UIPopoverController *m_popoverController;
}

@property (nonatomic, retain) IBOutlet HLSCursor *weekDaysCursor;
@property (nonatomic, retain) IBOutlet UILabel *weekDayIndexLabel;
@property (nonatomic, retain) IBOutlet UIButton *nextWeekDayButton;
@property (nonatomic, retain) IBOutlet HLSCursor *randomRangeCursor;
@property (nonatomic, retain) IBOutlet UILabel *randomRangeIndexLabel;
@property (nonatomic, retain) IBOutlet UIButton *randomRangeCursorReloadButton;
@property (nonatomic, retain) IBOutlet HLSCursor *timeScalesCursor;
@property (nonatomic, retain) IBOutlet HLSCursor *foldersCursor;
@property (nonatomic, retain) IBOutlet HLSCursor *mixedFoldersCursor;

- (IBAction)moveWeekDaysPointerToNextDay;
- (IBAction)reloadRandomRangeCursor;

@end
