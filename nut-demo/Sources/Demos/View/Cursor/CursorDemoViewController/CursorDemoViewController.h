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
    HLSCursor *m_daysCursor;
    UIButton *m_moveDaysPointerButton;
    UILabel *m_dayIndexLabel;
}

@property (nonatomic, retain) IBOutlet HLSCursor *daysCursor;
@property (nonatomic, retain) IBOutlet UIButton *moveDaysPointerButton;
@property (nonatomic, retain) IBOutlet UILabel *dayIndexLabel;

- (IBAction)moveDaysPointerToNextDay;

@end
