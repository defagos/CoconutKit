//
//  DemosListViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "DemosListViewController.h"

#import "FixedSizeViewController.h"
#import "LifeCycleTestViewController.h"
#import "MultipleViewsAnimationDemoViewController.h"
#import "OrientationClonerViewController.h"
#import "ParallelProcessingDemoViewController.h"
#import "PlaceholderDemoViewController.h"
#import "SingleViewAnimationDemoViewController.h"
#import "StretchableViewController.h"
#import "TableSearchDisplayDemoViewController.h"
#import "TableViewCellsDemoViewController.h"
#import "TextFieldsDemoViewController.h"

// Categories
typedef enum {
    DemoCategoryIndexEnumBegin = 0,
    DemoCategoryIndexAnimation = DemoCategoryIndexEnumBegin,
    DemoCategoryIndexTask,
    DemoCategoryIndexView,
    DemoCategoryIndexViewControllers,
    DemoCategoryIndexEnumEnd,
    DemoCategoryIndexEnumSize = DemoCategoryIndexEnumEnd - DemoCategoryIndexEnumBegin
} DemoCategoryIndex;

// Demos for animation
typedef enum {
    AnimationDemoIndexEnumBegin = 0,
    AnimationDemoIndexSingleView = AnimationDemoIndexEnumBegin,
    AnimationDemoIndexMultipleViews,
    AnimationDemoIndexEnumEnd,
    AnimationDemoIndexEnumSize = AnimationDemoIndexEnumEnd - AnimationDemoIndexEnumBegin
} AnimationDemoIndex;

// Demos for tasks
typedef enum {
    TaskDemoIndexEnumBegin = 0,
    TaskDemoIndexParallelProcessing = TaskDemoIndexEnumBegin,
    TaskDemoIndexEnumEnd,
    TaskDemoIndexEnumSize = TaskDemoIndexEnumEnd - TaskDemoIndexEnumBegin
} TaskDemoIndex;

// Demos for views
typedef enum {
    ViewDemoIndexEnumBegin = 0,
    ViewDemoIndexTableViewCells = ViewDemoIndexEnumBegin,
    ViewDemoIndexTextFieldsFixed,
    ViewDemoIndexTextFieldsScrollable,
    ViewDemoIndexEnumEnd,
    ViewDemoIndexEnumSize = ViewDemoIndexEnumEnd - ViewDemoIndexEnumBegin
} ViewDemoIndex;

// Demos for view controllers
typedef enum {
    ViewControllersDemoIndexEnumBegin = 0,
    ViewControllersDemoIndexPlaceholderViewController = ViewControllersDemoIndexEnumBegin,
    ViewControllersDemoIndexLifeCycleTestInScrollView,
    ViewControllersDemoIndexFixedSizeLargeInScrollView,
    ViewControllersDemoIndexStretchableLargeInScrollView,
    ViewControllersDemoIndexOrientationLargeClonerInScrollView,
    ViewControllersDemoIndexWizardViewController,
    ViewControllersDemoIndexTableSearchDisplayViewController,
    ViewControllersDemoIndexPageController,
    ViewControllersDemoIndexEnumEnd,
    ViewControllersDemoIndexEnumSize = ViewControllersDemoIndexEnumEnd - ViewControllersDemoIndexEnumBegin
} ViewControllersDemoIndex;

@implementation DemosListViewController

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.title = NSLocalizedString(@"Demos", @"Demos");
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = HLS_TABLE_VIEW_CELL_HEIGHT(HLSTableViewCell);
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return DemoCategoryIndexEnumSize;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case DemoCategoryIndexAnimation: {
            return NSLocalizedString(@"Animation", @"Animation");
            break;
        }
            
        case DemoCategoryIndexTask: {
            return NSLocalizedString(@"Tasks", @"Tasks");
            break;
        }

        case DemoCategoryIndexView: {
            return NSLocalizedString(@"Views", @"Views");
            break;
        }

        case DemoCategoryIndexViewControllers: {
            return NSLocalizedString(@"View controllers", @"View controllers");
            break;
        }
            
        default: {
            return nil;
            break;
        }            
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case DemoCategoryIndexAnimation: {
            return AnimationDemoIndexEnumSize;
            break;
        }
            
        case DemoCategoryIndexTask: {
            return TaskDemoIndexEnumSize;
            break;
        }            
            
        case DemoCategoryIndexView: {
            return ViewDemoIndexEnumSize;
            break;
        }            
            
        case DemoCategoryIndexViewControllers: {
            return ViewControllersDemoIndexEnumSize;
            break;
        }   
            
        default: {
            return 0;
            break;
        }            
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    UITableViewCell *cell = HLS_TABLE_VIEW_CELL(HLSSubtitleTableViewCell, tableView);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case DemoCategoryIndexAnimation: {
            switch (indexPath.row) {
                case AnimationDemoIndexSingleView: {
                    cell.textLabel.text = NSLocalizedString(@"Single view animation", @"Single view animation");
                    break;
                }
                
                case AnimationDemoIndexMultipleViews: {
                    cell.textLabel.text = NSLocalizedString(@"Multiple view animation", @"Multiple view animation");
                    break;
                }
                    
                default: {
                    return nil;
                    break;
                }            
            }
            break;
        }
            
        case DemoCategoryIndexTask: {
            switch (indexPath.row) {
                case TaskDemoIndexParallelProcessing: {
                    cell.textLabel.text = NSLocalizedString(@"Parallel processing", @"Parallel processing");
                    break;
                }
                    
                default: {
                    return nil;
                    break;
                }            
            }
            break;
        }
            
        case DemoCategoryIndexView: {
            switch (indexPath.row) {
                case ViewDemoIndexTableViewCells: {
                    cell.textLabel.text = NSLocalizedString(@"Table view cells", @"Table view cells");
                    break;
                }
                    
                case ViewDemoIndexTextFieldsFixed: {
                    cell.textLabel.text = NSLocalizedString(@"Text fields", @"Text fields");
                    break;
                }
                    
                case ViewDemoIndexTextFieldsScrollable: {
                    cell.textLabel.text = NSLocalizedString(@"Text fields (large)", @"Text fields (large)");
                    break;
                }
                    
                default: {
                    return nil;
                    break;
                }            
            }
            break;
        }
            
        case DemoCategoryIndexViewControllers: {
            switch (indexPath.row) {
                case ViewControllersDemoIndexPlaceholderViewController: {
                    cell.textLabel.text = @"HLSPlaceholderViewController";
                    break;
                }
                    
                case ViewControllersDemoIndexLifeCycleTestInScrollView: {
                    cell.textLabel.text = @"HLSScrollViewController + LifeCycleTest";
                    break;
                }
                    
                case ViewControllersDemoIndexFixedSizeLargeInScrollView: {
                    cell.textLabel.text = @"HLSScrollViewController + FixedSizeViewController (large)";
                    break;
                }
                    
                case ViewControllersDemoIndexStretchableLargeInScrollView: {
                    cell.textLabel.text = @"HLSScrollViewController + StretchableViewController (large)";
                    break;
                }
                    
                case ViewControllersDemoIndexOrientationLargeClonerInScrollView: {
                    cell.textLabel.text = @"HLSScrollViewController + OrientationCloner (large)";
                    break;                
                }
                    
                case ViewControllersDemoIndexWizardViewController: {
                    cell.textLabel.text = @"HLSWizardViewController";
                    break;
                }
                    
                case ViewControllersDemoIndexTableSearchDisplayViewController: {
                    cell.textLabel.text = @"HLSTableSearchDisplayController";
                    break;
                }
                    
                case ViewControllersDemoIndexPageController: {
                    cell.textLabel.text = @"HLSPageController";
                    break;
                }
                    
                default: {
                    return nil;
                    break;
                }            
            }
            break;
        }
            
        default: {
            return nil;
            break;
        }
    }
    return cell;
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case DemoCategoryIndexAnimation: {
            switch (indexPath.row) {
                case AnimationDemoIndexSingleView: {
                    SingleViewAnimationDemoViewController *demoViewController = [[[SingleViewAnimationDemoViewController alloc] init] autorelease];
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
                    
                case AnimationDemoIndexMultipleViews: {
                    MultipleViewsAnimationDemoViewController *demoViewController = [[[MultipleViewsAnimationDemoViewController alloc] init] autorelease];
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
                    
                default: {
                    return;
                    break;
                }            
            }
            break;
        }
            
        case DemoCategoryIndexTask: {
            switch (indexPath.row) {
                case TaskDemoIndexParallelProcessing: {
                    ParallelProcessingDemoViewController *demoViewController = [[[ParallelProcessingDemoViewController alloc] init] autorelease];
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
                    
                default: {
                    return;
                    break;
                }            
            }
            break;
        }
            
        case DemoCategoryIndexView: {
            switch (indexPath.row) {
                case ViewDemoIndexTableViewCells: {
                    TableViewCellsDemoViewController *demoViewController = [[[TableViewCellsDemoViewController alloc] init] autorelease];
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
                    
                case ViewDemoIndexTextFieldsFixed: {
                    TextFieldsDemoViewController *demoViewController = [[[TextFieldsDemoViewController alloc] init] autorelease];
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
                    
                case ViewDemoIndexTextFieldsScrollable: {
                    HLSScrollViewController *scrollViewController = [[[HLSScrollViewController alloc] init] autorelease];
                    TextFieldsDemoViewController *demoViewController = [[[TextFieldsDemoViewController alloc] initLarge:YES] autorelease];
                    scrollViewController.insetViewController = demoViewController;
                    [self.navigationController pushViewController:scrollViewController animated:YES];
                    break;
                }
                    
                default: {
                    return;
                    break;
                }            
            }
            break;
        }
            
        case DemoCategoryIndexViewControllers: {
            switch (indexPath.row) {
                case ViewControllersDemoIndexPlaceholderViewController: {
                    PlaceholderDemoViewController *demoViewController = [[[PlaceholderDemoViewController alloc] init] autorelease];
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
                    
                case ViewControllersDemoIndexLifeCycleTestInScrollView: {
                    HLSScrollViewController *scrollViewController = [[[HLSScrollViewController alloc] init] autorelease];
                    LifeCycleTestViewController *demoViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
                    scrollViewController.insetViewController = demoViewController;
                    scrollViewController.adjustingInset = YES;
                    [self.navigationController pushViewController:scrollViewController animated:YES];
                    break;                    
                }
                    
                case ViewControllersDemoIndexFixedSizeLargeInScrollView: {
                    HLSScrollViewController *scrollViewController = [[[HLSScrollViewController alloc] init] autorelease];
                    FixedSizeViewController *demoViewController = [[[FixedSizeViewController alloc] initLarge:YES] autorelease];
                    scrollViewController.insetViewController = demoViewController;
                    [self.navigationController pushViewController:scrollViewController animated:YES];
                    break;
                }
                    
                case ViewControllersDemoIndexStretchableLargeInScrollView: {
                    HLSScrollViewController *scrollViewController = [[[HLSScrollViewController alloc] init] autorelease];
                    StretchableViewController *demoViewController = [[[StretchableViewController alloc] initLarge:YES] autorelease];
                    scrollViewController.insetViewController = demoViewController;
                    [self.navigationController pushViewController:scrollViewController animated:YES];
                    break;
                }
                    
                case ViewControllersDemoIndexOrientationLargeClonerInScrollView: {
                    HLSScrollViewController *scrollViewController = [[[HLSScrollViewController alloc] init] autorelease];
                    OrientationClonerViewController *demoViewController = [[[OrientationClonerViewController alloc] initWithPortraitOrientation:UIInterfaceOrientationIsPortrait(self.interfaceOrientation) 
                                                                                                                                          large:YES] autorelease];
                    scrollViewController.insetViewController = demoViewController;
                    [self.navigationController pushViewController:scrollViewController animated:YES];
                    break;                    
                }
                    
                case ViewControllersDemoIndexWizardViewController: {

                    break;
                }
                    
                case ViewControllersDemoIndexTableSearchDisplayViewController: {
                    TableSearchDisplayDemoViewController *demoViewController = [[[TableSearchDisplayDemoViewController alloc] init] autorelease];
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
                    
                case ViewControllersDemoIndexPageController: {

                    break;
                }
                    
                default: {
                    return;
                    break;
                }            
            }
            break;
        }
            
        default: {
            return;
            break;
        }
    }
}

@end
