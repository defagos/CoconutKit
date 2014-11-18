//
//  HLSPlaceholderInsetSegue.m
//  CoconutKit
//
//  Created by Samuel Défago on 28.06.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSPlaceholderInsetSegue.h"

#import "HLSLogger.h"
#import "HLSPlaceholderViewController.h"

NSString * const HLSPlaceholderPreloadSegueIdentifierPrefix = @"hls_preload_at_index_";

@interface HLSPlaceholderInsetStandardSegue ()

@property (nonatomic, assign) Class transitionClass;

@end

@implementation HLSPlaceholderInsetSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    if (self = [super initWithIdentifier:identifier source:source destination:destination]) {
        self.index = 0;
        self.transitionClass = [HLSTransitionNone class];
        self.duration = kAnimationTransitionDefaultDuration;
        self.animated = YES;
    }
    return self;
}

#pragma mark Overrides

- (void)perform
{
    HLSPlaceholderViewController *placeholderViewController = nil;
    UIViewController *viewController = self.sourceViewController;
    
    // The source is a placeholder view controller. Reserved segue identifiers can be used to preload view controllers 
    // into a placeholder view controller
    if ([self.sourceViewController isKindOfClass:[HLSPlaceholderViewController class]]) {
        placeholderViewController = self.sourceViewController;
        if ([self.identifier hasPrefix:HLSPlaceholderPreloadSegueIdentifierPrefix]) {
            NSString *indexString = [self.identifier stringByReplacingOccurrencesOfString:HLSPlaceholderPreloadSegueIdentifierPrefix
                                                                               withString:@""];
            static NSNumberFormatter *s_numberFormatter = nil;
            static dispatch_once_t s_onceToken;
            dispatch_once(&s_onceToken, ^{
                s_numberFormatter = [[NSNumberFormatter alloc] init];
            });
            NSNumber *indexNumber = [s_numberFormatter numberFromString:indexString];
            if (! indexNumber) {
                HLSLoggerError(@"Cannot parse inset index from segue identifier '%@'", self.identifier);
                return;
            }
            
            if (self.index != [indexNumber unsignedIntegerValue]) {
                HLSLoggerWarn(@"For preloading segues, the index is extracted from the segue identifier '%@' and will override the one "
                              "(%lu) manually set", self.identifier, (unsigned long)self.index);
                self.index = [indexNumber unsignedIntegerValue];
            }
        }
    }
    else if (viewController.placeholderViewController) {
        placeholderViewController = viewController.placeholderViewController;
    }
    else {
        HLSLoggerError(@"The source view controller is neither a placeholder view controller not an inset view controller");
        return;
    }
    
    [placeholderViewController setInsetViewController:self.destinationViewController
                                              atIndex:self.index
                                  withTransitionClass:self.transitionClass
                                             duration:self.duration];
}

@end

@implementation HLSPlaceholderInsetStandardSegue

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
    HLSPlaceholderInsetSegue *insetSegue = [[HLSPlaceholderInsetSegue alloc] initWithIdentifier:self.identifier source:self.sourceViewController destination:self.destinationViewController];
    insetSegue.index = self.index;
    insetSegue.transitionClass = self.transitionClass;
    insetSegue.duration = self.duration;
    insetSegue.animated = self.animated;
    [insetSegue perform];
}

@end

@implementation HLSPlaceholderCoverFromBottomSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottom class]];
}

@end

@implementation HLSPlaceholderCoverFromTopSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromTop class]];
}

@end

@implementation HLSPlaceholderCoverFromLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromLeft class]];
}

@end

@implementation HLSPlaceholderCoverFromRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromRight class]];
}

@end

@implementation HLSPlaceholderCoverFromTopLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromTopLeft class]];
}

@end

@implementation HLSPlaceholderCoverFromTopRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromTopRight class]];
}

@end

@implementation HLSPlaceholderCoverFromBottomLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottomLeft class]];
}

@end

@implementation HLSPlaceholderCoverFromBottomRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottomRight class]];
}

@end

@implementation HLSPlaceholderCoverFromBottomPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottomPushToBack class]];
}

@end

@implementation HLSPlaceholderCoverFromTopPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromTopPushToBack class]];
}

@end

@implementation HLSPlaceholderCoverFromLeftPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromLeftPushToBack class]];
}

@end

@implementation HLSPlaceholderCoverFromRightPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromRightPushToBack class]];
}

@end

@implementation HLSPlaceholderCoverFromTopLeftPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromLeftPushToBack class]];
}

@end

@implementation HLSPlaceholderCoverFromTopRightPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromTopRightPushToBack class]];
}

@end

@implementation HLSPlaceholderCoverFromBottomLeftPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottomLeftPushToBack class]];
}

@end

@implementation HLSPlaceholderCoverFromBottomRightPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCoverFromBottomRightPushToBack class]];
}

@end

@implementation HLSPlaceholderFadeInSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFadeIn class]];
}

@end

@implementation HLSPlaceholderFadeInPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFadeInPushToBack class]];
}

@end

@implementation HLSPlaceholderCrossDissolveSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionCrossDissolve class]];
}

@end

@implementation HLSPlaceholderPushFromBottomSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromBottom class]];
}

@end

@implementation HLSPlaceholderPushFromTopSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromTop class]];
}

@end

@implementation HLSPlaceholderPushFromLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromLeft class]];
}

@end

@implementation HLSPlaceholderPushFromRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromRight class]];
}

@end

@implementation HLSPlaceholderPushFromBottomFadeInSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromBottomFadeIn class]];
}

@end

@implementation HLSPlaceholderPushFromTopFadeInSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromTopFadeIn class]];
}

@end

@implementation HLSPlaceholderPushFromLeftFadeInSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromLeftFadeIn class]];
}

@end

@implementation HLSPlaceholderPushFromRightFadeInSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushFromRightFadeIn class]];
}

@end

@implementation HLSPlaceholderPushToBackFromBottomSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushToBackFromBottom class]];
}

@end

@implementation HLSPlaceholderPushToBackFromTopSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushToBackFromTop class]];
}

@end

@implementation HLSPlaceholderPushToBackFromLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushToBackFromLeft class]];
}

@end

@implementation HLSPlaceholderPushToBackFromRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionPushToBackFromRight class]];
}

@end

@implementation HLSPlaceholderFlowFromBottomSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlowFromBottom class]];
}

@end

@implementation HLSPlaceholderFlowFromTopSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlowFromTop class]];
}

@end

@implementation HLSPlaceholderFlowFromLeftSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlowFromLeft class]];
}

@end

@implementation HLSPlaceholderFlowFromRightSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlowFromRight class]];
}

@end

@implementation HLSPlaceholderEmergeFromCenterSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionEmergeFromCenter class]];
}

@end

@implementation HLSPlaceholderEmergeFromCenterPushToBackSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionEmergeFromCenterPushToBack class]];
}

@end

@implementation HLSPlaceholderFlipVerticallySegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlipVertically class]];
}

@end

@implementation HLSPlaceholderFlipHorizontallySegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionFlipHorizontally class]];
}

@end

@implementation HLSPlaceholderRotateHorizontallyFromBottomCounterclockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateHorizontallyFromBottomCounterclockwise class]];
}

@end

@implementation HLSPlaceholderRotateHorizontallyFromBottomClockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateHorizontallyFromBottomClockwise class]];
}

@end

@implementation HLSPlaceholderRotateHorizontallyFromTopCounterclockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateHorizontallyFromTopCounterclockwise class]];
}

@end

@implementation HLSPlaceholderRotateHorizontallyFromTopClockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateHorizontallyFromTopClockwise class]];
}

@end

@implementation HLSPlaceholderRotateVerticallyFromLeftCounterclockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateVerticallyFromLeftCounterclockwise class]];
}

@end

@implementation HLSPlaceholderRotateVerticallyFromLeftClockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateVerticallyFromLeftClockwise class]];
}

@end

@implementation HLSPlaceholderRotateVerticallyFromRightCounterclockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateVerticallyFromRightCounterclockwise class]];
}

@end

@implementation HLSPlaceholderRotateVerticallyFromRightClockwiseSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination transitionClass:[HLSTransitionRotateVerticallyFromRightClockwise class]];
}

@end
