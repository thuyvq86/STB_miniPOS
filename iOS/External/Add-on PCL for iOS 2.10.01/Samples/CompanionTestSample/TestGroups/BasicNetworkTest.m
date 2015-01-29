//
//  BasicNetworkTest.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "BasicNetworkTest.h"


@implementation BasicNetworkTest
@synthesize networkChannel=_networkChannel;
@synthesize configurationChannel=_configurationChannel;
#pragma mark class methods

+(NSString *)prefixLetter {
	static NSString * prefixLetter = @"N";
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

-(void)_backgroundOpen {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    
    if ([(NSObject *)self.configurationChannel respondsToSelector:@selector(open)]) {
        [self.configurationChannel open];
    }
    
    [self displayDeviceState:[self.configurationChannel isAvailable]];
    
    [pool release];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	self.networkChannel = [ICNetwork sharedChannel];
	self.networkChannel.delegate = self;
	[self displayDeviceState:[ICISMPDevice isAvailable]];
    
    self.configurationChannel = [ICAdministration sharedChannel];
    self.configurationChannel.delegate = self;
    
    [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
	
	//[self enableLogToFile:YES];
}



-(void)accessoryDidConnect:(ICISMPDevice *)sender {
    NSLog(@"%s", __FUNCTION__);
    
    if (sender == self.configurationChannel) {
        [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
    }
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
    [super viewWillDisappear:animated];
    
    self.networkChannel.delegate = nil;
    self.networkChannel = nil;
    [self.configurationChannel close];
}


#pragma mark ICNetworkDelegate

-(void)networkData:(NSData *)data incoming:(BOOL)isIncoming {
	NSString * log = [NSString stringWithFormat:@"[Data: %@, Length: %lu]\r\n\t", (isIncoming==YES?@"Network -> iPhone":@"iPhone -> Network"), (unsigned long)[data length]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"[Data: %@, Length: %lu]", (isIncoming==YES?@"Network -> iPhone":@"iPhone -> Network"), (unsigned long)[data length]] waitUntilDone:NO];
    
    NSLog(@"%@", log);
}

-(void)networkWillConnectToHost:(NSString *)host onPort:(NSUInteger)port {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Trying to connect to %@:%lu", host, (unsigned long)port] waitUntilDone:NO];
}

-(void)networkDidConnectToHost:(NSString *)host onPort:(NSUInteger)port {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Connected to %@:%lu", host, (unsigned long)port] waitUntilDone:NO];
}

-(void)networkFailedToConnectToHost:(NSString *)host onPort:(NSUInteger)port {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Failed to connect to %@:%lu", host, (unsigned long)port] waitUntilDone:NO];
}

-(void)networkDidDisconnectFromHost:(NSString *)host onPort:(NSUInteger)port {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Disconnected from %@:%lu", host, (unsigned long)port] waitUntilDone:NO];
}

-(void)networkDidReceiveErrorWithHost:(NSString *)host andPort:(NSUInteger)port {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Received Error for %@:%lu", host, (unsigned long)port] waitUntilDone:NO];
}


#pragma mark -


@end
