//
//  DemosListViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "DemosListViewController.h"

#import "ActionSheetDemoViewController.h"
#import "CursorDemoViewController.h"
#import "DynamicLocalizationDemoViewController.h"
#import "ExpandingSearchBarDemoViewController.h"
#import "FixedSizeViewController.h"
#import "FontsDemoViewController.h"
#import "LabelDemoViewController.h"
#import "LayerPropertiesTestViewController.h"
#import "ParallaxScrollingDemoViewController.h"
#import "ParallelProcessingDemoViewController.h"
#import "PlaceholderDemoViewController.h"
#import "AnimationDemoViewController.h"
#import "SkinningDemoViewController.h"
#import "SlideshowDemoViewController.h"
#import "StackDemoViewController.h"
#import "TableSearchDisplayDemoViewController.h"
#import "TableViewCellsDemoViewController.h"
#import "TextFieldsDemoViewController.h"
#import "ViewEffectsDemoViewController.h"
#import "WebViewDemoViewController.h"
#import "WizardDemoViewController.h"

// Categories
typedef enum {
    DemoCategoryIndexEnumBegin = 0,
    DemoCategoryIndexAnimation = DemoCategoryIndexEnumBegin,
    DemoCategoryIndexCore,
    DemoCategoryIndexTask,
    DemoCategoryIndexView,
    DemoCategoryIndexViewControllers,
    DemoCategoryIndexEnumEnd,
    DemoCategoryIndexEnumSize = DemoCategoryIndexEnumEnd - DemoCategoryIndexEnumBegin
} DemoCategoryIndex;

// Demos for animation
typedef enum {
    AnimationDemoIndexEnumBegin = 0,
    AnimationDemoIndexAnimation = AnimationDemoIndexEnumBegin,
    AnimationDemoIndexLayerPropertiesTest,
    AnimationDemoIndexEnumEnd,
    AnimationDemoIndexEnumSize = AnimationDemoIndexEnumEnd - AnimationDemoIndexEnumBegin
} AnimationDemoIndex;

// Demos for core
typedef enum {
    CoreDemoIndexEnumBegin = 0,
    CoreDemoIndexDynamicLocalization = CoreDemoIndexEnumBegin,
    CoreDemoIndexFonts,
    CoreDemoIndexEnumEnd,
    CoreDemoIndexEnumSize = CoreDemoIndexEnumEnd - CoreDemoIndexEnumBegin
} CoreDemoIndex;

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
    ViewDemoIndexTextFields,
    ViewDemoIndexCursor,
    ViewDemoIndexLabel,
    ViewDemoIndexExpandingSearchBar,
    ViewDemoIndexActionSheet,
    ViewDemoIndexSlideshow,
    ViewDemoIndexSkinning,
    ViewDemoIndexEffects,
    ViewDemoIndexWebView,
    ViewDemoIndexParallaxScrolling,
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
    ViewControllersDemoIndexSegue,
    ViewControllersDemoIndexEnumEnd,
    ViewControllersDemoIndexEnumSize = ViewControllersDemoIndexEnumEnd - ViewControllersDemoIndexEnumBegin
} ViewControllersDemoIndex;

@interface DemosListViewController ()

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation DemosListViewController

@synthesize tableView = m_tableView;

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.tableView = nil;
}

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
    
    self.tableView.rowHeight = [HLSTableViewCell height];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
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
            
        case DemoCategoryIndexCore: {
            return NSLocalizedString(@"Core", @"Core");
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
            
        case DemoCategoryIndexCore: {
            return CoreDemoIndexEnumSize;
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
    UITableViewCell *cell = [HLSSubtitleTableViewCell cellForTableView:tableView];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case DemoCategoryIndexAnimation: {
            switch (indexPath.row) {
                case AnimationDemoIndexAnimation: {
                    cell.textLabel.text = NSLocalizedString(@"Animations", @"Animations");
                    break;
                }
                    
                case AnimationDemoIndexLayerPropertiesTest: {
                    cell.textLabel.text = NSLocalizedString(@"Layer properties test (not a CoconutKit component)", @"Layer properties test (not a CoconutKit component)");
                    break;
                }
                    
                default: {
                    return nil;
                    break;
                }            
            }
            break;
        }
            
        case DemoCategoryIndexCore: {
            switch (indexPath.row) {
                case CoreDemoIndexDynamicLocalization: {
                    cell.textLabel.text = NSLocalizedString(@"Dynamic localization", @"Dynamic localization");
                    break;
                }
                    
                case CoreDemoIndexFonts: {
                    cell.textLabel.text = NSLocalizedString(@"Fonts", @"Fonts");
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
                    
                case ViewDemoIndexTextFields: {
                    cell.textLabel.text = NSLocalizedString(@"Text fields", @"Text fields");
                    break;
                }
                    
                case ViewDemoIndexCursor: {
                    cell.textLabel.text = NSLocalizedString(@"Cursor", @"Cursor");
                    break;
                }
                
                case ViewDemoIndexLabel: {
                    cell.textLabel.text = NSLocalizedString(@"Label", @"Label");
                    break;
                }
                    
                case ViewDemoIndexExpandingSearchBar: {
                    cell.textLabel.text = NSLocalizedString(@"Search bar", @"Search bar");
                    break;
                }
                
                case ViewDemoIndexActionSheet: {
                    cell.textLabel.text = NSLocalizedString(@"Action sheet", @"Action sheet");
                    break;
                }
                    
                case ViewDemoIndexSlideshow: {
                    cell.textLabel.text = NSLocalizedString(@"Slideshow", @"Slideshow");
                    break;
                }
                    
                case ViewDemoIndexSkinning: {
                    cell.textLabel.text = NSLocalizedString(@"Skinning", @"Skinning");
                    break;
                }
                    
                case ViewDemoIndexEffects: {
                    cell.textLabel.text = NSLocalizedString(@"Effects", @"Effects");
                    break;
                }
                    
                case ViewDemoIndexWebView: {
                    cell.textLabel.text = NSLocalizedString(@"Web view", @"Web view");
                    break;
                }
                    
                case ViewDemoIndexParallaxScrolling: {
                    cell.textLabel.text = NSLocalizedString(@"Parallax scrolling", @"Parallax scrolling");
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
                    
                case ViewControllersDemoIndexSegue: {
                    cell.textLabel.textColor = [UIColor grayColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    // TODO: Cleanup this mess when CoconutKit compatible with iOS >= 5. Remove UIKit weak-linking in CoconutKit-demo
                    if ([UIStoryboard class]) {
                        // The compiled storyboard has a storyboardc extension
                        if ([[NSBundle mainBundle] pathForResource:@"SegueDemo" ofType:@"storyboardc"]) {
                            [UIStoryboard storyboardWithName:@"SegueDemo" bundle:nil];
                            
                            cell.textLabel.text = NSLocalizedString(@"Segues", @"Segues");
                            cell.textLabel.textColor = [UIColor blackColor];
                            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                        }
                        else {
                            cell.textLabel.text = NSLocalizedString(@"Segues (not available in bundle)", @"Segues (not available in bundle)");
                        }
                    }
                    else {
                        cell.textLabel.text = NSLocalizedString(@"Segues (not available for iOS 4)", @"Segues (not available for iOS 4)");
                    }
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
                case AnimationDemoIndexAnimation: {
                    demoViewController = [[[AnimationDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case AnimationDemoIndexLayerPropertiesTest: {
                    demoViewController = [[[LayerPropertiesTestViewController alloc] init] autorelease];
                    break;
                }
                    
                default: {
                    return;
                    break;
                }            
            }
            break;
        }
            
        case DemoCategoryIndexCore: {
            switch (indexPath.row) {
                case CoreDemoIndexDynamicLocalization: {
                    demoViewController = [[[DynamicLocalizationDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case CoreDemoIndexFonts: {
                    demoViewController = [[[FontsDemoViewController alloc] init] autorelease];
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
                    
                case ViewDemoIndexTextFields: {
                    demoViewController = [[[TextFieldsDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewDemoIndexCursor: {
                    demoViewController = [[[CursorDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewDemoIndexLabel: {
                    demoViewController = [[[LabelDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewDemoIndexExpandingSearchBar: {
                    demoViewController = [[[ExpandingSearchBarDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewDemoIndexActionSheet: {
                    ActionSheetDemoViewController *actionSheetDemoViewController = [[[ActionSheetDemoViewController alloc] init] autorelease];
                    UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
                    tabBarController.viewControllers = [NSArray arrayWithObject:actionSheetDemoViewController];
                    demoViewController = tabBarController;
                    break;
                }
                    
                case ViewDemoIndexSlideshow: {
                    demoViewController = [[[SlideshowDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewDemoIndexSkinning: {
                    demoViewController = [[[SkinningDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewDemoIndexEffects: {
                    demoViewController = [[[ViewEffectsDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewDemoIndexWebView: {
                    demoViewController = [[[WebViewDemoViewController alloc] init] autorelease];
                    break;
                }
                    
                case ViewDemoIndexParallaxScrolling: {
                    demoViewController = [[[ParallaxScrollingDemoViewController alloc] init] autorelease];
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
                    
                case ViewControllersDemoIndexSegue: {
                    // TODO: Cleanup this mess when CoconutKit compatible with iOS >= 5. Remove UIKit weak-linking in CoconutKit-demo
                    if ([UIStoryboard class]) {
                        // The compiled storyboard has a storyboardc extension
                        if ([[NSBundle mainBundle] pathForResource:@"SegueDemo" ofType:@"storyboardc"]) {
                            UIStoryboard *segueStoryboard = [UIStoryboard storyboardWithName:@"SegueDemo" bundle:nil];
                            demoViewController = [segueStoryboard instantiateInitialViewController];
                        }
                    }
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
