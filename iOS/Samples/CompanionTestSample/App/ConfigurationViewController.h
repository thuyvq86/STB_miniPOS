//
//  ConfigurationViewController.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 25/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigurationViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UISegmentedControl           * pclInterfaceType;
@property (nonatomic, retain) IBOutlet UITextField                  * iOSTcpPclPort;
@property (nonatomic, retain) IBOutlet UITextField                  * terminalTcpPclPort;
@property (nonatomic, retain) IBOutlet UITextField                  * terminalIP;

-(void)loadUserSettings;
-(void)saveUserSettings;

@end
