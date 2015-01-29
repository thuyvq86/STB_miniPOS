//
//  ConfigurationTest_020.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 07/04/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_020.h"


@implementation ConfigurationTest_020
@synthesize textView;
@synthesize control;

+(NSString *)title {
	return @"Simulate Key";
}


+(NSString *)subtitle {
	return @"iSMP Keyboard Key Simulation";
}

+(NSString *)instructions {
	return @"Ensure the device is ready and press the Get Components Info button. The running software components and their CRCs should appear below";
}

+(NSString *)category {
	return @"Device Configuration";
}

+(NSString *)prefixLetter {
	static NSString * prefixLetter = @"C";
	return prefixLetter;
}


+(NSString *)testNumber {
	NSMutableString * classname = [NSMutableString stringWithString:[self description]];
	NSString * number = [classname substringFromIndex:([classname length]-3)];
	return number;
}


char localToiSPM[] = {
	ICNum0,
	ICNum1,
	ICNum2,
	ICNum3,
	ICNum4,
	ICNum5,
	ICNum6,
	ICNum7,
	ICNum8,
	ICNum9,
	ICKeyDot,
	ICKeyPaperFeed,
	ICKeyGreen,
	ICKeyRed,
	ICKeyYellow,
	ICKeyF1,
	ICKeyF2,
	ICKeyF3,
	ICKeyF4,
	ICKeyUp,
	ICKeyDown,
	ICKeyOK,
	ICKeyC,
	ICKeyF,
};


-(void)_backgroundOpen {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if ([(NSObject *)self.control respondsToSelector:@selector(open)]) {
        [self.control open];
    }
    
    //[self displayDeviceState:[self.control isAvailable]];
    
    [pool release];
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = [[self class] title];
    
    self.control = [ICAdministration sharedChannel];
    self.control.delegate = self;
    
    [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
}

-(void)viewDidUnload {
    self.control = nil;
    [super viewDidUnload];
}


-(void)accessoryDidConnect:(ICISMPDevice *)sender {
    NSLog(@"%s", __FUNCTION__);
    
    [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
}


-(void)logOnTextView:(NSString *)message {
	textView.text = [NSString stringWithFormat:@"%@\n%@", textView.text, message];
}

-(void)simulateKeyHelper:(id)obj {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	BOOL retValue = [self.control simulateKey:localToiSPM[((UIButton *)obj).tag]];
	NSString * msg = nil;
	if (retValue == NO) {
		msg = @"Simulate Key Failed";
	} else {
		msg = @"Simulate Key Succeeded";
	}
	[self performSelectorOnMainThread:@selector(logOnTextView:) withObject:msg waitUntilDone:NO];
	[pool release];
}


-(IBAction)onTerminalKeyPress:(id)sender {
	[self performSelectorInBackground:@selector(simulateKeyHelper:) withObject:sender];
}

-(void)logEntry:(NSString *)message withSeverity:(int)severity {
	[self performSelectorOnMainThread:@selector(logOnTextView:) withObject:message waitUntilDone:NO];
	NSLog(@"%@", message);
}

@end
