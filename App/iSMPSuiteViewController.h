//
//  iSMPTestSuiteViewController.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 17/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iSMP/revision.h>

@interface iSMPSuiteViewController : iSMPBaseViewController <UITableViewDelegate, UITableViewDataSource> {

	NSDictionary		* testGroups;
	
	UILabel				* labelApiVersion;
	UILabel				* labelApplicationBuildTime;
	UILabel				* labelAppVersion;
    
    IBOutlet UITableView *_tableView;
}

@property (nonatomic, retain) NSDictionary * testGroups;
@property (nonatomic, retain) IBOutlet UILabel * labelApiVersion;
@property (nonatomic, retain) IBOutlet UILabel * labelApplicationBuildTime;
@property (nonatomic, retain) IBOutlet UILabel * labelAppVersion;
@property (nonatomic, retain) NSOutputStream * batteryLogStream;


-(IBAction)iSpmInformation;

@end

