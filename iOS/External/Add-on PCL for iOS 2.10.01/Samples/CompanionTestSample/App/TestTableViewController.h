//
//  TestTableViewController.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 28/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestCategoryManager.h"


@interface TestTableViewController : UITableViewController {
	IBOutlet	UITableView * _tableView;
	NSString				* testGroup;
	TestCategoryManager		* testCategoryManager;
}

@property (nonatomic, retain) IBOutlet	UITableView * _tableView;
@property (nonatomic, copy) NSString * testGroup;
@property (nonatomic, retain) TestCategoryManager * testCategoryManager;

@end
