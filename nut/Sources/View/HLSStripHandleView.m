//
//  HLSStripHandleView.m
//  nut-dev
//
//  Created by Samuel Défago on 07.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStripHandleView.h"

#import "HLSLogger.h"

@implementation HLSStripHandleView

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.exclusiveTouch = YES;
    }
    return self;
}

- (void)dealloc
{
    // Code
    
    [super dealloc];
}

#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    HLSLoggerInfo(@"Touches began");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    HLSLoggerInfo(@"Touches moved");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    HLSLoggerInfo(@"Touches ended");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    HLSLoggerInfo(@"Touches cancelled");
}

- (void)endTouches:(NSSet *)touches animated:(BOOL)animated
{
    HLSLoggerInfo(@"Touches ended");
}

@end
