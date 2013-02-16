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
    HLSCursor *_weekDaysCursor;
    UILabel *_weekDayIndexLabel;
    HLSCursor *_randomRangeCursor;
    UILabel *_randomRangeIndexLabel;
    UISlider *_widthFactorSlider;
    UISlider *_heightFactorSlider;
    HLSCursor *_timeScalesCursor;
    HLSCursor *_foldersCursor;
    HLSCursor *_mixedFoldersCursor;
    UIPopoverController *_currentPopoverController;
    CGSize _originalRandomRangeCursorSize;
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

- (IBAction)moveWeekDaysPointerToNextDay:(id)sender;
- (IBAction)reloadRandomRangeCursor:(id)sender;
- (IBAction)sizeChanged:(id)sender;

@end
