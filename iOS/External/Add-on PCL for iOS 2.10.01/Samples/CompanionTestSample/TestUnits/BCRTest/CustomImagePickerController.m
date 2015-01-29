//
//  CustomImagePickerController.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 03/08/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "CustomImagePickerController.h"


@implementation CustomImagePickerController
@synthesize barcode;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.barcode = [ICBarCodeReader sharedICBarCodeReader];
    self.barcode.delegate = self;
    [self.barcode powerOn];
    //[self.barcode enableTrigger:YES];
}

-(void)dealloc {
    self.barcode = nil;
    [super dealloc];
}


#pragma mark ICBarCodeReaderDelegate

-(void)barcodeData:(id)data ofType:(int)type {
    
}

-(void)onConfigurationApplied {
	
}

-(void)barcodeLogEntry:(NSString *)logEntry withSeverity:(int)severity {
	
}

-(void)triggerReleased {
	NSLog(@"%s", __FUNCTION__);
    [self takePicture];
}

-(void)triggerPulled {
    NSLog(@"%s", __FUNCTION__);
}

-(void)enableTriggerSync {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self.barcode enableTrigger:YES];
    [pool release];
}

-(void)configurationRequest {
	[self performSelectorInBackground:@selector(enableTriggerSync) withObject:nil];
}

#pragma mark -


@end
