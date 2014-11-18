//
//  HLSSPushSegue.m
//  CoconutKit
//
//  Created by Samuel Défago on 27.06.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSStackPushSegue.h"

#import "HLSLogger.h"
#import "HLSStackController.h"

NSString * const HLSStackRootSegueIdentifier = @"hls_root";

@interface HLSStackPushStandardSegue ()

@property (nonatomic, assign) Class transitionClass;

@end

@implementation HLSStackPushSegue

#pragma mark Object creation and destruction

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    if (self = [super initWithIdentifier:identifier source:source destination:destination]) {
        self.transitionClass = [HLSTransitionNone class];
        self.duration = kAnimationTransitionDefaultDuration;
        self.animated = YES;
    }
    return self;
}

#pragma mark Overrides

- (void)perform
{
    HLSStackController *stackController = nil;
    
    // The source is a stack controller. The 'hls_root' segue is used to set its root view controller
    if ([self.sourceViewController isKindOfClass:[HLSStackController class]]) {
        stackController = self.sourceViewController;
        if (! [self.identifier isEqualToString:HLSStackRootSegueIdentifier]) {
            HLSLoggerError(@"The push segue attached to a stack controller must be called '%@'", HLSStackRootSegueIdentifier);
            return;
        }
        
        if ([[stackController viewControllers] count] != 0) {
            HLSLoggerError(@"The segue called '%@' can only be used to set a root view controller. No view controller "
                           "must have been loaded before", HLSStackRootSegueIdentifier);
            return;
        }
    }
    // The source is an arbitrary view controller. Check that it is embedded into a stack controller, and
    // push the destination view controller into it
    else {
        UIViewController *sourceViewController = self.sourceViewController;
        if (! sourceViewController.stackController) {
            HLSLoggerError(@"The source view controller is not embedded into a stack controller");
            return;
        }
        
        stackController = sourceViewController.stackController;
    }
    
    [stackController pushViewController:self.destinationViewController
                    withTransitionClass:self.transitionClass
                               duration:self.duration
                               animated:self.animated];
}

@end

@implementation HLSStackPushStandardSegue

#pragma mark Object creation and destruction

- (instancetype)initWithIdentifier:(NSString *)identifier
                            source:(UIViewController *)source
                       destination:(UIViewController *)destination
                   transitionClass:(Class)transitionClass
{
    if (self = [super initWithIdentifier:identifier source:source destination:destination]) {
        self.transitionClass = transitionClass;
        self.duration = kAnimationTransitionDefaultDuration;
        self.animated = YES;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [self initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionNone class]];
}

#pragma mark Overrides

- (void)perform
{
    HLSStackPushSegue *pushSegue = [[HLSStackPushSegue alloc] initWithIdentifier:self.identifier source:self.sourceViewController destination:self.destinationViewController];
    pushSegue.transitionClass = self.transitionClass;
    pushSegue.duration = self.duration;
    pushSegue.animated = self.animated;
    [pushSegue perform];
}

@end

@implementation UIViewController (HLSStackControllerSegueUnwinding)

- (IBAction)unwindToPreviousViewControllerInStackControllerAnimated:(UIStoryboardSegue *)sender
{
    NSAssert(self.stackController, @"The view controller must be contained within a stack controller");
    [self.stackController popViewControllerAnimated:YES];
}

- (IBAction)unwindToPreviousViewControllerInStackControllerNotAnimated:(UIStoryboardSegue *)sender
{
    NSAssert(self.stackController, @"The view controller must be contained within a stack controller");
    [self.stackController popViewControllerAnimated:NO];
}

- (IBAction)unwindToRootViewControllerInStackControllerAnimated:(UIStoryboardSegue *)sender
{
    NSAssert(self.stackController, @"The view controller must be contained within a stack controller");
    [self.stackController popToRootViewControllerAnimated:YES];
}

- (IBAction)unwindToRootViewControllerInStackControllerNotAnimated:(UIStoryboardSegue *)sender
{
    NSAssert(self.stackController, @"The view controller must be contained within a stack controller");
    [self.stackController popToRootViewControllerAnimated:NO];
}

@end

@implementation HLSStackCoverFromBottomSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottom class]];
}

@end

@implementation HLSStackCoverFromTopSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromTop class]];
}

@end

@implementation HLSStackCoverFromLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromLeft class]];
}

@end

@implementation HLSStackCoverFromRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromRight class]];
}

@end

@implementation HLSStackCoverFromTopLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromTopLeft class]];
}

@end

@implementation HLSStackCoverFromTopRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromTopRight class]];
}

@end

@implementation HLSStackCoverFromBottomLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottomLeft class]];
}

@end

@implementation HLSStackCoverFromBottomRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottomRight class]];
}

@end

@implementation HLSStackCoverFromBottomPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottomPushToBack class]];
}

@end

@implementation HLSStackCoverFromTopPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromTopPushToBack class]];
}

@end

@implementation HLSStackCoverFromLeftPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromLeftPushToBack class]];
}

@end

@implementation HLSStackCoverFromRightPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromRightPushToBack class]];
}

@end

@implementation HLSStackCoverFromTopLeftPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromLeftPushToBack class]];
}

@end

@implementation HLSStackCoverFromTopRightPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromTopRightPushToBack class]];
}

@end

@implementation HLSStackCoverFromBottomLeftPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottomLeftPushToBack class]];
}

@end

@implementation HLSStackCoverFromBottomRightPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottomRightPushToBack class]];
}

@end

@implementation HLSStackFadeInSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFadeIn class]];
}

@end

@implementation HLSStackFadeInPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFadeInPushToBack class]];
}

@end

@implementation HLSStackCrossDissolveSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCrossDissolve class]];
}

@end

@implementation HLSStackPushFromBottomSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromBottom class]];
}

@end

@implementation HLSStackPushFromTopSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromTop class]];
}

@end

@implementation HLSStackPushFromLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromLeft class]];
}

@end

@implementation HLSStackPushFromRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromRight class]];
}

@end

@implementation HLSStackPushFromBottomFadeInSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromBottomFadeIn class]];
}

@end

@implementation HLSStackPushFromTopFadeInSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromTopFadeIn class]];
}

@end

@implementation HLSStackPushFromLeftFadeInSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromLeftFadeIn class]];
}

@end

@implementation HLSStackPushFromRightFadeInSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromRightFadeIn class]];
}

@end

@implementation HLSStackPushToBackFromBottomSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushToBackFromBottom class]];
}

@end

@implementation HLSStackPushToBackFromTopSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushToBackFromTop class]];
}

@end

@implementation HLSStackPushToBackFromLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushToBackFromLeft class]];
}

@end

@implementation HLSStackPushToBackFromRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushToBackFromRight class]];
}

@end

@implementation HLSStackFlowFromBottomSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlowFromBottom class]];
}

@end

@implementation HLSStackFlowFromTopSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlowFromTop class]];
}

@end

@implementation HLSStackFlowFromLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlowFromLeft class]];
}

@end

@implementation HLSStackFlowFromRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlowFromRight class]];
}

@end

@implementation HLSStackEmergeFromCenterSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionEmergeFromCenter class]];
}

@end

@implementation HLSStackEmergeFromCenterPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionEmergeFromCenterPushToBack class]];
}

@end

@implementation HLSStackFlipVerticallySegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlipVertically class]];
}

@end

@implementation HLSStackFlipHorizontallySegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlipHorizontally class]];
}

@end

@implementation HLSStackRotateHorizontallyFromBottomCounterclockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateHorizontallyFromBottomCounterclockwise class]];
}

@end

@implementation HLSStackRotateHorizontallyFromBottomClockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateHorizontallyFromBottomClockwise class]];
}

@end

@implementation HLSStackRotateHorizontallyFromTopCounterclockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateHorizontallyFromTopCounterclockwise class]];
}

@end

@implementation HLSStackRotateHorizontallyFromTopClockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateHorizontallyFromTopClockwise class]];
}

@end

@implementation HLSStackRotateVerticallyFromLeftCounterclockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateVerticallyFromLeftCounterclockwise class]];
}

@end

@implementation HLSStackRotateVerticallyFromLeftClockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateVerticallyFromLeftClockwise class]];
}

@end

@implementation HLSStackRotateVerticallyFromRightCounterclockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateVerticallyFromRightCounterclockwise class]];
}

@end

@implementation HLSStackRotateVerticallyFromRightClockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateVerticallyFromRightClockwise class]];
}

@end
