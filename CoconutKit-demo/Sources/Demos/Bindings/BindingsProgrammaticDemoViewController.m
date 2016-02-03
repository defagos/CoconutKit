//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "BindingsProgrammaticDemoViewController.h"

@interface BindingsProgrammaticDemoViewController ()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) float completion;
@property (nonatomic, assign) float completion2;

@property (nonatomic, weak) UISlider *slider;
@property (nonatomic, weak) UIProgressView *progressView;

@end

@implementation BindingsProgrammaticDemoViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.date = [NSDate date];
    }
    return self;
}

- (void)loadView
{
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:applicationFrame];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 40.f)];
    label.center = CGPointMake(CGRectGetMidX(view.bounds), 200.f);
    [label bindToKeyPath:@"date" withTransformer:@"DemoTransformer:mediumDateFormatter"];
    [view addSubview:label];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 40.f)];
    slider.center = CGPointMake(CGRectGetMidX(view.bounds), 300.f);
    [slider bindToKeyPath:@"completion" withTransformer:nil];
    [view addSubview:slider];
    self.slider = slider;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 40.f)];
    progressView.center = CGPointMake(CGRectGetMidX(view.bounds), 400.f);
    [progressView bindToKeyPath:@"completion" withTransformer:nil];
    [view addSubview:progressView];
    self.progressView = progressView;
    
    UIButton *rebindButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [rebindButton setTitle:NSLocalizedString(@"Rebind", nil) forState:UIControlStateNormal];
    rebindButton.bounds = CGRectMake(0.f, 0.f, 200.f, 40.f);
    rebindButton.center = CGPointMake(CGRectGetMidX(view.bounds), 500.f);
    [rebindButton addTarget:self action:@selector(rebind:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:rebindButton];
    
    self.view = view;
}

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Programmatic", nil);
}

- (void)rebind:(id)sender
{
    [self.slider bindToKeyPath:@"completion2" withTransformer:nil];
    [self.progressView bindToKeyPath:@"completion2" withTransformer:nil];
}

@end
