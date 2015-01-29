//
//  ConfigurationTest_029.h
//  iSMPTestSuite
//
//  Created by Stephane RABILLER on 22/09/14.
//  Copyright 2014 Ingenico. All rights reserved.
//

#import "ConfigurationTest_030.h"


@implementation ConfigurationTest_030
@synthesize ip, port, identifier, sslProfiles;


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonWithTitle:@"Refresh" andAction:@selector(refresh)];
	ip	= [self addTextFieldWithTitle:@"IP / Hostname"];
	port		= [self addTextFieldWithTitle:@"Port"];
	identifier	= [self addTextFieldWithTitle:@"Identifier"];
    sslProfiles = [self addTextFieldWithTitle:@"Current SSL Profile"];
    labelCount = 0;
    [ip setEnabled:YES];
	[port setEnabled:YES];
	[identifier setEnabled:YES];
    [sslProfiles setEnabled:YES];
}


+(NSString *)title {
	return @"Set TMS Parameters";
}


+(NSString *)subtitle {
	return @"Set the TMS parameters to the Companion";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready and press the refresh button. The TMS server parameters should then be applied.";
}

+(NSString *)category {
	return @"Device Configuration";
}


-(void)setInformationHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
    ICTmsInformation *tmsInfos = [[ICTmsInformation alloc] init];
    tmsInfos.TmsIP = [NSMutableString stringWithString:ip.text];
    tmsInfos.TmsPort = [NSMutableString stringWithString:port.text];
    tmsInfos.TmsIdentifier = [NSMutableString stringWithString:identifier.text];
    tmsInfos.TmsCurrentSSLProfile = [NSMutableString stringWithString:sslProfiles.text];
    
    [self.configurationChannel setTmsInformation:tmsInfos];
	double totalTime = [self endTimeMeasure];

	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Total Time: %f", totalTime] waitUntilDone:NO];
    [tmsInfos release];
	[pool release];
}


-(void)refresh {
	[self performSelectorInBackground:@selector(setInformationHelper) withObject:nil];
}


@end
