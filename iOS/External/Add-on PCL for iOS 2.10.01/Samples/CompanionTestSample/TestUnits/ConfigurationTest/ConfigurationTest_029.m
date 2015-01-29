//
//  ConfigurationTest_029.h
//  iSMPTestSuite
//
//  Created by Stephane RABILLER on 22/09/14.
//  Copyright 2014 Ingenico. All rights reserved.
//

#import "ConfigurationTest_029.h"


@implementation ConfigurationTest_029
@synthesize ip, port, identifier, sslCurrentProfile, sslProfiles;


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonWithTitle:@"Refresh" andAction:@selector(refresh)];
	ip	= [self addTextFieldWithTitle:@"IP"];
	port		= [self addTextFieldWithTitle:@"Port"];
	identifier	= [self addTextFieldWithTitle:@"Identifier"];
    sslCurrentProfile = [self addTextFieldWithTitle:@"Current Profile"];
    sslProfiles = [self addTextViewWithTitle:@"SSL Profiles"];
    labelCount = 0;
    [ip setEnabled:NO];
	[port setEnabled:NO];
	[identifier setEnabled:NO];
    [sslCurrentProfile setEnabled:NO];
}


+(NSString *)title {
	return @"Get TMS Parameters";
}


+(NSString *)subtitle {
	return @"Retrieve the TMS parameters from the Companion";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready and press the refresh button. The TMS server parameters should then be displayed.";
}

+(NSString *)category {
	return @"Device Configuration";
}


-(void)getInformationHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
    ICTmsInformation *tmsInfos = nil;
    tmsInfos = [self.configurationChannel getTmsInformation];
	double totalTime = [self endTimeMeasure];
    ip.text	=  [NSString stringWithFormat:@"%@", tmsInfos.TmsIP];
	port.text = [NSString stringWithFormat:@"%@", tmsInfos.TmsPort];
    identifier.text = [NSString stringWithFormat:@"%@", tmsInfos.TmsIdentifier];
    sslCurrentProfile.text = [NSString stringWithFormat:@"%@", tmsInfos.TmsCurrentSSLProfile];
    NSMutableString *sslList = [NSMutableString stringWithFormat:@"%@\n", sslProfiles.text];
    
    labelCount = [tmsInfos.TmsArraySSLProfile count];
    for(int i = 0; i<labelCount;i++)
    {
        NSString *temp = [NSString stringWithFormat:@"%@\n",tmsInfos.TmsArraySSLProfile[i]];
        [sslList appendString:temp];
        [sslProfiles performSelectorOnMainThread:@selector(setText:) withObject:sslList waitUntilDone:NO];
    }
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Total Time: %f", totalTime] waitUntilDone:NO];
	[pool release];
}


-(void)refresh {
	[self performSelectorInBackground:@selector(getInformationHelper) withObject:nil];
}


@end
