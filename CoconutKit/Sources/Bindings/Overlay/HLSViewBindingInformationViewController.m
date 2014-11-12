//
//  HLSViewBindingInformationViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 03/12/13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingInformationViewController.h"

#import "HLSInfoTableViewCell.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSTransformer.h"
#import "HLSViewBindingInformationEntry.h"
#import "NSBundle+HLSExtensions.h"
#import "NSString+HLSExtensions.h"
#import "UIPopoverController+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"
#import "UIView+HLSViewBindingImplementation.h"

@interface HLSViewBindingInformationViewController ()

@property (nonatomic, strong) HLSViewBindingInformation *bindingInformation;

@property (nonatomic, strong) NSArray *headerTitles;
@property (nonatomic, strong) NSArray *footerTitles;

@property (nonatomic, strong) NSArray *entries;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation HLSViewBindingInformationViewController

#pragma mark Object creation and destruction

- (instancetype)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation
{
    if (self = [super initWithBundle:[NSBundle coconutKitBundle]]) {
        self.bindingInformation = bindingInformation;
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(320.f, 640.f);
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
    if (! self.popoverController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                              target:self
                                                                                              action:@selector(close:)];
    }
    
    [self reloadData];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Properties", nil);
    
    self.headerTitles = [NSArray arrayWithObjects:NSLocalizedString(@"Status", nil),
                         NSLocalizedString(@"Parameters", nil),
                         NSLocalizedString(@"Resolved information", nil),
                         NSLocalizedString(@"Values", nil), nil];
    self.footerTitles = [NSArray arrayWithObjects:[NSNull null],
                         [NSNull null],
                         NSLocalizedString(@"Tap to highlight objects", nil),
                         [NSNull null],
                         nil];
    [self reloadEntries];
}

#pragma mark Data

- (NSArray *)statusEntries
{
    NSMutableArray *statusEntries = [NSMutableArray array];
    
    NSString *defaultStatusString = self.bindingInformation.verified ? CoconutKitLocalizedString(@"The binding information is valid", nil) : CoconutKitLocalizedString(@"The binding information has not been fully verified yet", nil);
    NSString *statusString = self.bindingInformation.error ? [self.bindingInformation.error localizedDescription] : defaultStatusString;
    
    HLSViewBindingInformationEntry *statusEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Status", nil)
                                                                                                  text:statusString];
    [statusEntries addObject:statusEntry];
    
    HLSViewBindingInformationEntry *updatedAutomaticallyEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"View updated automatically", nil)
                                                                                                                text:HLSStringFromBool(self.bindingInformation.updatedAutomatically)];
    [statusEntries addObject:updatedAutomaticallyEntry];
    
    HLSViewBindingInformationEntry *canUpdateEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Can update the model", nil)
                                                                                                     text:HLSStringFromBool([self.bindingInformation.view respondsToSelector:@selector(displayedValue)])];
    [statusEntries addObject:canUpdateEntry];
    
    return [NSArray arrayWithArray:statusEntries];
}

- (NSArray *)parameterEntries
{
    NSMutableArray *parameterEntries = [NSMutableArray array];
    
    HLSViewBindingInformationEntry *keyPathEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Key path", nil)
                                                                                                   text:self.bindingInformation.keyPath];
    [parameterEntries addObject:keyPathEntry];
    
    HLSViewBindingInformationEntry *transformerNameEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Transformer name", nil)
                                                                                                           text:self.bindingInformation.transformerName];
    [parameterEntries addObject:transformerNameEntry];
    
    return [NSArray arrayWithArray:parameterEntries];
}

- (NSArray *)resolvedInformationEntries
{
    NSMutableArray *resolvedInformationEntries = [NSMutableArray array];
    
    HLSViewBindingInformationEntry *objectTargetEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved bound object", nil)
                                                                                                      object:self.bindingInformation.objectTarget];
    [resolvedInformationEntries addObject:objectTargetEntry];
    
    HLSViewBindingInformationEntry *delegateEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved binding delegate", nil)
                                                                                                  object:self.bindingInformation.delegate];
    [resolvedInformationEntries addObject:delegateEntry];

    HLSViewBindingInformationEntry *transformationTargetEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved transformation target", nil)
                                                                                                              object:self.bindingInformation.transformationTarget];
    [resolvedInformationEntries addObject:transformationTargetEntry];
    
    NSString *transformationSelectorString = nil;
    if (self.bindingInformation.transformationSelector) {
        transformationSelectorString = [NSString stringWithFormat:@"%@%@", hls_isClass(self.bindingInformation.transformationTarget) ? @"+" : @"-",
                                        NSStringFromSelector(self.bindingInformation.transformationSelector)];
    }
    else {
        transformationSelectorString = @"-";
    }
    
    HLSViewBindingInformationEntry *transformationSelectorEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved transformation selector", nil)
                                                                                                                  text:transformationSelectorString];
    [resolvedInformationEntries addObject:transformationSelectorEntry];
    
    return [NSArray arrayWithArray:resolvedInformationEntries];
}

- (NSArray *)valueEntries
{
    NSMutableArray *valueEntries = [NSMutableArray array];
    
    HLSViewBindingInformationEntry *displayedValueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Displayed value", nil)
                                                                                                        object:[self.bindingInformation displayedValue]];
    [valueEntries addObject:displayedValueEntry];
    
    HLSViewBindingInformationEntry *rawValueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Raw value", nil)
                                                                                                  object:[self.bindingInformation rawValue]];
    [valueEntries addObject:rawValueEntry];
    
    HLSViewBindingInformationEntry *valueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Formatter raw value", nil)
                                                                                               object:[self.bindingInformation value]];
    [valueEntries addObject:valueEntry];
    
    return [NSArray arrayWithArray:valueEntries];
}

- (void)reloadEntries
{
    NSMutableArray *entries = [NSMutableArray array];
    [entries addObject:[self statusEntries]];
    [entries addObject:[self parameterEntries]];
    [entries addObject:[self resolvedInformationEntries]];
    [entries addObject:[self valueEntries]];
    self.entries = [NSArray arrayWithArray:entries];
}

- (void)reloadData
{
    [self reloadEntries];
    [self.tableView reloadData];
}

- (HLSViewBindingInformationEntry *)entryAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionEntries = [self.entries objectAtIndex:indexPath.section];
    return [sectionEntries objectAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.headerTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.headerTitles objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    id title = [self.footerTitles objectAtIndex:section];
    return title != [NSNull null] ? title : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionEntries = [self.entries objectAtIndex:section];
    return [sectionEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [HLSInfoTableViewCell cellForTableView:tableView];
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLSViewBindingInformationEntry *entry = [self entryAtIndexPath:indexPath];
    
    HLSInfoTableViewCell *infoCell = (HLSInfoTableViewCell *)cell;
    infoCell.nameLabel.text = entry.name;
    infoCell.valueLabel.text = entry.text;
    infoCell.selectionStyle = [entry canHighlight] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLSViewBindingInformationEntry *entry = [self entryAtIndexPath:indexPath];
    return [HLSInfoTableViewCell heightForValue:entry.text];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HLSViewBindingInformationEntry *entry = [self entryAtIndexPath:indexPath];
    [entry highlight];
}

#pragma mark Actions

- (void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
