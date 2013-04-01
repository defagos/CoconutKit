//
//  ConnectionDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 29.03.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "ConnectionDemoViewController.h"

@interface ConnectionDemoViewController ()

@property (nonatomic, weak) HLSURLConnection *singleWeakRefConnection;
@property (nonatomic, strong) HLSURLConnection *singleStrongRefConnection;

@end

@implementation ConnectionDemoViewController

#pragma mark Class methods

+ (NSURL *)image1URL
{
    return [[NSBundle mainBundle] URLForResource:@"img_apple1" withExtension:@"jpg"];
}

+ (NSURL *)image2URL
{
    return [[NSBundle mainBundle] URLForResource:@"img_apple2" withExtension:@"jpg"];
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        // Code
    }
    return self;
}

- (void)dealloc
{
    HLSLoggerInfo(@"The connection demo view controller was properly deallocated");
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Code
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        [self.singleWeakRefConnection cancel];
        [self.singleStrongRefConnection cancel];
    }
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Connection", nil);
}

#pragma mark Action callbacks

- (IBAction)downloadSingleWeakRef:(id)sender
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[ConnectionDemoViewController image1URL]];
    HLSURLConnection *singleWeakRefConnection = [[HLSMockDiskConnection alloc] initWithRequest:request completionBlock:^(id responseObject, NSError *error) {
        NSLog(@"---> Done! %@", self);
    }];
    [singleWeakRefConnection start];
    self.singleWeakRefConnection = singleWeakRefConnection;
}

- (IBAction)cancelSingleWeakRef:(id)sender
{
    [self.singleWeakRefConnection cancel];
}

- (IBAction)downloadSingleStrongRef:(id)sender
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[ConnectionDemoViewController image1URL]];
    self.singleStrongRefConnection = [[HLSMockDiskConnection alloc] initWithRequest:request completionBlock:^(id responseObject, NSError *error) {
        NSLog(@"---> Done! %@", self);
        
        // The strong ref must be released
        self.singleStrongRefConnection = nil;
    }];
    [self.singleStrongRefConnection start];
}

- (IBAction)cancelSingleStrongRef:(id)sender
{
    [self.singleStrongRefConnection cancel];
}

- (IBAction)downloadSingleNoRef:(id)sender
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[ConnectionDemoViewController image1URL]];
    HLSURLConnection *singleNoRefConnection = [[HLSMockDiskConnection alloc] initWithRequest:request completionBlock:^(id responseObject, NSError *error) {
        NSLog(@"---> Done! %@", self);
    }];
    [singleNoRefConnection start];    
}

- (IBAction)downloadSeveralWeakRef:(id)sender
{

}

- (IBAction)cancelSeveralWeakRef:(id)sender
{

}

- (IBAction)downloadSeveralStrongRef:(id)sender
{

}

- (IBAction)cancelSeveralStrongRef:(id)sender
{

}

- (IBAction)downloadSeveralNoRef:(id)sender
{

}

- (IBAction)downloadCascadingWeakRef:(id)sender
{

}

- (IBAction)cancelCascadingWeakRef:(id)sender
{

}

- (IBAction)downloadCascadingStrongRef:(id)sender
{

}

- (IBAction)cancelCascadingStrongRef:(id)sender
{

}

- (IBAction)downloadCascadingNoRef:(id)sender
{

}

@end
