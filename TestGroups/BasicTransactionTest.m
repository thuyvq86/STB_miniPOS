//
//  BasicTransactionTest.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "BasicTransactionTest.h"


@implementation BasicTransactionTest

#pragma mark class methods

+(NSString *)prefixLetter {
	static NSString * prefixLetter = @"T";
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


- (void)dealloc {
    [super dealloc];
}

#pragma mark IMPDelegate

-(void)newMessage:(NSString *)message {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:message waitUntilDone:NO];
}

-(void)transactionSuccess:(NSArray *)receipts {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:@"Transaction Succeeded" waitUntilDone:NO];
}

-(void)transactionFailed:(NSArray *)receipts {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:@"Transaction Failed" waitUntilDone:NO];
}

#pragma mark -


@end
