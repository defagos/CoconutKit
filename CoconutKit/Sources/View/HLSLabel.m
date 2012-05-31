//
//  HLSLabel.m
//  CoconutKit
//
//  Created by Joris Heuberger on 12.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLabel.h"

#import "NSString+HLSExtensions.h"

@implementation HLSLabel

@synthesize verticalAlignment = _verticalAlignment;

@end

/**
 * Vertical Alignement
 *
 * Original author: jhoncybpr - http://www.iphonedevsdk.com/forum/iphone-sdk-development/35532-uilabel-vertical-align-top.html 
 */

@implementation HLSLabel (VerticalAlignement)

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		self.verticalAlignment = HLSLabelVerticalAlignmentMiddle;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder])) {
		self.verticalAlignment = HLSLabelVerticalAlignmentMiddle;
	}
	return self;
}

- (void)setVerticalAlignment:(HLSLabelVerticalAlignment)verticalAlignment
{
	_verticalAlignment = verticalAlignment;
	[self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
	CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
	
	switch (self.verticalAlignment)
	{
		case HLSLabelVerticalAlignmentTop:
			textRect.origin.y = bounds.origin.y;
			break;
		case HLSLabelVerticalAlignmentBottom:
			textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
			break;
		case HLSLabelVerticalAlignmentMiddle:
			// Fall through.
		default:
			textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
	}
	return textRect;
}

- (void)drawTextInRect:(CGRect)requestedRect
{
	CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
	[super drawTextInRect:actualRect];
}
@end

/**
 * Adjusting Font Size
 *
 */

@implementation HLSLabel (AdjustFontSize)

- (void)setText:(NSString *)text
{
	[super setText:text];
	
	if (self.adjustsFontSizeToFitWidth)
	{
        CGSize size = CGSizeMake(self.frame.size.width*self.numberOfLines /* UGLY CHEAT -> */ * 0.9 /* <- UGLY CHEAT */, self.frame.size.height);
        CGFloat fontSize = [text fontSizeWithFont:self.font constrainedToSize:size minFontSize:self.minimumFontSize lineBreakMode:self.lineBreakMode];
		self.font = [UIFont fontWithName:self.font.fontName size:fontSize];
	}
}

@end
