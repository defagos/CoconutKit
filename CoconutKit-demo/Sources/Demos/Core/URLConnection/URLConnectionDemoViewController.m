//
//  URLConnectionDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 11.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "URLConnectionDemoViewController.h"

#import "Coconut.h"
#import "CoconutTableViewCell.h"

@interface URLConnectionDemoViewController ()

@property (nonatomic, retain) NSArray *coconuts;

@end

@implementation URLConnectionDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
    }
    return self;
}

- (void)dealloc
{
    self.coconuts = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.tableView = nil;
}

#pragma mark Accessors and mutators

@synthesize coconuts = m_coconuts;

@synthesize tableView = m_tableView;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = [CoconutTableViewCell height];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8087/coconuts.plist"]];
    HLSURLConnection *connection = [HLSURLConnection connectionWithRequest:request];
    connection.downloadFilePath = [HLSApplicationTemporaryDirectoryPath() stringByAppendingPathComponent:@"coconuts.plist"];
    
    connection.delegate = self;
    [connection start];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Networking with HLSURLConnection", @"Networking with HLSURLConnection");
    
    // Must sort coconuts by name again when switching languages
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" 
                                                                         ascending:YES 
                                                                          selector:@selector(localizedCaseInsensitiveCompare:)];
    self.coconuts = [self.coconuts sortedArrayUsingDescriptor:nameSortDescriptor]; 
    
    [self reloadData];
}

#pragma mark HLSURLConnectionDelegate protocol implementation

- (void)connectionDidStart:(HLSURLConnection *)connection
{
    HLSLoggerInfo(@"Connection did start");
}

- (void)connectionDidProgress:(HLSURLConnection *)connection
{
    HLSLoggerInfo(@"Connection did progress (progress = %f)", connection.progress);
}

- (void)connectionDidFinish:(HLSURLConnection *)connection
{
    HLSLoggerInfo(@"Connection did finish");
        
    NSDictionary *coconutsDictionary = [NSDictionary dictionaryWithContentsOfFile:connection.downloadFilePath];
    NSArray *coconuts = [Coconut coconutsFromDictionary:coconutsDictionary];
    
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" 
                                                                         ascending:YES 
                                                                          selector:@selector(localizedCaseInsensitiveCompare:)];
    self.coconuts = [coconuts sortedArrayUsingDescriptor:nameSortDescriptor]; 
    
    [self reloadData];
}

- (void)connection:(HLSURLConnection *)connection didFailWithError:(NSError *)error
{
    HLSLoggerInfo(@"Connection did fail with error: %@", error);
    
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                         message:NSLocalizedString(@"The data could not be retrieved", @"The data could not be retrieved") 
                                                        delegate:nil 
                                               cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.coconuts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return [CoconutTableViewCell cellForTableView:tableView];
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CoconutTableViewCell *tableViewCell = (CoconutTableViewCell *)cell;
    
    Coconut *coconut = [self.coconuts objectAtIndex:indexPath.row];
    
    // We must use a customm cell here. If we try to use a standard cell style and its imageView property, refresh does
    // not work correctly. UITableViewCell implementation probably does some nasty things under the hood
    if (coconut.thumbnailImageName) {
        NSURL *url = [[NSURL URLWithString:@"http://localhost:8087"] URLByAppendingPathComponent:coconut.thumbnailImageName];
        [tableViewCell.thumbnailImageView loadWithImageAtURL:url];        
    }
    else {
        tableViewCell.thumbnailImageView.image = nil;
    }
    tableViewCell.nameLabel.text = coconut.name;
    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
