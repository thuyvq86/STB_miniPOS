//
//  BasicTest.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "BasicTest.h"

#define kVSpace				4
#define kButtonHeight		30
#define kTextFieldHeight	30
#define kLabelHeight		30
#define kSwitchHeight		30
#define	kSegmentHeight		40
#define kHMargin			2
#define kVMargin			4
#define kWebViewHeight      200

@implementation BasicTest
@synthesize iSpmConnectionState, instructions, scrollView, textView, logStream;


-(id)init {
	if ((self = [super initWithNibName:@"BasicTest" bundle:nil])) {
		startDate			= nil;
		resignActiveDate	= nil;
		_vCursor			= 0;
		entryNumber			= 0;
		trashTextLength		= 0;
		_logToFile			= NO;
		[self enableLogToFile:YES];
        
        //Register for accessory notifications
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
        
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationBecameInactive:) 
											  name:UIApplicationWillResignActiveNotification 
											  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationDidEnterBackground:) 
                                                     name:UIApplicationDidEnterBackgroundNotification 
                                                   object:nil];
	}
	return self;
}

-(void)dealloc {
	if (startDate != nil) {
		[startDate release];
	}
	if (resignActiveDate != nil) {
		[resignActiveDate release];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    
	[super dealloc];
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = [[self class] title];
	instructions.text = [[self class] instructions];
}

-(void)viewDidUnload {
	/*
	for (UIView * view in [self.scrollView subviews]) {
		[view removeFromSuperview];
	}
	*/
	[super viewDidUnload];
}


-(void)applicationBecameInactive:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
	if (resignActiveDate != nil) {
		[resignActiveDate release];
		resignActiveDate = nil;
	}
	resignActiveDate = [[NSDate alloc] init];
}

-(void)applicationDidEnterBackground:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
	
}

-(void)onAccessoryDidConnect:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark Test Properties

+(NSString *)title {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+(NSString *)subtitle {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+(NSString *)instructions {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+(NSString *)category {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+(NSString *)prefixLetter {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+(NSString *)testNumber {
	NSMutableString * classname = [NSMutableString stringWithString:[self description]];
	NSString * number = [classname substringFromIndex:([classname length]-3)];
	return number;
}

#pragma mark -


#pragma mark ICDeviceDelegate

-(void)accessoryDidConnect:(ICISMPDevice *)sender {
	if ([ICISMPDevice isAvailable]) {
		[self displayDeviceState:YES];
	} else {
		[self displayDeviceState:NO];
	}

}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {
	[self displayDeviceState:NO];
	
	//Measure time from the application becoming inactive to accessory disconnection
	if (resignActiveDate != nil) {
		double fromInactive2DisconnectTime = - [resignActiveDate timeIntervalSinceNow];
		NSString * msg = [NSString stringWithFormat:@"Time form application becoming inactive til iSMP disconnection: %f", fromInactive2DisconnectTime];
		//[self logMessage:msg];
		[self performSelectorOnMainThread:@selector(logMessage:) withObject:msg waitUntilDone:NO];
		NSLog(@"%@", msg);
		[resignActiveDate release];
		resignActiveDate = nil;
	}
}

-(void)logEntry:(NSString *)message withSeverity:(int)severity {
	NSLog(@"[%@] %@", [ICISMPDevice severityLevelString:severity], message);
	//[self performSelectorOnMainThread:@selector(logMessage:) withObject:message waitUntilDone:NO];
	
	if (_logToFile) {
		NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
		message = [NSString stringWithFormat:@"%@ [%@] %@\r\n", [dateFormatter stringFromDate:[NSDate date]], [ICISMPDevice severityLevelString:severity], message];
		[self.logStream write:(uint8_t *)[message UTF8String] maxLength:[message length]];
		[dateFormatter release];
	}
}

-(void)logSerialData:(NSData *)data incomming:(BOOL)isIncoming {
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
	NSString * log = [NSString stringWithFormat:@"%@ [Data: %@, Length: %d]\r\n\t", [dateFormatter stringFromDate:[NSDate date]], (isIncoming==YES?@"iSMP->iPhone":@"iPhone->iSMP"), [data length]];
	[self.logStream write:(uint8_t *)[log UTF8String] maxLength:[log length]];
	NSLog(@"%@", log);
	[dateFormatter release];
}

#pragma mark -

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -

#pragma mark Debugging

-(void)beginTimeMeasure {
	if (startDate != nil) {
		[startDate release];
	}
	startDate = [[NSDate alloc] init];
}

-(NSTimeInterval)endTimeMeasure {
	NSTimeInterval interval = - [startDate timeIntervalSinceNow];
	return interval;
}


-(void)logMessage:(NSString *)message {
	
	//entryNumber++;
	NSMutableString * log = [NSMutableString stringWithFormat:@"%@\n", textView.text];
	/*
	if (entryNumber == 50) {
		trashTextLength = [log length];
	} else if (entryNumber == 100) {
		[log deleteCharactersInRange:NSMakeRange(0, trashTextLength)];
		entryNumber = 1;
		trashTextLength = [log length];
	}
	*/
	[log appendString:message];
	textView.text = log;
	[textView scrollRangeToVisible:NSMakeRange([textView.text length]-1, 1)];
	
	NSLog(@"%@", message);
	if (_logToFile) {
		NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
		message = [NSString stringWithFormat:@"%@ %@\r\n", [dateFormatter stringFromDate:[NSDate date]], message];
		[self.logStream write:(uint8_t *)[message UTF8String] maxLength:[message length]];
		[dateFormatter release];
	}
}

-(void)clearAndLogMessage:(NSString *)message {
	textView.text = message;
	NSLog(@"%@", message);
	if (_logToFile) {
		NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
		message = [NSString stringWithFormat:@"%@ %@\r\n", [dateFormatter stringFromDate:[NSDate date]], message];
		[self.logStream write:(uint8_t *)[message UTF8String] maxLength:[message length]];
		[dateFormatter release];
	}
}

-(IBAction)clearLog {
	textView.text	= @"";
	entryNumber		= 0;
	trashTextLength = 0;
}

-(void)enableLogToFile:(BOOL)enabled {
	_logToFile = enabled;
	if (enabled == YES) {
		NSString * logFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"iSMPLog.txt"];
		self.logStream = [NSOutputStream outputStreamToFileAtPath:logFilePath append:YES];
		[self.logStream open];
	} else {
		[self.logStream close];
		self.logStream = nil;
	}
}

#pragma mark -


#pragma mark User Interface

-(void)_backgroundDisplayDeviceState:(NSNumber *)boolReady {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if ([boolReady boolValue] == YES) {
		iSpmConnectionState.backgroundColor = [UIColor greenColor];
		iSpmConnectionState.text			= @"Device ready";
	} else {
		iSpmConnectionState.backgroundColor = [UIColor redColor];
		iSpmConnectionState.text			= @"Device not ready";
	}
    
    [pool release];
}

-(void)displayDeviceState:(BOOL)ready {
    
    if ([NSThread isMainThread]) {
        if (ready == YES) {
            iSpmConnectionState.backgroundColor = [UIColor greenColor];
            iSpmConnectionState.text			= @"Device ready";
        } else {
            iSpmConnectionState.backgroundColor = [UIColor redColor];
            iSpmConnectionState.text			= @"Device not ready";
        }
    } else {
        [self performSelectorOnMainThread:@selector(_backgroundDisplayDeviceState:) withObject:[NSNumber numberWithBool:ready] waitUntilDone:NO];
    }
}


-(UIButton *)addButtonWithTitle:(NSString *)title andAction:(SEL)action {
	UIButton * button = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:title forState:UIControlStateNormal];
	button.frame = CGRectMake(kVMargin, _vCursor, scrollView.frame.size.width - kHMargin*2, kButtonHeight);
	[button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
	[scrollView addSubview:button];
	_vCursor += kButtonHeight + kVSpace;
	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, _vCursor)];
	return button;
}

-(void)addButtonsWithTitle:(NSString *)title andTitle2:(NSString*)title2 toAction:(SEL)action {
	UIButton * button = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:title forState:UIControlStateNormal];
	button.tag = 0;
	button.frame = CGRectMake(kHMargin, _vCursor, scrollView.frame.size.width/2 - kHMargin*2, kButtonHeight);
	[button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
	[scrollView addSubview:button];
	
	button = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
	button.tag = 1;
	[button setTitle:title2 forState:UIControlStateNormal];
	button.frame = CGRectMake(scrollView.frame.size.width /2- kHMargin, _vCursor, scrollView.frame.size.width/2 - kHMargin*2, kButtonHeight);
	[button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
	[scrollView addSubview:button];
	_vCursor += kButtonHeight + kVSpace;
	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, _vCursor)];
}

-(UITextField *)addTextFieldWithTitle:(NSString *)title {
	UILabel	* label = [[[UILabel alloc] initWithFrame:CGRectMake(kHMargin, _vCursor, scrollView.frame.size.width/2- kHMargin*2, kLabelHeight)] autorelease];
	label.text = title;
	label.font = [UIFont systemFontOfSize:13];
	label.backgroundColor = [UIColor clearColor];
//	_vCursor += kLabelHeight;
	UITextField * textField = [[[UITextField alloc] initWithFrame:CGRectMake(scrollView.frame.size.width/2 - kHMargin, _vCursor, scrollView.frame.size.width/2 - kHMargin*2, kTextFieldHeight)] autorelease];
	textField.borderStyle = UITextBorderStyleBezel;
	textField.font = [UIFont systemFontOfSize:13];
	_vCursor += kTextFieldHeight + kVSpace;
	textField.delegate = self;
	[scrollView addSubview:label];
	[scrollView addSubview:textField];
	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, _vCursor)];
	return textField;
}

-(UISwitch *)addSwitchWithTitle:(NSString *)title {
	UILabel	* label = [[[UILabel alloc] initWithFrame:CGRectMake(kHMargin, _vCursor, scrollView.frame.size.width / 2- kHMargin*2, kLabelHeight)] autorelease];
	label.text = title;
	label.font = [UIFont systemFontOfSize:13];
	label.backgroundColor = [UIColor clearColor];
//	_vCursor += kLabelHeight;
	UISwitch * _switch = [[[UISwitch alloc] initWithFrame:CGRectMake(scrollView.frame.size.width / 2- kHMargin, _vCursor, scrollView.frame.size.width / 2 - kHMargin*2, kSwitchHeight)] autorelease];
	_vCursor += kTextFieldHeight + kVSpace;
	[scrollView addSubview:label];
	[scrollView addSubview:_switch];
	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, _vCursor)];
	return _switch;
}

-(UISegmentedControl *)addSegmentedControlWithTitle:(NSString *)title {
	UILabel	* label = [[[UILabel alloc] initWithFrame:CGRectMake(kHMargin, _vCursor, scrollView.frame.size.width - kHMargin*2, kLabelHeight)] autorelease];
	label.text = title;
	label.font = [UIFont systemFontOfSize:13];
	label.backgroundColor = [UIColor clearColor];
	_vCursor += kLabelHeight;
	UISegmentedControl * segControl = [[[UISegmentedControl alloc] initWithFrame:CGRectMake(kHMargin, _vCursor, scrollView.frame.size.width - 2 * kHMargin, kSegmentHeight)] autorelease];
	_vCursor += kSegmentHeight + kVSpace;
	[scrollView addSubview:label];
	[scrollView addSubview:segControl];
	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, _vCursor)];
	return segControl;
}

-(UILabel *)addLabelWithTitle:(NSString *)title {
	UILabel	* label = [[[UILabel alloc] initWithFrame:CGRectMake(kHMargin, _vCursor, scrollView.frame.size.width - kHMargin*2, kLabelHeight)] autorelease];
	label.text = title;
	label.font = [UIFont systemFontOfSize:13];
	label.backgroundColor = [UIColor clearColor];
	_vCursor += kLabelHeight;
	[scrollView addSubview:label];
	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, _vCursor)];	
	return label;
}

-(UIWebView *)addWebView {
    UIWebView * webView = [[[UIWebView alloc] initWithFrame:CGRectMake(kHMargin, _vCursor, scrollView.frame.size.width - kHMargin*2, kWebViewHeight)] autorelease];
    _vCursor += kLabelHeight;
    [scrollView addSubview:webView];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, _vCursor)];	
    return webView;
}

-(void)enableUserInteraction {
    [self.view setUserInteractionEnabled:YES];
}

#pragma mark -


#pragma mark Helper Methods

-(NSString *)getIPAddress
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else
                    if([name isEqualToString:@"pdp_ip0"]) {
                        // Interface is the cell connection on the iPhone
                        cellAddress = addr;
                    }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    return addr ? addr : @"0.0.0.0";
}

#pragma mark -

@end
