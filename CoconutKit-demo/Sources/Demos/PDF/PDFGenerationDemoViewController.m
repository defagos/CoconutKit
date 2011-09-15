//
//  PDFGenerationDemoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 14.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "PDFGenerationDemoViewController.h"

#import "PDFGenerationDemoLayoutController.h"

@interface PDFGenerationDemoViewController ()

- (void)generateButtonClicked:(id)sender;

@end

@implementation PDFGenerationDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
    }
    return self;
}

- (void)dealloc
{
    // Code
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.generateButton = nil;
}

#pragma mark Accessors and mutators

@synthesize generateButton = m_generateButton;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.generateButton addTarget:self
                            action:@selector(generateButtonClicked:) 
                  forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"PDF generation", @"PDF generation");
}

#pragma mark Event callbacks

- (void)generateButtonClicked:(id)sender
{
    PDFGenerationDemoLayoutController *layoutController = [[[PDFGenerationDemoLayoutController alloc] init] autorelease];
    
    NSString *outputPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.pdf"];
    [layoutController generateAndSavePDFFileToPath:outputPath];
}

@end
