//
//  CursorCustomPointerView.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 20.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface CursorCustomPointerView : HLSNibView {
@private
    UILabel *_valueLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *valueLabel;

@end
