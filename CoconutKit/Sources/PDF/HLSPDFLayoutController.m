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
#import "UILabel+HLSPDFLayout.h"
#import "UIView+HLSPDFLayout.h"

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
    
    // Remark: It would have been rather convenient if we could have called the drawRect: method directly. It does not
    //         seem to work (after some tests: everything is drawn at the origin, and view backgrounds are not filled), 
    //         though, therefore the need for a drawElement method. But this requires us to implement each 
    //         drawElement method manually (mirroring what drawRect: should do). This requires some more work but 
    //         allows us to taylor drawing as needed. Moreover, not so many drawElement methods have to be implemented, 
    //         this is not a no-go
    //         Some QuartzCore methods could maybe make implementing drawElement easy (especially [CALayer renderInContext:]).
    //         But replacing the drawElement call below by a renderInContext does not work correctly (well, almost): Masks
    //         are not applied to images, and the problem is that renderInContext renders the whole layer tree. It is
    //         therefore difficult to render such trees. Moreover, we want to be able to use nib and views to design
    //         the screen, but this means we do not necessarily want to create an exact clone of the view: We only want
    //         some properties to be copied, and some objects might be drawn differently (e.g. a table view)
    
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, self.layout.bounds, nil);
    
    UIGraphicsBeginPDFPage();
    
    [layout drawElement];
    
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
