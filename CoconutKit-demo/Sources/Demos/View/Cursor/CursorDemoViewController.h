//
//  CursorDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 10.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Designated initializer: -init
 */
@interface CursorDemoViewController : HLSViewController <HLSCursorDataSource, HLSCursorDelegate> {
@private
    HLSCursor *m_weekDaysCursor;
    UILabel *m_weekDayIndexLabel;
    HLSCursor *m_randomRangeCursor;
    UILabel *m_randomRangeIndexLabel;
    UISlider *m_widthFactorSlider;
    UISlider *m_heightFactorSlider;
    HLSCursor *m_timeScalesCursor;
    HLSCursor *m_foldersCursor;
    HLSCursor *m_mixedFoldersCursor;
    UISwitch *m_animatedSwitch;
    UIPopoverController *m_popoverController;
    CGSize m_originalRandomRangeCursorSize;
}

@property (nonatomic, retain) IBOutlet HLSCursor *weekDaysCursor;
@property (nonatomic, retain) IBOutlet UILabel *weekDayIndexLabel;
@property (nonatomic, retain) IBOutlet HLSCursor *randomRangeCursor;
@property (nonatomic, retain) IBOutlet UILabel *randomRangeIndexLabel;
@property (nonatomic, retain) IBOutlet UISlider *widthFactorSlider;
@property (nonatomic, retain) IBOutlet UISlider *heightFactorSlider;
@property (nonatomic, retain) IBOutlet HLSCursor *timeScalesCursor;
@property (nonatomic, retain) IBOutlet HLSCursor *foldersCursor;
@property (nonatomic, retain) IBOutlet HLSCursor *mixedFoldersCursor;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;

- (IBAction)moveWeekDaysPointerToNextDay:(id)sender;
- (IBAction)reloadRandomRangeCursor:(id)sender;
- (IBAction)changeSize:(id)sender;
- (IBAction)toggleAnimated:(id)sender;

@end
