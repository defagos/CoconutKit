//
//  HLSPDFLayoutController.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSPDFLayoutController.h"

#import "HLSLogger.h"
#import "NSObject+HLSExtensions.h"

@interface HLSPDFLayoutController ()

- (NSString *)findNibName;

@end

@implementation HLSPDFLayoutController

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.layout = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize layout = m_layout;

- (HLSPDFLayout *)layout
{
    if (! [self isLayoutLoaded]) {
        NSString *nibName = [self findNibName];
        
        // A nib file is used. Load it (this will bind outlets as well. This should especially bind the layout outlet)
        if (nibName) {
            [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        }
        // Created programmatically
        else {
            [self loadLayout];
        }
        
        // Now the layout must have been loaded, otherwise something went wrong (e.g. the user implemented
        // loadLayout but did not assign anything to the layout property)
        if (! [self isLayoutLoaded]) {
            NSString *reason = [NSString stringWithFormat:@"No layout has been provided. Did you bind the layout outlet "
                                "(layout created using a nib)? Did you set the layout property in loadLayout (layout created"
                                "programmatically)?"];
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];            
        }
        
        [self layoutDidLoad];
    }
    return m_layout;
}

- (void)setLayout:(HLSPDFLayout *)layout
{    
    if (m_layout == layout) {
        return;
    }
    
    [m_layout release];
    m_layout = [layout retain];
    
    m_layoutLoaded = (m_layout != nil);
}

- (NSString *)nibName
{
    return [self className];
}

- (void)loadLayout
{
    // This method does nothing. Implemented by subclasses
}

- (BOOL)isLayoutLoaded
{
    return m_layoutLoaded;
}

- (void)layoutDidLoad
{
    // This method does nothing. Implemented by subclasses
}

#pragma mark PDF generation

- (NSData *)generatePDFData
{
    HLSPDFLayout *layout = self.layout;
    if (! layout) {
        HLSLoggerError(@"No layout available");
        return nil;
    }
    
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, self.layout.frame, nil);
    
    UIGraphicsBeginPDFPage();
    
    // TODO: Must be recursive, relative to parent view coosys, etc.. Just a test here :-)
    for (UIView *view in self.layout.subviews) {
        if (! [view conformsToProtocol:@protocol(HLSPDFLayoutElement)]) {
            HLSLoggerWarn(@"The view %@ is not a layout element. Ignored");
            continue;
        }
        
        UIView<HLSPDFLayoutElement> *layoutElement = (UIView<HLSPDFLayoutElement> *)view;
        [layoutElement draw];
    }
    
    // This write the pdf data
    UIGraphicsEndPDFContext();
    return [NSData dataWithData:pdfData];
}

- (BOOL)generateAndSavePDFFileToPath:(NSString *)path
{
    NSData *pdfData = [self generatePDFData];
    if (! pdfData) {
        return NO;
    }
    
    if (! [pdfData writeToFile:path atomically:NO]) {
        HLSLoggerError(@"Could not save pdf data to %@", path);
        return NO;
    }
    
    return YES;
}

#pragma mark Nib lookup

- (NSString *)findNibName
{
    // If a nib file name has been specified, use it, otherwise try to locate the default one (nib bearing
    // the class name)
    NSString *nibName = [self nibName];
    if (! nibName && [[NSBundle mainBundle] pathForResource:[self className] ofType:@"nib"]) {
        nibName = [self className];
    }
    return nibName;
}

@end
