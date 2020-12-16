//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSLoggerViewController.h"

#import "HLSLogger.h"
#import "HLSLogger+Friend.h"
#import "HLSPreviewItem.h"
#import "HLSTableViewCell.h"
#import "NSBundle+HLSExtensions.h"

@interface HLSLoggerViewController ()

@property (nonatomic) HLSLogger *logger;

@property (nonatomic) NSArray<NSString *> *logFilePaths;

@property (nonatomic, weak) IBOutlet UISegmentedControl *levelSegmentedControl;
@property (nonatomic, weak) IBOutlet UISwitch *enabledSwitch;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic) NSURL *currentLogFileURL;

@end

@implementation HLSLoggerViewController

#pragma mark Object creation and destruction

- (instancetype)initWithLogger:(HLSLogger *)logger
{
    NSParameterAssert(logger);
    
    if (self = [super initWithBundle:[NSBundle coconutKitBundle]]) {
        self.logger = logger;        
        self.title = CoconutKitLocalizedString(@"Logging controls", nil);
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Ensure the view controller does not extend under the navigation and status bars
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = [HLSTableViewCell height];
    
    self.enabledSwitch.on = self.logger.fileLoggingEnabled;
    self.levelSegmentedControl.selectedSegmentIndex = self.logger.level;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(close:)];
    
    [self reloadData];
}

#pragma mark Reloading the screen

- (void)reloadData
{
    self.logFilePaths = self.logger.availableLogFilePaths;
    
    [self.tableView reloadData];
}

#pragma mark QLPreviewControllerDataSource protocol implementation

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [[HLSPreviewItem alloc] initWithPreviewItemURL:self.currentLogFileURL];
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logFilePaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return [HLSTableViewCell cellForTableView:tableView];
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = self.logFilePaths[indexPath.row].lastPathComponent;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.currentLogFileURL = [NSURL fileURLWithPath:self.logFilePaths[indexPath.row]];
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark Action callbacks

- (IBAction)toggleEnabled:(id)sender
{
    self.logger.fileLoggingEnabled = ! self.logger.fileLoggingEnabled;
}

- (IBAction)selectLevel:(id)sender
{
    self.logger.level = self.levelSegmentedControl.selectedSegmentIndex;
}

- (IBAction)clearLogs:(id)sender
{
    [self.logger clearLogs];
    [self reloadData];
}

- (void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
