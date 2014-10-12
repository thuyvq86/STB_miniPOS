//
//  ConfigurationTest_020.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 07/04/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"


@interface ConfigurationTest_020 : UIViewController<TestProperties, ICISMPDeviceDelegate, ICAdministrationDelegate> {

}

@property (nonatomic, retain) IBOutlet UITextView * textView;
@property (nonatomic, retain) ICAdministration * control;

-(IBAction)onTerminalKeyPress:(id)sender;

@end
