//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewBindingHelpViewController.h"

#import "HLSViewBindingDebugOverlayApperance.h"
#import "NSBundle+HLSExtensions.h"

@interface HLSViewBindingHelpViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UIView *automaticView;
@property (nonatomic, weak) IBOutlet UIView *manualView;

@property (nonatomic, weak) IBOutlet UIView *unverifiedView;
@property (nonatomic, weak) IBOutlet UIView *validView;
@property (nonatomic, weak) IBOutlet UIView *invalidView;

@property (nonatomic, weak) IBOutlet UIView *outputOnlyView;
@property (nonatomic, weak) IBOutlet UIView *inputAndOutputView;

@end

@implementation HLSViewBindingHelpViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super initWithBundle:[NSBundle coconutKitBundle]]) {
        self.title = NSLocalizedString(@"Help", nil);
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.contentSize = self.contentView.bounds.size;
    [self.scrollView addSubview:self.contentView];
    
    self.automaticView.backgroundColor = [UIColor clearColor];
    self.automaticView.layer.borderWidth = HLSViewBindingDebugOverlayBorderWidth(YES);
    
    self.manualView.backgroundColor = [UIColor clearColor];
    self.manualView.layer.borderWidth = HLSViewBindingDebugOverlayBorderWidth(NO);
    
    self.unverifiedView.backgroundColor = HLSViewBindingDebugOverlayBorderColor(NO, NO);
    self.validView.backgroundColor = HLSViewBindingDebugOverlayBorderColor(YES, NO);
    self.invalidView.backgroundColor = HLSViewBindingDebugOverlayBorderColor(YES, YES);
    
    self.outputOnlyView.backgroundColor = [[UIColor colorWithPatternImage:HLSViewBindingDebugOverlayStripesPatternImage()] colorWithAlphaComponent:0.3f];
    self.inputAndOutputView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:HLSViewBindingDebugOverlayAlpha()];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scrollView flashScrollIndicators];
}

@end
