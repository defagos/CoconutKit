//
//  CursorDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 10.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CursorDemoViewController.h"

@implementation CursorDemoViewController

static NSArray *s_weekDays = nil;
static NSArray *s_monthDays = nil;

#pragma mark Class methods

+ (void)initialize
{
    s_weekDays = [[NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil] retain];
    s_monthDays = [[NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", 
                    @"17", nil] retain];
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Cursor", @"Cursor");
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.weekDaysCursor = nil;
    self.moveWeekDaysPointerButton = nil;
    self.weekDayIndexLabel = nil;
    self.monthDaysCursor = nil;
}

#pragma mark Accessors and mutators

@synthesize weekDaysCursor = m_weekDaysCursor;

@synthesize moveWeekDaysPointerButton = m_moveWeekDaysPointerButton;

@synthesize weekDayIndexLabel = m_weekDayIndexLabel;

@synthesize monthDaysCursor = m_monthDaysCursor;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weekDaysCursor.dataSource = self;
    self.weekDaysCursor.delegate = self;
    [self.weekDaysCursor setSelectedIndex:3 animated:NO];
    self.weekDaysCursor.spacing = 30.f;
    
    self.monthDaysCursor.dataSource = self;
    self.monthDaysCursor.delegate = self;
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
    if (cursor == self.weekDaysCursor) {
        return [s_weekDays count];
    }
    else if (cursor == self.monthDaysCursor) {
        return [s_monthDays count];
    }
    else {
        HLSLoggerDebug(@"Unknown cursor");
        return 0;
    }
}

- (NSString *)cursor:(HLSCursor *)cursor titleAtIndex:(NSUInteger)index
{
    if (cursor == self.weekDaysCursor) {
        return [s_weekDays objectAtIndex:index];
    }
    else if (cursor == self.monthDaysCursor) {
        return [s_monthDays objectAtIndex:index];
    }
    else {
        HLSLoggerDebug(@"Unknown cursor");
        return @"";
    }
}

#pragma mark HLSCursorDelegate protocol implementation

- (void)cursor:(HLSCursor *)cursor didSelectIndex:(NSUInteger)index
{
    if (cursor == self.weekDaysCursor) {
        self.weekDayIndexLabel.text = [NSString stringWithFormat:@"%d", index];
    }
}

#pragma mark Event callbacks

- (IBAction)moveWeekDaysPointerToNextDay
{
    [self.weekDaysCursor setSelectedIndex:[self.weekDaysCursor selectedIndex] + 1 animated:YES];
}

@end
