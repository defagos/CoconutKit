//
//  ExpandingSearchBarDemoViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface ExpandingSearchBarDemoViewController : HLSViewController <HLSExpandingSearchBarDelegate> {
@private
    HLSExpandingSearchBar *_searchBar1;
    HLSExpandingSearchBar *_searchBar2;
    HLSExpandingSearchBar *_searchBar3;
    UISwitch *_animatedSwitch;
}

@property (nonatomic, retain) IBOutlet HLSExpandingSearchBar *searchBar1;
@property (nonatomic, retain) IBOutlet HLSExpandingSearchBar *searchBar2;
@property (nonatomic, retain) IBOutlet HLSExpandingSearchBar *searchBar3;

@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;

- (IBAction)expandSearchBar1:(id)sender;
- (IBAction)collapseSearchBar1:(id)sender;

@end
