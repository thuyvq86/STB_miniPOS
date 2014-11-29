//
//  ConfigurationTest_019.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 07/04/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_019.h"


@implementation ConfigurationTest_019


+(NSString *)title {
	return @"iSMP Components Info";
}


+(NSString *)subtitle {
	return @"Retrieve the iSMP Software Components";
}

+(NSString *)instructions {
	return @"Ensure the device is ready and press the Get Components Info button. The running software components and their CRCs should appear below";
}

+(NSString *)category {
	return @"Device Configuration";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	buttonGet = [self addButtonWithTitle:@"Get Components Info" andAction:@selector(getComponentsInfo:)];
	componentsLabels = NULL;
	labelCount = 0;
}


-(void)getComponentsInfoHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSUInteger i = 0;
	if (componentsLabels != NULL) {
		for (i = 0; i < labelCount; i++) {
			[componentsLabels[i] removeFromSuperview];
		}
	}
	[self beginTimeMeasure];
	NSArray * components = [self.configurationChannel getSoftwareComponents];
	float totalTime = [self endTimeMeasure];
	if (components == nil) {
		[self logMessage:[NSString stringWithFormat:@"Failed to retrieve the terminal's software components\nTotal Time: %f", totalTime]];
	} else {
		NSString * componentString = nil;
		labelCount = [components count];
		componentsLabels = (UILabel **)malloc(labelCount * sizeof(UILabel *));
		i = 0;
		for (ICSoftwareComponent * softwareComponent in components) {
			componentString = [NSString stringWithFormat:@"Name: %@ Version: %@ Type: %d CRC: %@", softwareComponent.name, softwareComponent.version, softwareComponent.type, softwareComponent.crc];
			UILabel * label = [self addLabelWithTitle:componentString];
			componentsLabels[i++] = label;
		}
	}
	[buttonGet setEnabled:YES];
	[pool release];
}


-(void)getComponentsInfo:(id)sender {
	[buttonGet setEnabled:NO];
	[self performSelectorInBackground:@selector(getComponentsInfoHelper) withObject:nil];
}

@end
