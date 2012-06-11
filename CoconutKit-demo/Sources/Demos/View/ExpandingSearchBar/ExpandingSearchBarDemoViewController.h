//
//  ExpandingSearchBarDemoViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface ExpandingSearchBarDemoViewController : HLSViewController {
@private
    HLSExpandingSearchBar *m_searchBar;
}

@property (nonatomic, retain) IBOutlet HLSExpandingSearchBar *searchBar;

@end
