//
//  HLSRuntimeChecks.h
//  nut
//
//  Created by Samuel Défago on 7/14/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#define FORBIDDEN_INHERITED_METHOD()            [NSException raise:@"Forbidden inherited method call" \
                                                            format:@"The '%s' method has been inherited by " \
                                                            "class '%@' but could not be meaningfully " \
                                                            "overriden. This method has therefore been " \
                                                            "disabled", _cmd, [self class]]
