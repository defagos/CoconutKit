//
//  CursorDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 10.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CursorDemoViewController.h"

@implementation CursorDemoViewController

static NSArray *s_days = nil;

#pragma mark Class methods

+ (void)initialize
{
    s_days = [[NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil] retain];
}

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.daysCursor = nil;
    self.moveDaysPointerButton = nil;
    self.dayIndexLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize daysCursor = m_daysCursor;

@synthesize moveDaysPointerButton = m_moveDaysPointerButton;

@synthesize dayIndexLabel = m_dayIndexLabel;;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.daysCursor.dataSource = self;
    self.daysCursor.delegate = self;
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark HLSCursorDataSource protocol implementation

- (NSUInteger)numberOfElementsForCursor:(HLSCursor *)cursor
{
    if (cursor == self.daysCursor) {
        return [s_days count];
    }
    else {
        HLSLoggerDebug(@"Unknown cursor");
        return 0;
    }
}

- (NSString *)cursor:(HLSCursor *)cursor titleAtIndex:(NSUInteger)index
{
    if (cursor == self.daysCursor) {
        return [s_days objectAtIndex:index];
    }
    else {
        HLSLoggerDebug(@"Unknown cursor");
        return @"";
    }
}

#pragma mark HLSCursorDelegate protocol implementation

- (void)cursor:(HLSCursor *)cursor didSelectIndex:(NSUInteger)index
{
    self.dayIndexLabel.text = [NSString stringWithFormat:@"%d", index];
}

#pragma mark Event callbacks

- (IBAction)moveDaysPointerToNextDay
{
    [self.daysCursor setSelectedIndex:[self.daysCursor selectedIndex] + 1 animated:YES];
}

@end
