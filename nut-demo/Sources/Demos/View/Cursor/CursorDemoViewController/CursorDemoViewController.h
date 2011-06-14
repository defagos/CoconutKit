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
}

@property (nonatomic, retain) IBOutlet HLSCursor *daysCursor;

@end
