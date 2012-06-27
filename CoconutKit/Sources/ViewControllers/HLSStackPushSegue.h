//
//  HLSStackPushSegue.h
//  CoconutKit
//
//  Created by Samuel Défago on 27.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSTransitionStyle.h"

@interface HLSStackPushSegue : UIStoryboardSegue {
@private
    HLSTransitionStyle m_transitionStyle;
    NSTimeInterval m_duration;
}

@property (nonatomic, assign) HLSTransitionStyle transitionStyle;
@property (nonatomic, assign) NSTimeInterval duration;

@end
