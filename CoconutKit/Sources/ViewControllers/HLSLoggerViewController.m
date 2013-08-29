//
//  HLSLoggerViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 29.08.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSLoggerViewController.h"

#import "HLSLogger.h"
#import "HLSLogger+Friend.h"
#import "HLSTableViewCell.h"
#import "NSBundle+HLSExtensions.h"

@interface HLSLoggerViewController ()

@property (nonatomic, strong) NSArray *logFilePaths;

@property (nonatomic, weak) IBOutlet UISegmentedControl *levelSegmentedControl;
@property (nonatomic, weak) IBOutlet UISwitch *enabledSwitch;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation HLSLoggerViewController

#pragma mark Object creation and destruction

- (id)init
{
    return [super initWithBundle:[NSBundle coconutKitBundle]];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = [HLSTableViewCell height];
    
    HLSLogger *logger = [HLSLogger sharedLogger];
    self.enabledSwitch.on = logger.fileLoggingEnabled;
    self.levelSegmentedControl.selectedSegmentIndex = logger.level;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(close:)];
    
    [self reloadData];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = CoconutKitLocalizedString(@"Logging controls", nil);
}

#pragma mark Reloading the screen

- (void)reloadData
{
    self.logFilePaths = [HLSLogger availableLogFilePaths];
    
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.logFilePaths count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return [HLSTableViewCell cellForTableView:tableView];
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [[self.logFilePaths objectAtIndex:indexPath.row] lastPathComponent];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Show document interaction controller. Hopefully can be customized to add a send by email button
}

#pragma mark Action callbacks

- (IBAction)toggleEnabled:(id)sender
{
    [HLSLogger sharedLogger].fileLoggingEnabled = ! [HLSLogger sharedLogger].fileLoggingEnabled;
}

- (IBAction)selectLevel:(id)sender
{
    [HLSLogger sharedLogger].level = [self.levelSegmentedControl selectedSegmentIndex];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
