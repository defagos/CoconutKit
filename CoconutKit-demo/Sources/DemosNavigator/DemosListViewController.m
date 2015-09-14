//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "DemosListViewController.h"

#import "BindingsControlsDemoViewController.h"
#import "BindingsFailuresDemoViewController.h"
#import "BindingsPerformance1DemoViewController.h"
#import "BindingsPerformance2DemoViewController.h"
#import "BindingsProgrammaticDemoViewController.h"
#import "BindingsTransformersDemoViewController.h"
#import "BindingsViewsDemoViewController.h"
#import "CursorDemoViewController.h"
#import "DynamicLocalizationDemoViewController.h"
#import "FixedSizeViewController.h"
#import "FontsDemoViewController.h"
#import "KeyboardAvoidingScrollViewDemoViewController.h"
#import "LayerPropertiesTestViewController.h"
#import "NibViewAutolayoutDemoViewController.h"
#import "NibViewAutoresizingMasksDemoViewController.h"
#import "NibViewAutolayoutSimpleDemoViewController.h"
#import "NibViewAutoresizingMasksSimpleDemoViewController.h"
#import "ParallaxScrollingDemoViewController.h"
#import "ParallelProcessingDemoViewController.h"
#import "PlaceholderDemoViewController.h"
#import "AnimationDemoViewController.h"
#import "SlideshowDemoViewController.h"
#import "StackDemoViewController.h"
#import "TableSearchDisplayDemoViewController.h"
#import "BindingsViewsDemoViewController.h"
#import "TableViewCellsDemoViewController.h"
#import "ViewEffectsDemoViewController.h"
#import "WebViewDemoViewController.h"
#import "WizardDemoViewController.h"

// Categories
typedef NS_ENUM(NSInteger, DemoCategoryIndex) {
    DemoCategoryIndexEnumBegin = 0,
    DemoCategoryIndexAnimation = DemoCategoryIndexEnumBegin,
    DemoCategoryIndexBindings,
    DemoCategoryIndexCore,
    DemoCategoryIndexTask,
    DemoCategoryIndexView,
    DemoCategoryIndexViewControllers,
    DemoCategoryIndexEnumEnd,
    DemoCategoryIndexEnumSize = DemoCategoryIndexEnumEnd - DemoCategoryIndexEnumBegin
};

// Demos for animation
typedef NS_ENUM(NSInteger, AnimationDemoIndex) {
    AnimationDemoIndexEnumBegin = 0,
    AnimationDemoIndexAnimation = AnimationDemoIndexEnumBegin,
    AnimationDemoIndexLayerPropertiesTest,
    AnimationDemoIndexEnumEnd,
    AnimationDemoIndexEnumSize = AnimationDemoIndexEnumEnd - AnimationDemoIndexEnumBegin
};

// Demos for bindings
typedef enum {
    BindingsDemoIndexEnumBegin = 0,
    BindingsDemoIndexControls = BindingsDemoIndexEnumBegin,
    BindingsDemoIndexViews,
    BindingsDemoIndexTransformers,
    BindingsDemoIndexProgrammatic,
    BindingsDemoIndexPerformance1,
    BindingsDemoIndexPerformance2,
    BindingsDemoIndexFailures,
    BindingsDemoIndexEnumEnd,
    BindingsDemoIndexEnumSize = BindingsDemoIndexEnumEnd - BindingsDemoIndexEnumBegin
} BindingsDemoIndex;

// Demos for core
typedef NS_ENUM(NSInteger, CoreDemoIndex) {
    CoreDemoIndexEnumBegin = 0,
    CoreDemoIndexDynamicLocalization = CoreDemoIndexEnumBegin,
    CoreDemoIndexFonts,
    CoreDemoIndexEnumEnd,
    CoreDemoIndexEnumSize = CoreDemoIndexEnumEnd - CoreDemoIndexEnumBegin
};

// Demos for tasks
typedef NS_ENUM(NSInteger, TaskDemoIndex) {
    TaskDemoIndexEnumBegin = 0,
    TaskDemoIndexParallelProcessing = TaskDemoIndexEnumBegin,
    TaskDemoIndexEnumEnd,
    TaskDemoIndexEnumSize = TaskDemoIndexEnumEnd - TaskDemoIndexEnumBegin
};

// Demos for views
typedef NS_ENUM(NSInteger, ViewDemoIndex) {
    ViewDemoIndexEnumBegin = 0,
    ViewDemoIndexTableViewCells = ViewDemoIndexEnumBegin,
    ViewDemoIndexKeyboardAvoidingScrollView,
    ViewDemoIndexCursor,
    ViewDemoIndexSlideshow,
    ViewDemoIndexEffects,
    ViewDemoIndexWebView,
    ViewDemoIndexParallaxScrolling,
    ViewDemoIndexNibViewAutolayoutSimple,
    ViewDemoIndexNibViewAutoresizingMasksSimple,
    ViewDemoIndexNibViewAutolayout,
    ViewDemoIndexNibViewAutoresizingMasks,
    ViewDemoIndexEnumEnd,
    ViewDemoIndexEnumSize = ViewDemoIndexEnumEnd - ViewDemoIndexEnumBegin
};

// Demos for view controllers
typedef NS_ENUM(NSInteger, ViewControllersDemoIndex) {
    ViewControllersDemoIndexEnumBegin = 0,
    ViewControllersDemoIndexPlaceholderViewController = ViewControllersDemoIndexEnumBegin,
    ViewControllersDemoIndexWizardViewController,
    ViewControllersDemoIndexStackController,
    ViewControllersDemoIndexTableSearchDisplayViewController,
    ViewControllersDemoIndexWebViewController,
    ViewControllersDemoIndexSegue,
    ViewControllersDemoIndexEnumEnd,
    ViewControllersDemoIndexEnumSize = ViewControllersDemoIndexEnumEnd - ViewControllersDemoIndexEnumBegin
};

@interface DemosListViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation DemosListViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = [HLSTableViewCell height];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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
            return NSLocalizedString(@"Animation", nil);
            break;
        }
            
        case DemoCategoryIndexBindings: {
            return NSLocalizedString(@"Bindings", nil);
            break;
        }
            
        case DemoCategoryIndexCore: {
            return NSLocalizedString(@"Core", nil);
            break;
        }
            
        case DemoCategoryIndexTask: {
            return NSLocalizedString(@"Tasks", nil);
            break;
        }

        case DemoCategoryIndexView: {
            return NSLocalizedString(@"Views", nil);
            break;
        }

        case DemoCategoryIndexViewControllers: {
            return NSLocalizedString(@"View controllers", nil);
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
            
        case DemoCategoryIndexBindings: {
            return BindingsDemoIndexEnumSize;
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
                    cell.textLabel.text = NSLocalizedString(@"Animations", nil);
                    break;
                }
                    
                case AnimationDemoIndexLayerPropertiesTest: {
                    cell.textLabel.text = NSLocalizedString(@"Layer properties test (not a CoconutKit component)", nil);
                    break;
                }
                    
                default: {
                    return nil;
                    break;
                }            
            }
            break;
        }
            
        case DemoCategoryIndexBindings: {
            switch (indexPath.row) {
                case BindingsDemoIndexControls: {
                    cell.textLabel.text = NSLocalizedString(@"Controls", nil);
                    break;
                }
                    
                case BindingsDemoIndexViews: {
                    cell.textLabel.text = NSLocalizedString(@"Views", nil);
                    break;
                }
                    
                case BindingsDemoIndexTransformers: {
                    cell.textLabel.text = NSLocalizedString(@"Transformers", nil);
                    break;
                }
                    
                case BindingsDemoIndexProgrammatic: {
                    cell.textLabel.text = NSLocalizedString(@"Programmatic", nil);
                    break;
                }
                    
                case BindingsDemoIndexPerformance1: {
                    cell.textLabel.text = NSLocalizedString(@"Performance 1", nil);
                    break;
                }
                    
                case BindingsDemoIndexPerformance2: {
                    cell.textLabel.text = NSLocalizedString(@"Performance 2", nil);
                    break;
                }
                    
                case BindingsDemoIndexFailures: {
                    cell.textLabel.text = NSLocalizedString(@"Failures", nil);
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
                    cell.textLabel.text = NSLocalizedString(@"Dynamic localization", nil);
                    break;
                }
                    
                case CoreDemoIndexFonts: {
                    cell.textLabel.text = NSLocalizedString(@"Fonts", nil);
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
                    cell.textLabel.text = NSLocalizedString(@"Parallel processing", nil);
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
                    cell.textLabel.text = NSLocalizedString(@"Table view cells", nil);
                    break;
                }
                    
                case ViewDemoIndexKeyboardAvoidingScrollView: {
                    cell.textLabel.text = NSLocalizedString(@"Scroll view avoiding the keyboard", nil);
                    break;
                }
                    
                case ViewDemoIndexCursor: {
                    cell.textLabel.text = NSLocalizedString(@"Cursor", nil);
                    break;
                }
                                    
                case ViewDemoIndexSlideshow: {
                    cell.textLabel.text = NSLocalizedString(@"Slideshow", nil);
                    break;
                }
                    
                case ViewDemoIndexEffects: {
                    cell.textLabel.text = NSLocalizedString(@"Effects", nil);
                    break;
                }
                    
                case ViewDemoIndexWebView: {
                    cell.textLabel.text = NSLocalizedString(@"Web view", nil);
                    break;
                }
                    
                case ViewDemoIndexParallaxScrolling: {
                    cell.textLabel.text = NSLocalizedString(@"Parallax scrolling", nil);
                    break;
                }
                    
                case ViewDemoIndexNibViewAutolayoutSimple: {
                    cell.textLabel.text = NSLocalizedString(@"Nib view (autolayout, simple)", nil);
                    break;
                }
                    
                case ViewDemoIndexNibViewAutoresizingMasksSimple: {
                    cell.textLabel.text = NSLocalizedString(@"Nib view (autoresizing masks, simple)", nil);
                    break;
                }
                    
                case ViewDemoIndexNibViewAutolayout: {
                    cell.textLabel.text = NSLocalizedString(@"Nib view (autolayout)", nil);
                    break;
                }
                    
                case ViewDemoIndexNibViewAutoresizingMasks: {
                    cell.textLabel.text = NSLocalizedString(@"Nib view (autoresizing masks)", nil);
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
                    cell.textLabel.text = NSLocalizedString(@"Segues", nil);
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
                    demoViewController = [[AnimationDemoViewController alloc] init];
                    break;
                }
                    
                case AnimationDemoIndexLayerPropertiesTest: {
                    demoViewController = [[LayerPropertiesTestViewController alloc] init];
                    break;
                }
                    
                default: {
                    return;
                    break;
                }            
            }
            break;
        }
            
        case DemoCategoryIndexBindings: {
            switch (indexPath.row) {
                case BindingsDemoIndexControls: {
                    demoViewController = [[BindingsControlsDemoViewController alloc] init];
                    break;
                }
                    
                case BindingsDemoIndexViews: {
                    demoViewController = [[BindingsViewsDemoViewController alloc] init];
                    break;
                }
                    
                case BindingsDemoIndexTransformers: {
                    demoViewController = [[BindingsTransformersDemoViewController alloc] init];
                    break;
                }
                    
                case BindingsDemoIndexProgrammatic: {
                    demoViewController = [[BindingsProgrammaticDemoViewController alloc] init];
                    break;
                }
                    
                case BindingsDemoIndexPerformance1: {
                    demoViewController = [[BindingsPerformance1DemoViewController alloc] init];
                    break;
                }
                    
                case BindingsDemoIndexPerformance2: {
                    demoViewController = [[BindingsPerformance2DemoViewController alloc] init];
                    break;
                }
                    
                case BindingsDemoIndexFailures: {
                    demoViewController = [[BindingsFailuresDemoViewController alloc] init];
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
                    demoViewController = [[DynamicLocalizationDemoViewController alloc] init];
                    break;
                }
                    
                case CoreDemoIndexFonts: {
                    demoViewController = [[FontsDemoViewController alloc] init];
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
                    demoViewController = [[ParallelProcessingDemoViewController alloc] init];
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
                    demoViewController = [[TableViewCellsDemoViewController alloc] init];
                    break;
                }
                    
                case ViewDemoIndexKeyboardAvoidingScrollView: {
                    demoViewController = [[KeyboardAvoidingScrollViewDemoViewController alloc] init];
                    break;
                }
                    
                case ViewDemoIndexCursor: {
                    demoViewController = [[CursorDemoViewController alloc] init];
                    break;
                }
                    
                case ViewDemoIndexSlideshow: {
                    demoViewController = [[SlideshowDemoViewController alloc] init];
                    break;
                }
                
                case ViewDemoIndexEffects: {
                    demoViewController = [[ViewEffectsDemoViewController alloc] init];
                    break;
                }
                    
                case ViewDemoIndexWebView: {
                    demoViewController = [[WebViewDemoViewController alloc] init];
                    break;
                }
                    
                case ViewDemoIndexParallaxScrolling: {
                    demoViewController = [[ParallaxScrollingDemoViewController alloc] init];
                    break;
                }
                    
                case ViewDemoIndexNibViewAutolayoutSimple: {
                    demoViewController = [[NibViewAutolayoutSimpleDemoViewController alloc] init];
                    break;
                }
                    
                case ViewDemoIndexNibViewAutoresizingMasksSimple: {
                    demoViewController = [[NibViewAutoresizingMasksSimpleDemoViewController alloc] init];
                    break;
                }
                    
                case ViewDemoIndexNibViewAutolayout: {
                    demoViewController = [[NibViewAutolayoutDemoViewController alloc] init];
                    break;
                }
                    
                case ViewDemoIndexNibViewAutoresizingMasks: {
                    demoViewController = [[NibViewAutoresizingMasksDemoViewController alloc] init];
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
                    demoViewController = [[PlaceholderDemoViewController alloc] init];
                    break;
                }
                    
                case ViewControllersDemoIndexWizardViewController: {
                    demoViewController = [[WizardDemoViewController alloc] init];
                    break;
                }
                    
                case ViewControllersDemoIndexStackController: {
                    demoViewController = [[StackDemoViewController alloc] init];
                    break;
                }
                    
                case ViewControllersDemoIndexTableSearchDisplayViewController: {
                    demoViewController = [[TableSearchDisplayDemoViewController alloc] init];
                    break;
                }
                
                case ViewControllersDemoIndexWebViewController: {
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.apple.com"]];
                    demoViewController = [[HLSWebViewController alloc] initWithRequest:request];
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
		demoViewController.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems;
		[self.navigationController pushViewController:demoViewController animated:YES];
	}
}

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Demos", nil);
    [self.tableView reloadData];
}

@end
