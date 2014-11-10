//
//  LabelBindingsDemo6ViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Defago on 07/11/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "LabelBindingsDemo6ViewController.h"

@interface LabelBindingsDemo6ViewController ()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) float completion;

@end

@implementation LabelBindingsDemo6ViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.date = [NSDate date];
    }
    return self;
}

- (void)loadView
{
#if 0
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:applicationFrame];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 40.f)];
    label.center = CGPointMake(CGRectGetMidX(view.bounds), 200.f);
    [label bindToKeyPath:@"date" withTransformer:@"+[DemoTransformer mediumDateFormatter]"];
    [view addSubview:label];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 40.f)];
    slider.center = CGPointMake(CGRectGetMidX(view.bounds), 300.f);
    [slider bindToKeyPath:@"completion" withTransformer:nil];
    [view addSubview:slider];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 40.f)];
    progressView.center = CGPointMake(CGRectGetMidX(view.bounds), 400.f);
    [progressView bindToKeyPath:@"completion" withTransformer:nil];
    [view addSubview:progressView];
    
    self.view = view;
#endif
}

@end
