//
//  DemosListViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "DemosListViewController.h"

#import "FixedSizeViewController.h"
#import "MultipleViewsAnimationDemoViewController.h"
#import "ParallelProcessingDemoViewController.h"
#import "PlaceholderDemoViewController.h"
#import "SingleViewAnimationDemoViewController.h"
#import "TableSearchDisplayDemoViewController.h"
#import "TableViewCellsDemoViewController.h"
#import "TextFieldsDemoViewController.h"
#import "WizardDemoViewController.h"
#import "WizardPageViewController.h"

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
    ViewDemoIndexTextFieldsLarge,
    ViewDemoIndexEnumEnd,
    ViewDemoIndexEnumSize = ViewDemoIndexEnumEnd - ViewDemoIndexEnumBegin
} ViewDemoIndex;

// Demos for view controllers
typedef enum {
    ViewControllersDemoIndexEnumBegin = 0,
    ViewControllersDemoIndexPlaceholderViewController = ViewControllersDemoIndexEnumBegin,
    ViewControllersDemoIndexWizardViewController,
    ViewControllersDemoIndexTableSearchDisplayViewController,
//    ViewControllersDemoIndexPageController,
    ViewControllersDemoIndexEnumEnd,
    ViewControllersDemoIndexEnumSize = ViewControllersDemoIndexEnumEnd - ViewControllersDemoIndexEnumBegin
} ViewControllersDemoIndex;

@implementation DemosListViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Demos", @"Demos");
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = HLSTableViewCellHeight(HLSTableViewCell);
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
    UITableViewCell *cell = HLSTableViewCellGet(HLSSubtitleTableViewCell, tableView);
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
                    
                case ViewDemoIndexTextFieldsLarge: {
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
                    
                case ViewControllersDemoIndexWizardViewController: {
                    cell.textLabel.text = @"HLSWizardViewController";
                    break;
                }
                    
                case ViewControllersDemoIndexTableSearchDisplayViewController: {
                    cell.textLabel.text = @"HLSTableSearchDisplayController";
                    break;
                }
#if 0
                case ViewControllersDemoIndexPageController: {
                    cell.textLabel.text = @"HLSPageController";
                    break;
                }
#endif                    
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
                    TextFieldsDemoViewController *demoViewController = [[[TextFieldsDemoViewController alloc] initLarge:NO] autorelease];
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
                    
                case ViewDemoIndexTextFieldsLarge: {
                    TextFieldsDemoViewController *demoViewController = [[[TextFieldsDemoViewController alloc] initLarge:YES] autorelease];
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
            
        case DemoCategoryIndexViewControllers: {
            switch (indexPath.row) {
                case ViewControllersDemoIndexPlaceholderViewController: {
                    PlaceholderDemoViewController *demoViewController = [[[PlaceholderDemoViewController alloc] init] autorelease];
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
                    
                case ViewControllersDemoIndexWizardViewController: {
                    WizardDemoViewController *demoViewController = [[[WizardDemoViewController alloc] init] autorelease];
                    demoViewController.adjustingInset = YES;
                    
                    WizardPageViewController *wizardPageViewController1 = [[[WizardPageViewController alloc] init] autorelease];
                    WizardPageViewController *wizardPageViewController2 = [[[WizardPageViewController alloc] init] autorelease];
                    WizardPageViewController *wizardPageViewController3 = [[[WizardPageViewController alloc] init] autorelease];
                    demoViewController.viewControllers = [NSArray arrayWithObjects:wizardPageViewController1,
                                                          wizardPageViewController2,
                                                          wizardPageViewController3,
                                                          nil];                    
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
                    
                case ViewControllersDemoIndexTableSearchDisplayViewController: {
                    TableSearchDisplayDemoViewController *demoViewController = [[[TableSearchDisplayDemoViewController alloc] init] autorelease];
                    [self.navigationController pushViewController:demoViewController animated:YES];
                    break;
                }
#if 0
                case ViewControllersDemoIndexPageController: {

                    break;
                }
#endif                    
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
