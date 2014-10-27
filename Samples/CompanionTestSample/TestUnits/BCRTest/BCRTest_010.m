//
//  BCRTest_010.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 17/06/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "BCRTest_010.h"


@implementation BCRTest_010


+(NSString *)title {
	return @"Default Configuration";
}

+(NSString *)subtitle {
	return @"Intermec/Ingenico Default Configurations";
}

+(NSString *)instructions {
	return @"Ensure the device is ready. Push Intermec/Ingenico Defaults to apply Intermec/Ingenico 's default scanner configurations.";
}

+(NSString *)category {
	return @"Unit Tests";
}


-(void)viewDidLoad {
	[super viewDidLoad];
    [self addButtonWithTitle:@"Intermec Defaults" andAction:@selector(applyIntermecDefaults)];
    [self addButtonWithTitle:@"Ingenico Defaults" andAction:@selector(applyIngenicoDefaults)];
}

-(void)applyIngenicoDefaults {
	[ingenicoDefaults setEnabled:NO];
}

#pragma mark ICBarCodeReaderDelegate

-(void)barcodeData:(id)data ofType:(int)type {
    
}

-(void)onConfigurationApplied {
    [ingenicoDefaults setEnabled:YES];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Scanner configured !!" message:@"Ingenico Default Configuration applied" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    [self logMessage:@"Ingenico Default Configuration applied"];
}

-(void)barcodeLogEntry:(NSString *)logEntry withSeverity:(int)severity {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:logEntry waitUntilDone:NO];
}

#pragma -


@end
