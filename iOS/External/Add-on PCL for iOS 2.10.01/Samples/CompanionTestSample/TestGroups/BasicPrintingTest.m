//
//  BasicPrintingTest.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "BasicPrintingTest.h"


@implementation BasicPrintingTest
@synthesize printer=_printer;
#pragma mark class methods

+(NSString *)prefixLetter {
	static NSString * prefixLetter = @"P";
	return prefixLetter;
}

#pragma mark instance methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	self.printer = [ICPrinter sharedPrinter];
	self.printer.delegate = self;
	[self displayDeviceState:[ICISMPDevice isAvailable]];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
	self.printer.delegate = nil;
	self.printer = nil;
	[super viewWillDisappear:animated];
}

#pragma mark ICPrinterDelegate

-(void)printingDidEndWithRowNumber:(NSUInteger)count {
	NSLog(@"%s : To be implemented in subclasses", __FUNCTION__);
}

#pragma mark -

-(void)logEntry:(NSString *)message withSeverity:(int)severity {
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"[%@] %@", [ICISMPDevice severityLevelString:severity], message] waitUntilDone:NO];
}

@end
