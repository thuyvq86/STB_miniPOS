//
//  BasicConfigurationTest.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "BasicConfigurationTest.h"

@implementation BasicConfigurationTest
@synthesize configurationChannel=_configurationChannel;

#pragma mark class methods

+(NSString *)prefixLetter {
	static NSString * prefixLetter = @"A";
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
    
    //Initialize the PPP Channel
    //self.pppChannel = [ICPPP sharedChannel];
    //self.pppChannel.delegate = self;
    
    //Start the PPP Stack
    //[self.pppChannel openChannel];
}


-(void)_backgroundOpen {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if ([(NSObject *)self.configurationChannel respondsToSelector:@selector(open)]) {
        [self.configurationChannel open];
    }
    
    [self displayDeviceState:[self.configurationChannel isAvailable]];
    
    [pool release];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Check the settings to know how to initialize the ICAdministration object
    if ([[SettingsManager sharedSettingsManager] pclInterfaceType] == SERIAL) {
        NSLog(@"%s Using PCL over Serial", __FUNCTION__);
        
        self.configurationChannel = [ICAdministration sharedChannel];
        self.configurationChannel.delegate = self;
        
        [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
        
    } else if ([[SettingsManager sharedSettingsManager] pclInterfaceType] == TCP) {
        NSLog(@"%s Using PCL over TCP/IP", __FUNCTION__);
        
        //Do Nothing - Wait for the PPP channel to open
    }
    
}

-(void)accessoryDidConnect:(ICISMPDevice *)sender {
    NSLog(@"%s", __FUNCTION__);
    
    if (sender == self.configurationChannel) {
        [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
    }
}

#pragma mark ICAdministrationDelegate

//-(void)confLogEntry:(NSString *)message withSeverity:(int)severity {
//	NSLog(@"%@", message);
//	if ((severity == SEV_ERROR) || (severity == SEV_WARN)) {
//		[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"[%@] %@", [ICDevice severityLevelString:severity], message] waitUntilDone:NO];
//	}
//}


-(void)confSerialData:(NSData *)data incoming:(BOOL)isIncoming {
	NSLog(@"[Data: %@, Length: %d]\n\t", (isIncoming == YES ? @"iSMP -> iPhone" : @"iPhone -> iSMP"), [data length]);
	//[super logSerialData:data incomming:isIncoming];
}

#pragma mark -


-(NSString *)iSMPResultToString:(iSMPResult)result {
    NSString * retValue = @"";
    
    switch (result) {
        case ISMP_Result_SUCCESS:                         retValue = @"OK"; break;
        case ISMP_Result_Failure:                         retValue = @"KO"; break;
        case ISMP_Result_TIMEOUT:                         retValue = @"TIMEOUT"; break;
        case ISMP_Result_ISMP_NOT_CONNECTED:              retValue = @"ISMP NOT CONNECTED"; break;
        case ISMP_Result_ENCRYPTION_KEY_INVALID:          retValue = @"ENCRYPTION KEY INVALID"; break;
        case ISMP_Result_ENCRYPTION_KEY_NOT_FOUND:        retValue = @"ENCRYPTION KEY NOT FOUND"; break;
        case ISMP_Result_ENCRYPTION_DLL_MISSING:          retValue = @"ENCRYPTION DLL Missing"; break;
            
        default:                                        retValue = [NSString stringWithFormat:@"Unknown Result Code %x", result]; break;
    }
    return retValue;
}

@end
