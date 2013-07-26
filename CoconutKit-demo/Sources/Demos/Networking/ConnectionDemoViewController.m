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

@property (nonatomic, weak) HLSURLConnection *severalWeakRefParentConnection;
@property (nonatomic, strong) HLSURLConnection *severalStrongRefParentConnection;

@property (nonatomic, weak) HLSURLConnection *cascadeWeakRefParentConnection;
@property (nonatomic, strong) HLSURLConnection *cascadeStrongRefParentConnection;

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

- (void)dealloc
{
    HLSLoggerInfo(@"The connection demo view controller was properly deallocated");
}

#pragma mark View lifecycle

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        [self.singleWeakRefConnection cancel];
        
        [self.singleStrongRefConnection cancel];
        self.singleStrongRefConnection = nil;
        
        // Only need to cancel parent connections. Child connections will be cancelled as well
        [self.severalWeakRefParentConnection cancel];
        
        [self.severalStrongRefParentConnection cancel];
        self.severalStrongRefParentConnection = nil;
        
        [self.cascadeWeakRefParentConnection cancel];
        
        [self.cascadeStrongRefParentConnection cancel];
        self.cascadeStrongRefParentConnection = nil;
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
    HLSURLConnection *singleWeakRefConnection = [[HLSFileURLConnection alloc] initWithRequest:request completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
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
    self.singleStrongRefConnection = [[HLSFileURLConnection alloc] initWithRequest:request completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Done! %@", self);
        
        // The strong ref must be released
        self.singleStrongRefConnection = nil;
    }];
    [self.singleStrongRefConnection start];
}

- (IBAction)cancelSingleStrongRef:(id)sender
{
    [self.singleStrongRefConnection cancel];
    self.singleStrongRefConnection = nil;
}

- (IBAction)downloadSingleNoRef:(id)sender
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[ConnectionDemoViewController image1URL]];
    HLSURLConnection *singleNoRefConnection = [[HLSFileURLConnection alloc] initWithRequest:request completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Done! %@, connection = %@", self, connection);
    }];
    [singleNoRefConnection start];    
}

- (IBAction)downloadSeveralWeakRef:(id)sender
{
    NSURLRequest *parentRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image1URL]];
    HLSURLConnection *severalWeakRefParentConnection = [[HLSFileURLConnection alloc] initWithRequest:parentRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Parent done! %@", self);
    }];
    
    NSURLRequest *childRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image2URL]];
    HLSURLConnection *severalWeakRefChildConnection = [[HLSFileURLConnection alloc] initWithRequest:childRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Child done! %@", self);
    }];
    [severalWeakRefParentConnection addChildConnection:severalWeakRefChildConnection];
    
    self.severalWeakRefParentConnection = severalWeakRefParentConnection;
    [self.severalWeakRefParentConnection start];
}

- (IBAction)cancelSeveralWeakRef:(id)sender
{
    [self.severalWeakRefParentConnection cancel];
}

- (IBAction)downloadSeveralStrongRef:(id)sender
{
    NSURLRequest *parentRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image1URL]];
    self.severalStrongRefParentConnection = [[HLSFileURLConnection alloc] initWithRequest:parentRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Parent done! %@", self);
        
        // The strong ref must be released
        self.severalStrongRefParentConnection = nil;
    }];
    
    NSURLRequest *childRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image2URL]];
    HLSURLConnection *severalStrongRefChildConnection = [[HLSFileURLConnection alloc] initWithRequest:childRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Child done! %@", self);
    }];
    [self.severalStrongRefParentConnection addChildConnection:severalStrongRefChildConnection];
    
    [self.severalStrongRefParentConnection start];
}

- (IBAction)cancelSeveralStrongRef:(id)sender
{
    [self.severalStrongRefParentConnection cancel];
    self.severalStrongRefParentConnection = nil;
}

- (IBAction)downloadSeveralNoRef:(id)sender
{
    NSURLRequest *parentRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image1URL]];
    HLSURLConnection *severalStrongRefParentConnection = [[HLSFileURLConnection alloc] initWithRequest:parentRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Parent done! %@", self);
    }];
    
    NSURLRequest *childRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image2URL]];
    HLSURLConnection *severalStrongRefChildConnection = [[HLSFileURLConnection alloc] initWithRequest:childRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Child done! %@", self);
    }];
    [severalStrongRefParentConnection addChildConnection:severalStrongRefChildConnection];
    
    [severalStrongRefParentConnection start];
}

- (IBAction)downloadCascadingWeakRef:(id)sender
{
    NSURLRequest *parentRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image1URL]];
    HLSURLConnection *cascadeWeakRefParentConnection = [[HLSFileURLConnection alloc] initWithRequest:parentRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Parent done! %@", self);
        
        NSURLRequest *childRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image2URL]];
        HLSURLConnection *cascadeWeakRefChildConnection = [[HLSFileURLConnection alloc] initWithRequest:childRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
            NSLog(@"---> Child done! %@", self);
        }];
        // works, but not optimal IMHO: [self.cascadeWeakRefParentConnection addChildConnection:cascadeWeakRefChildConnection];
        [connection addChildConnection:cascadeWeakRefChildConnection];      // does not work: receiver is nil
    }];
    
    self.cascadeWeakRefParentConnection = cascadeWeakRefParentConnection;
    [self.cascadeWeakRefParentConnection start];
}

- (IBAction)cancelCascadingWeakRef:(id)sender
{
    [self.cascadeWeakRefParentConnection cancel];
}

- (IBAction)downloadCascadingStrongRef:(id)sender
{
    NSURLRequest *parentRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image1URL]];
    self.cascadeStrongRefParentConnection = [[HLSFileURLConnection alloc] initWithRequest:parentRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Parent done! %@", self);
        
        NSURLRequest *childRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image2URL]];
        HLSURLConnection *cascadeStrongRefChildConnection = [[HLSFileURLConnection alloc] initWithRequest:childRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
            NSLog(@"---> Child done! %@", self);
            self.cascadeStrongRefParentConnection = nil;
        }];
        [connection addChildConnection:cascadeStrongRefChildConnection];
    }];
    
    [self.cascadeStrongRefParentConnection start];
}

- (IBAction)cancelCascadingStrongRef:(id)sender
{
    [self.cascadeStrongRefParentConnection cancel];
    self.cascadeStrongRefParentConnection = nil;
}

- (IBAction)downloadCascadingNoRef:(id)sender
{
    NSURLRequest *parentRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image1URL]];
    HLSURLConnection *cascadeNoRefParentConnection = [[HLSFileURLConnection alloc] initWithRequest:parentRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
        NSLog(@"---> Parent done! %@", self);
        
        NSURLRequest *childRequest = [NSURLRequest requestWithURL:[ConnectionDemoViewController image2URL]];
        HLSURLConnection *cascadeNoRefChildConnection = [[HLSFileURLConnection alloc] initWithRequest:childRequest completionBlock:^(HLSConnection *connection, id responseObject, NSError *error) {
            NSLog(@"---> Child done! %@", self);
        }];
        [connection addChildConnection:cascadeNoRefChildConnection];
    }];
    
    [cascadeNoRefParentConnection start];
}

@end
