//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewBindingInformationViewController.h"

#import "HLSCoreError.h"
#import "HLSInfoTableViewCell.h"
#import "HLSLogger.h"
#import "HLSMAKVONotificationCenter.h"
#import "HLSRuntime.h"
#import "HLSTransformer.h"
#import "HLSViewBindingDebugOverlayViewController.h"
#import "HLSViewBindingHelpViewController.h"
#import "HLSViewBindingInformation.h"
#import "HLSViewBindingInformationEntry.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"
#import "NSString+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"
#import "UIView+HLSViewBindingImplementation.h"

@interface HLSViewBindingInformationViewController ()

@property (nonatomic) HLSViewBindingInformation *bindingInformation;

@property (nonatomic) NSArray<NSString *> *headerTitles;
@property (nonatomic) NSArray<NSString *> *footerTitles;

@property (nonatomic) NSArray<NSArray<HLSViewBindingInformationEntry *> *> *entries;

@end

@implementation HLSViewBindingInformationViewController

#pragma mark Object creation and destruction

- (instancetype)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation
{
    NSParameterAssert(bindingInformation);
    
    if (self = [super initWithBundle:[NSBundle coconutKitBundle]]) {
        self.bindingInformation = bindingInformation;
        
        self.title = CoconutKitLocalizedString(@"Properties", nil);
        
        self.headerTitles = @[@"Status", @"Capabilities", @"Parameters", @"Resolved information", @"Values"];
        self.footerTitles = @[@"", @"", @"", @"Tap to highlight objects", @""];
        
        __weak __typeof(self) weakSelf = self;
        if ([bindingInformation.keyPath rangeOfString:@"@"].length == 0) {
            [bindingInformation.objectTarget hlsma_addObserver:self keyPath:bindingInformation.keyPath options:NSKeyValueObservingOptionNew block:^(HLSMAKVONotification *notification) {
                [weakSelf reloadData];
            }];
        }
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    if (! self.navigationController.popoverPresentationController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                              target:self
                                                                                              action:@selector(close:)];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CoconutKitLocalizedString(@"Help", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showHelp:)];
    
    [self reloadData];
}

#pragma mark Data

- (NSArray<HLSViewBindingInformationEntry *> *)statusEntries
{
    NSMutableArray<HLSViewBindingInformationEntry *> *statusEntries = [NSMutableArray array];
    
    NSString *statusString = nil;
    if (! self.bindingInformation.error) {
        statusString = self.bindingInformation.verified ? @"The binding information is valid" : @"The binding information has not been fully verified yet";
    }
    else {
        if ([self.bindingInformation.error hasCode:HLSCoreErrorMultipleErrors withinDomain:HLSCoreErrorDomain]) {
            NSArray<NSError *> *errors = [self.bindingInformation.error objectForKey:HLSDetailedErrorsKey];
            NSArray<NSString *> *localizedDescriptions = [errors valueForKeyPath:@"@distinctUnionOfObjects.localizedDescription"];
            statusString = [localizedDescriptions componentsJoinedByString:@"\n\n"];
        }
        else {
            statusString = self.bindingInformation.error.localizedDescription;
        }
    }
    
    HLSViewBindingInformationEntry *statusEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Status"
                                                                                                  text:statusString];
    [statusEntries addObject:statusEntry];
    
    return [statusEntries copy];
}

- (NSArray<HLSViewBindingInformationEntry *> *)capabilitiesEntries
{
    NSMutableArray<HLSViewBindingInformationEntry *> *capabilitiesEntries = [NSMutableArray array];
    
    HLSViewBindingInformationEntry *supportingInputEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Supports input"
                                                                                                           text:HLSStringFromBool(self.bindingInformation.supportingInput)];
    [capabilitiesEntries addObject:supportingInputEntry];
    
    HLSViewBindingInformationEntry *viewUpdatedAutomaticallyEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"View updated automatically"
                                                                                                                    text:HLSStringFromBool(self.bindingInformation.viewAutomaticallyUpdated)];
    [capabilitiesEntries addObject:viewUpdatedAutomaticallyEntry];
    
    if (self.bindingInformation.supportingInput) {
        HLSViewBindingInformationEntry *canUpdateEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Model updated automatically"
                                                                                                         text:HLSStringFromBool(self.bindingInformation.modelAutomaticallyUpdated)];
        [capabilitiesEntries addObject:canUpdateEntry];
    }
    
    return [capabilitiesEntries copy];
}

- (NSArray<HLSViewBindingInformationEntry *> *)parameterEntries
{
    NSMutableArray<HLSViewBindingInformationEntry *> *parameterEntries = [NSMutableArray array];
    
    HLSViewBindingInformationEntry *keyPathEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Key path"
                                                                                                   text:self.bindingInformation.keyPath];
    [parameterEntries addObject:keyPathEntry];
    
    HLSViewBindingInformationEntry *transformerNameEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Transformer name"
                                                                                                           text:self.bindingInformation.transformerName];
    [parameterEntries addObject:transformerNameEntry];
    
    HLSViewBindingInformationEntry *bindUpdateAnimatedEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Animates updates"
                                                                                                              text:HLSStringFromBool(self.bindingInformation.view.bindUpdateAnimated)];
    [parameterEntries addObject:bindUpdateAnimatedEntry];
    
    if (self.bindingInformation.supportingInput) {
        HLSViewBindingInformationEntry *bindInputCheckedEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Automatically checks input"
                                                                                                                text:HLSStringFromBool(self.bindingInformation.view.bindInputChecked)];
        [parameterEntries addObject:bindInputCheckedEntry];
    }
    
    return [parameterEntries copy];
}

- (NSArray<HLSViewBindingInformationEntry *> *)resolvedInformationEntries
{
    NSMutableArray<HLSViewBindingInformationEntry *> *resolvedInformationEntries = [NSMutableArray array];
    
    HLSViewBindingInformationEntry *objectTargetEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Resolved bound object"
                                                                                                      object:self.bindingInformation.objectTarget];
    [resolvedInformationEntries addObject:objectTargetEntry];
    
    HLSViewBindingInformationEntry *delegateEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Resolved binding delegate"
                                                                                                  object:self.bindingInformation.delegate];
    [resolvedInformationEntries addObject:delegateEntry];

    if (self.bindingInformation.transformerName) {
        HLSViewBindingInformationEntry *transformationTargetEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Resolved transformation target"
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
        
        HLSViewBindingInformationEntry *transformationSelectorEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Resolved transformation selector"
                                                                                                                      text:transformationSelectorString];
        [resolvedInformationEntries addObject:transformationSelectorEntry];
    }
    
    if (self.bindingInformation.supportingInput) {
        HLSViewBindingInformationEntry *inputClassEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Resolved input value class (view)"
                                                                                                          text:NSStringFromClass(self.bindingInformation.inputClass)];
        [resolvedInformationEntries addObject:inputClassEntry];
    }
    
    HLSViewBindingInformationEntry *rawClassEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Resolved raw value class (model)"
                                                                                                    text:NSStringFromClass(self.bindingInformation.rawClass)];
    [resolvedInformationEntries addObject:rawClassEntry];
    
    return [resolvedInformationEntries copy];
}

- (NSArray<HLSViewBindingInformationEntry *> *)valueEntries
{
    NSMutableArray<HLSViewBindingInformationEntry *> *valueEntries = [NSMutableArray array];
    
    if (self.bindingInformation.supportingInput) {
        HLSViewBindingInformationEntry *inputValueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Input value (view)"
                                                                                                        object:self.bindingInformation.inputValue];
        [valueEntries addObject:inputValueEntry];
    }
    
    HLSViewBindingInformationEntry *rawValueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Raw value (model)"
                                                                                                  object:self.bindingInformation.rawValue];
    [valueEntries addObject:rawValueEntry];
    
    HLSViewBindingInformationEntry *valueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:@"Transformed value"
                                                                                               object:self.bindingInformation.value];
    [valueEntries addObject:valueEntry];
    
    return [valueEntries copy];
}

- (void)reloadEntries
{
    NSMutableArray<NSArray<HLSViewBindingInformationEntry *> *> *entries = [NSMutableArray array];
    [entries addObject:[self statusEntries]];
    [entries addObject:[self capabilitiesEntries]];
    [entries addObject:[self parameterEntries]];
    [entries addObject:[self resolvedInformationEntries]];
    [entries addObject:[self valueEntries]];
    self.entries = [entries copy];
}

- (void)reloadData
{
    [self reloadEntries];
    [self.tableView reloadData];
}

- (HLSViewBindingInformationEntry *)entryAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray<HLSViewBindingInformationEntry *> *sectionEntries = self.entries[indexPath.section];
    return sectionEntries[indexPath.row];
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.headerTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.headerTitles[section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = self.footerTitles[section];
    return title.filled ? title : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionEntries = self.entries[section];
    return sectionEntries.count;
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
    infoCell.selectionStyle = entry.view ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
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
    [[HLSViewBindingDebugOverlayViewController currentBindingDebugOverlayViewController] highlightView:entry.view];
}

#pragma mark Actions

- (void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showHelp:(id)sender
{
    HLSViewBindingHelpViewController *helpViewController = [[HLSViewBindingHelpViewController alloc] init];
    [self.navigationController pushViewController:helpViewController animated:YES];
}

@end
