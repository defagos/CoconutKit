//
//  CursorDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 10.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CursorDemoViewController.h"

#import "CursorFolderView.h"
#import "CursorSelectedFolderView.h"

@implementation CursorDemoViewController

static NSArray *s_weekDays = nil;
static NSArray *s_monthDays = nil;
static NSArray *s_timeScales = nil;
static NSArray *s_folders = nil;

#pragma mark Class methods

+ (void)initialize
{
    s_weekDays = [[NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil] retain];
    s_monthDays = [[NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", 
                    @"17", nil] retain];
    s_timeScales = [[NSArray arrayWithObjects:@"YEAR", @"MONTH", @"WEEK", @"DAY", nil] retain];
    s_folders = [[NSArray arrayWithObjects:@"A-F", @"G-L", @"M-R", @"S-Z", nil] retain];
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
    self.timeScalesCursor = nil;
    self.foldersCursor = nil;
    self.mixedFoldersCursor = nil;
}

#pragma mark Accessors and mutators

@synthesize weekDaysCursor = m_weekDaysCursor;

@synthesize moveWeekDaysPointerButton = m_moveWeekDaysPointerButton;

@synthesize weekDayIndexLabel = m_weekDayIndexLabel;

@synthesize monthDaysCursor = m_monthDaysCursor;

@synthesize timeScalesCursor = m_timeScalesCursor;

@synthesize foldersCursor = m_foldersCursor;

@synthesize mixedFoldersCursor = m_mixedFoldersCursor;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weekDaysCursor.dataSource = self;
    self.weekDaysCursor.delegate = self;
    [self.weekDaysCursor setSelectedIndex:3 animated:NO];
    self.weekDaysCursor.spacing = 30.f;
    self.weekDaysCursor.pointerViewTopLeftOffset = CGSizeMake(-10.f, -5.f);
    self.weekDaysCursor.pointerViewBottomRightOffset = CGSizeMake(10.f, 5.f);
    
    self.monthDaysCursor.dataSource = self;
    self.monthDaysCursor.delegate = self;
    
    self.timeScalesCursor.dataSource = self;
    self.timeScalesCursor.delegate = self;
    
    self.foldersCursor.dataSource = self;
    self.foldersCursor.delegate = self;
    self.foldersCursor.pointerViewTopLeftOffset = CGSizeMake(5.f, 5.f);
    self.foldersCursor.pointerViewBottomRightOffset = CGSizeMake(-5.f, -5.f);
    
    self.mixedFoldersCursor.dataSource = self;
    self.mixedFoldersCursor.delegate = self;
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

- (UIView *)cursor:(HLSCursor *)cursor viewAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.foldersCursor || (cursor == self.mixedFoldersCursor && index % 2 == 0)) {
        if (selected) {
            CursorSelectedFolderView *view = HLSXibViewGet(CursorSelectedFolderView);
            view.nameLabel.text = [s_folders objectAtIndex:index];
            return view;
        }
        else {
            CursorFolderView *view = HLSXibViewGet(CursorFolderView);
            view.nameLabel.text = [s_folders objectAtIndex:index];
            return view;        
        }
    }
    else {
        // Not defined using a view
        return nil;
    }
}

- (NSUInteger)numberOfElementsForCursor:(HLSCursor *)cursor
{
    if (cursor == self.weekDaysCursor) {
        return [s_weekDays count];
    }
    else if (cursor == self.monthDaysCursor) {
        return [s_monthDays count];
    }
    else if (cursor == self.timeScalesCursor) {
        return [s_timeScales count];
    }
    else if (cursor == self.foldersCursor || cursor == self.mixedFoldersCursor) {
        return [s_folders count];
    }
    else {
        HLSLoggerError(@"Unknown cursor");
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
    else if (cursor == self.timeScalesCursor) {
        return [s_timeScales objectAtIndex:index];
    }
    else if (cursor == self.mixedFoldersCursor && index % 2 != 0) {
        return [s_folders objectAtIndex:index];
    }
    else {
        return @"";
    }
}

- (UIFont *)cursor:(HLSCursor *)cursor fontAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.timeScalesCursor) {
        if (selected) {
            return [UIFont fontWithName:@"ProximaNova-Bold" size:20.f];
        }
        else {
            return [UIFont fontWithName:@"ProximaNova-Regular" size:20.f];
        }
    }
    else {
        // Default
        return nil;
    }
}

- (UIColor *)cursor:(HLSCursor *)cursor textColorAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.monthDaysCursor) {
        return [UIColor blueColor];
    }
    else if (cursor == self.mixedFoldersCursor) {
        return [UIColor blackColor];
    }
    else {
        // Default
        return nil;
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
