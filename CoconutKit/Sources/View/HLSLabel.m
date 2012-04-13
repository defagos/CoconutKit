//
//  HLSLabel.m
//  CoconutKit
//
//  Created by Joris Heuberger on 12.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLabel.h"

/**
 * NSString Category that provides the necessary font size to fit in a given size
 *
 * Original author: Ortwin Gentz - http://stackoverflow.com/users/235297/ortwin-gentz
 * Reference: http://stackoverflow.com/questions/4382976/multiline-uilabel-with-adjustsfontsizetofitwidth
 */

@implementation NSString (fontSizeWithFont_constrainedToSize_)

- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
	CGFloat fontSize = [font pointSize];
	CGFloat height = [self sizeWithFont:font constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
	UIFont *newFont = font;
	
	//Reduce font size while too large, break if no height (empty string)
	while (height > size.height && height != 0)
	{   
		fontSize--;  
		newFont = [UIFont fontWithName:font.fontName size:fontSize];   
		height = [self sizeWithFont:newFont constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
	};
	
	// Loop through words in string and resize to fit
	for (NSString *word in [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])
	{
		CGFloat width = [word sizeWithFont:newFont].width;
		while (width > size.width && width != 0)
		{
			fontSize--;
			newFont = [UIFont fontWithName:font.fontName size:fontSize];   
			width = [word sizeWithFont:newFont].width;
		}
	}
	return fontSize;
}

@end


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
	if ((self = [super initWithFrame:frame]))
	{
		self.verticalAlignment = HLSLabelVerticalAlignmentMiddle;
	}
	return self;
}

- (void)awakeFromNib
{
    self.verticalAlignment = HLSLabelVerticalAlignmentMiddle;
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
		CGFloat fontSize = [text fontSizeWithFont:self.font constrainedToSize:self.frame.size];
		fontSize = (fontSize < self.minimumFontSize) ? self.minimumFontSize : fontSize;
		self.font = [UIFont fontWithName:self.font.fontName size:fontSize];
	}
}

@end
