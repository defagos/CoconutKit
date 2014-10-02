//
//  LabelBindingsDemo2ViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "LabelBindingsDemo2ViewController.h"

#import "Employee.h"

@interface LabelBindingsDemo2ViewController ()

@property (nonatomic, weak) IBOutlet UIView *firstSubview;
@property (nonatomic, weak) IBOutlet UIView *secondSubview;
@property (nonatomic, weak) IBOutlet UIView *subviewInSecondSubview;

@end

@implementation LabelBindingsDemo2ViewController

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        Employee *employee1 = [[Employee alloc] init];
        employee1.fullName = @"Jesse Pinkman";
        employee1.age = @22;
        
        // Objects can be bound early (they are retained)
        [self bindToObject:employee1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // If you want to nest views with bound objects, be sure to bind them in the proper order (ancestor views first),
    // otherwise values will be overridden in subviews when binding a view. In general, though, you should try to keep
    // view hierarchies distinct if you intend to bind distinct objects. Alternatively, you can use embedded view
    // controllers if this makes sense (binding namely stops at view controller boundaries)
    Employee *employee2 = [[Employee alloc] init];
    employee2.fullName = @"Skyler White";
    employee2.age = @47;
    [self.firstSubview bindToObject:employee2];
    
    Employee *employee3 = [[Employee alloc] init];
    employee3.fullName = @"Walter White Jr.";
    employee3.age = @17;
    [self.secondSubview bindToObject:employee3];
    
    Employee *employee4 = [[Employee alloc] init];
    employee4.fullName = @"Hank Schrader";
    employee4.age = @45;
    [self.subviewInSecondSubview bindToObject:employee4];
}

- (IBAction)refresh:(id)sender
{
    [self refreshBindingsForced:NO];
}

- (IBAction)change:(id)sender
{
    // Since there is no view controller boundary here, this will override the bindings in subviewInSecondSubview
    Employee *employee5 = [[Employee alloc] init];
    employee5.fullName = @"Marie Schrader";
    employee5.age = @52;
    [self.secondSubview bindToObject:employee5];
}

@end
