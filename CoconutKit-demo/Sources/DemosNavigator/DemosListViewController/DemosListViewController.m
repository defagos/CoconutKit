//
//  DemosListViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "DemosListViewController.h"

#import "CursorDemoViewController.h"
#import "FixedSizeViewController.h"
#import "MultipleViewsAnimationDemoViewController.h"
#import "ParallelProcessingDemoViewController.h"
#import "PlaceholderDemoViewController.h"
#import "SingleViewAnimationDemoViewController.h"
#import "StackDemoViewController.h"
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
    ViewDemoIndexCursor,
    ViewDemoIndexEnumEnd,
    ViewDemoIndexEnumSize = ViewDemoIndexEnumEnd - ViewDemoIndexEnumBegin
} ViewDemoIndex;

// Demos for view controllers
typedef enum {
    ViewControllersDemoIndexEnumBegin = 0,
    ViewControllersDemoIndexPlaceholderViewController = ViewControllersDemoIndexEnumBegin,
    ViewControllersDemoIndexWizardViewController,
    ViewControllersDemoIndexStackController,
    ViewControllersDemoIndexTableSearchDisplayViewController,
    ViewControllersDemoIndexWebViewController,
//    ViewControllersDemoIndexPageController,
    ViewControllersDemoIndexEnumEnd,
    ViewControllersDemoIndexEnumSize = ViewControllersDemoIndexEnumEnd - ViewControllersDemoIndexEnumBegin
} ViewControllersDemoIndex;

@interface DemosListViewController ()

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation DemosListViewController

@synthesize tableView = m_tableView;

#pragma mark View lifecycle

- (void)loadView
{
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.view = self.tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = HLSTableViewCellHeight(HLSTableViewCell);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)releaseViews
{
    [super releaseViews];
    self.tableView = nil;
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
                    
                case ViewDemoIndexCursor: {
                    cell.textLabel.text = NSLocalizedString(@"Cursor", @"Cursor");
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
                    
                case ViewControllersDemoIndexStackController: {
                    cell.textLabel.text = @"HLSStackController";
                    break;
                }
                    
                case ViewControllersDemoIndexTableSearchDisplayViewController: {
                    cell.textLabel.text = @"HLSTableSearchDisplayController";
                    break;
                }
                
                case ViewControllersDemoIndexWebViewController: {
                    cell.textLabel.text = @"HLSWebViewController";
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
    UIViewController *demoViewController = nil;
    switch (indexPath.section) {
        case DemoCategoryIndexAnimation: {
            switch (indexPath.row) {
                case AnimationDemoIndexSingleView: {
                    demoViewController = [[[SingleViewAnimationDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case AnimationDemoIndexMultipleViews: {
                    demoViewController = [[[MultipleViewsAnimationDemoViewController alloc] init] autorelease];
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
                    demoViewController = [[[ParallelProcessingDemoViewController alloc] init] autorelease];
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
                    demoViewController = [[[TableViewCellsDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewDemoIndexTextFieldsFixed: {
                    demoViewController = [[[TextFieldsDemoViewController alloc] initLarge:NO] autorelease];
                    break;
                }
                    
                case ViewDemoIndexTextFieldsLarge: {
                    demoViewController = [[[TextFieldsDemoViewController alloc] initLarge:YES] autorelease];
                    break;
                } 
                    
                case ViewDemoIndexCursor: {
                    demoViewController = [[[CursorDemoViewController alloc] init] autorelease];
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
                    demoViewController = [[[PlaceholderDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewControllersDemoIndexWizardViewController: {
                    demoViewController = [[[WizardDemoViewController alloc] init] autorelease];
                    WizardDemoViewController *wizardDemoViewController = (WizardDemoViewController*)demoViewController;
                    wizardDemoViewController.stretchingContent = YES;
                    
                    WizardPageViewController *wizardPageViewController1 = [[[WizardPageViewController alloc] init] autorelease];
                    WizardPageViewController *wizardPageViewController2 = [[[WizardPageViewController alloc] init] autorelease];
                    WizardPageViewController *wizardPageViewController3 = [[[WizardPageViewController alloc] init] autorelease];
                    wizardDemoViewController.viewControllers = [NSArray arrayWithObjects:wizardPageViewController1,
                                                                wizardPageViewController2,
                                                                wizardPageViewController3,
                                                                nil];                    
                    break;
                }
                    
                case ViewControllersDemoIndexStackController: {
                    demoViewController = [[[StackDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewControllersDemoIndexTableSearchDisplayViewController: {
                    demoViewController = [[[TableSearchDisplayDemoViewController alloc] init] autorelease];
                    break;
                }
                
                case ViewControllersDemoIndexWebViewController: {
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://lestudio.hortis.ch"]];
                    demoViewController = [[[HLSWebViewController alloc] initWithRequest:request] autorelease];
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
	
	if (demoViewController) {
		demoViewController.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
		[self.navigationController pushViewController:demoViewController animated:YES];
	}
}

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Demos", @"Demos");
    [self.tableView reloadData];
}

@end
