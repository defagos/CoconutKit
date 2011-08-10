//
//  CursorDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 10.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CursorDemoViewController.h"

#import "CursorCustomPointerView.h"
#import "CursorFolderView.h"
#import "CursorPointerInfoViewController.h"
#import "CursorSelectedFolderView.h"

@interface CursorDemoViewController ()

@property (nonatomic, retain) UIPopoverController *popoverController;

@end

@implementation CursorDemoViewController

static NSArray *s_weekDays = nil;
static NSArray *s_completeRange = nil;
static NSArray *s_timeScales = nil;
static NSArray *s_folders = nil;

#pragma mark Class methods

+ (void)initialize
{
    s_weekDays = [[NSDateFormatter orderedWeekdaySymbols] retain];    
    s_completeRange = [[NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10",
                      @"11", @"12", @"13", @"14", @"15", @"16", nil] retain];
    s_timeScales = [[NSArray arrayWithObjects:NSLocalizedString(@"YEAR", @"YEAR"),
                     NSLocalizedString(@"MONTH", @"MONTH"),
                     NSLocalizedString(@"WEEK", @"WEEK"),
                     NSLocalizedString(@"DAY", @"DAY"),
                     nil] retain];
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

- (void)dealloc
{
    self.popoverController = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.weekDaysCursor = nil;
    self.weekDayIndexLabel = nil;
    self.nextWeekDayButton = nil;
    self.randomRangeCursor = nil;
    self.randomRangeIndexLabel = nil;
    self.randomRangeCursorReloadButton = nil;
    self.timeScalesCursor = nil;
    self.foldersCursor = nil;
    self.mixedFoldersCursor = nil;
}

#pragma mark Accessors and mutators

@synthesize weekDaysCursor = m_weekDaysCursor;

@synthesize weekDayIndexLabel = m_weekDayIndexLabel;

@synthesize nextWeekDayButton = m_nextWeekDayButton;

@synthesize randomRangeCursor = m_randomRangeCursor;

@synthesize randomRangeIndexLabel = m_randomRangeIndexLabel;

@synthesize randomRangeCursorReloadButton = m_randomRangeCursorReloadButton;

@synthesize timeScalesCursor = m_timeScalesCursor;

@synthesize foldersCursor = m_foldersCursor;

@synthesize mixedFoldersCursor = m_mixedFoldersCursor;

@synthesize popoverController = m_popoverController;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weekDaysCursor.dataSource = self;
    self.weekDaysCursor.delegate = self;
    [self.weekDaysCursor moveToIndex:3 animated:NO];
    self.weekDaysCursor.spacing = 30.f;
    self.weekDaysCursor.pointerViewTopLeftOffset = CGSizeMake(-10.f, -5.f);
    self.weekDaysCursor.pointerViewBottomRightOffset = CGSizeMake(10.f, 5.f);
    
    [self.nextWeekDayButton setTitle:NSLocalizedString(@"Next", @"Next") forState:UIControlStateNormal];
    
    self.randomRangeCursor.pointerView = HLSXibViewGet(CursorCustomPointerView);
    [self.randomRangeCursor moveToIndex:4 animated:NO];
    self.randomRangeCursor.dataSource = self;
    self.randomRangeCursor.delegate = self;
    
    [self.randomRangeCursorReloadButton setTitle:NSLocalizedString(@"Reload", @"Reload") forState:UIControlStateNormal];
    
    self.timeScalesCursor.dataSource = self;
    self.timeScalesCursor.delegate = self;
    // Not perfectly centered with the font used. Tweak a little bit to get a perfect result
    self.timeScalesCursor.pointerViewTopLeftOffset = CGSizeMake(-11.f, -12.f);
    
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

#pragma mark Memory warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.popoverController = nil;
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
    else if (cursor == self.randomRangeCursor) {
        // Omit up to 10 objects at the end of the array
        return arc4random() % 10 + [s_completeRange count] - 10 + 1;
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
    else if (cursor == self.randomRangeCursor) {
        return [s_completeRange objectAtIndex:index];
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
        return [UIFont fontWithName:@"ProximaNova-Regular" size:20.f];
    }
    else {
        // Default
        return nil;
    }
}

- (UIColor *)cursor:(HLSCursor *)cursor textColorAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.randomRangeCursor) {
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

- (UIColor *)cursor:(HLSCursor *)cursor shadowColorAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.randomRangeCursor) {
        return [UIColor whiteColor];
    }
    else {
        // Default (no shadow)
        return nil;
    }
}

- (CGSize)cursor:(HLSCursor *)cursor shadowOffsetAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.randomRangeCursor) {
        return CGSizeMake(0, 1);
    }
    else {
        return kCursorShadowOffsetDefault;
    }
}

#pragma mark HLSCursorDelegate protocol implementation

- (void)cursor:(HLSCursor *)cursor didMoveFromIndex:(NSUInteger)index
{
    if (cursor == self.weekDaysCursor) {
        self.weekDayIndexLabel.text = [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Index", @"Index"), index];
        self.weekDayIndexLabel.textColor = [UIColor redColor];
    }
    else if (cursor == self.randomRangeCursor) {
        self.randomRangeIndexLabel.text = [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Index", @"Index"), index];
        self.randomRangeIndexLabel.textColor = [UIColor redColor];
    }    
}

- (void)cursor:(HLSCursor *)cursor didMoveToIndex:(NSUInteger)index
{
    if (cursor == self.weekDaysCursor) {
        self.weekDayIndexLabel.text = [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Index", @"Index"), index];
        self.weekDayIndexLabel.textColor = [UIColor blackColor];
    }
    else if (cursor == self.randomRangeCursor) {
        self.randomRangeIndexLabel.text = [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Index", @"Index"), index];
        self.randomRangeIndexLabel.textColor = [UIColor blackColor];
        
        CursorCustomPointerView *pointerView = (CursorCustomPointerView *)cursor.pointerView;
        pointerView.valueLabel.text = [s_completeRange objectAtIndex:index];
    }
}

- (void)cursorDidStartDragging:(HLSCursor *)cursor
{
    if (cursor == self.randomRangeCursor) {
        if (! self.popoverController) {
            CursorPointerInfoViewController *infoViewController = [[[CursorPointerInfoViewController alloc] init] autorelease];
            self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:infoViewController] autorelease];
            self.popoverController.popoverContentSize = infoViewController.view.frame.size;
        }        
    }
}

- (void)cursor:(HLSCursor *)cursor didDragNearIndex:(NSUInteger)index
{
    if (cursor == self.randomRangeCursor) {
        CursorPointerInfoViewController *infoViewController = (CursorPointerInfoViewController *)self.popoverController.contentViewController;
        infoViewController.valueLabel.text = [s_completeRange objectAtIndex:index];
        
        [self.popoverController presentPopoverFromRect:cursor.pointerView.bounds
                                                inView:cursor.pointerView
                              permittedArrowDirections:UIPopoverArrowDirectionDown
                                              animated:NO];
        
        CursorCustomPointerView *pointerView = (CursorCustomPointerView *)cursor.pointerView;
        pointerView.valueLabel.text = [s_completeRange objectAtIndex:index];
    }
}

- (void)cursorDidStopDragging:(HLSCursor *)cursor
{
    if (cursor == self.randomRangeCursor) {
        [self.popoverController dismissPopoverAnimated:NO];
    }
}

#pragma mark Event callbacks

- (IBAction)moveWeekDaysPointerToNextDay
{
    [self.weekDaysCursor moveToIndex:[self.weekDaysCursor selectedIndex] + 1 animated:YES];
}

- (IBAction)reloadRandomRangeCursor
{
    [self.randomRangeCursor reloadData];
}

@end
