//
//  MessagingViewController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/14/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "MessagingViewController.h"

@interface MessagingViewController ()<ICISMPDeviceDelegate, ICAdministrationDelegate, ICISMPDeviceExtensionDelegate, NSStreamDelegate>{
    NSDate				*startDate;
	NSDate				*resignActiveDate;
	
	NSUInteger			  _vCursor;
	
	NSUInteger			  entryNumber;
	NSUInteger			  trashTextLength;
	
	BOOL				 _logToFile;
}
@property (nonatomic, strong) NSOutputStream *logStream;

@end

@implementation MessagingViewController

@synthesize configurationChannel = _configurationChannel;
@synthesize logStream = _logStream;

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"iSMP->iPhone";
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor brownColor];
    CGRect frame = _lbliSpmConnectionState.frame;
    DLog(@"y=%f", frame.origin.y);
    if (IOS7_OR_GREATER){
        // CGRect frame = _lbliSpmConnectionState.frame;
        frame.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        _lbliSpmConnectionState.frame = frame;
        
        _tableView.frame = CGRectSetPosY(_tableView.frame, CGRectGetMaxY(_lbliSpmConnectionState.frame));
    }
    
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Check the settings to know how to initialize the ICAdministration object
    if ([[SettingsManager sharedSettingsManager] pclInterfaceType] == SERIAL) {
        DLog(@"Using PCL over Serial");
        
        self.configurationChannel = [ICAdministration sharedChannel];
        self.configurationChannel.delegate = self;
        
        [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
        
    } else if ([[SettingsManager sharedSettingsManager] pclInterfaceType] == TCP) {
        DLog(@"Using PCL over TCP/IP");
        
        //Do Nothing - Wait for the PPP channel to open
    }
}

- (void)dealloc {
//    [_lbliSpmConnectionState release];
//    [_tableView release];
//    [super dealloc];
}

- (void)viewDidUnload {
    //    [_lbliSpmConnectionState release];
    _lbliSpmConnectionState = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    
//    [_tableView release];
    _tableView = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ICDeviceDelegate

- (void)accessoryDidConnect:(ICISMPDevice *)sender {
    DLog();
    
    if (sender == self.configurationChannel) {
        [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
    }
}

- (void)accessoryDidDisconnect:(ICISMPDevice *)sender {
	[self displayDeviceState:NO];
	
	//Measure time from the application becoming inactive to accessory disconnection
	if (resignActiveDate != nil) {
		double fromInactive2DisconnectTime = - [resignActiveDate timeIntervalSinceNow];
		NSString * msg = [NSString stringWithFormat:@"Time form application becoming inactive til iSMP disconnection: %f", fromInactive2DisconnectTime];
		[self performSelectorOnMainThread:@selector(logMessage:) withObject:msg waitUntilDone:NO];
		DLog(@"%@", msg);
    
		resignActiveDate = nil;
	}
}

- (void)logEntry:(NSString *)message withSeverity:(int)severity {
	NSLog(@"[%@] %@", [ICISMPDevice severityLevelString:severity], message);
	//[self performSelectorOnMainThread:@selector(logMessage:) withObject:message waitUntilDone:NO];
	
	if (_logToFile) {
		NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
		message = [NSString stringWithFormat:@"%@ [%@] %@\r\n", [dateFormatter stringFromDate:[NSDate date]], [ICISMPDevice severityLevelString:severity], message];
		[self.logStream write:(uint8_t *)[message UTF8String] maxLength:[message length]];
	}
}

- (void)logSerialData:(NSData *)data incomming:(BOOL)isIncoming {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
	
    NSString *log = [NSString stringWithFormat:@"%@ [Data: %@, Length: %d]\r\n\t", [dateFormatter stringFromDate:[NSDate date]], (isIncoming==YES?@"iSMP->iPhone":@"iPhone->iSMP"), [data length]];
    
	[self.logStream write:(uint8_t *)[log UTF8String] maxLength:[log length]];
	DLog(@"%@", log);
}

#pragma mark - Run in background

- (void)applicationBecameInactive:(NSNotification *)notification {
    DLog();
	resignActiveDate = [[NSDate alloc] init];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    DLog();
}

- (void)onAccessoryDidConnect:(NSNotification *)notification {
    DLog();
}

#pragma mark - Helpers

- (void)_backgroundOpen {
    DLog();
    
    @autoreleasepool {
        if ([(NSObject *)self.configurationChannel respondsToSelector:@selector(open)]) {
            [self.configurationChannel open];
        }
        
        [self displayDeviceState:[self.configurationChannel isAvailable]];
    }
}

- (void)displayDeviceState:(BOOL)ready {
    
    if ([NSThread isMainThread]) {
        [self _updateDeviceState:ready];
    }
    else {
        [self performSelectorOnMainThread:@selector(_backgroundDisplayDeviceState:) withObject:[NSNumber numberWithBool:ready] waitUntilDone:NO];
    }
}

- (void)_backgroundDisplayDeviceState:(NSNumber *)boolReady{
    DLog();
    
    @autoreleasepool {
        [self _updateDeviceState:[boolReady boolValue]];
    }
}

- (void)_updateDeviceState:(BOOL)ready{
    NSString *statusText = ready ? @"Device ready" : @"Device not ready";
    UIColor *backgroundColor = ready ? [UIColor greenColor] : [UIColor redColor];
    
    _lbliSpmConnectionState.backgroundColor = backgroundColor;
    _lbliSpmConnectionState.text			= statusText;
}

#pragma mark - Debugging

- (void)beginTimeMeasure {
	startDate = [[NSDate alloc] init];
}

- (NSTimeInterval)endTimeMeasure {
	NSTimeInterval interval =- [startDate timeIntervalSinceNow];
    
	return interval;
}

- (IBAction)clearLog {
    //	textView.text	= @"";
	entryNumber		= 0;
	trashTextLength = 0;
}

- (void)logMessage:(NSString *)message {
	NSMutableString *log = [NSMutableString string];//[NSMutableString stringWithFormat:@"%@\n", textView.text];
	[log appendString:message];
    
//	textView.text = log;
//	[textView scrollRangeToVisible:NSMakeRange([textView.text length]-1, 1)];
	
	DLog(@"%@", message);
	if (_logToFile) {
		NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
		message = [NSString stringWithFormat:@"%@ %@\r\n", [dateFormatter stringFromDate:[NSDate date]], message];
		[self.logStream write:(uint8_t *)[message UTF8String] maxLength:[message length]];
	}
}

- (void)clearAndLogMessage:(NSString *)message {
//	textView.text = message;
	DLog(@"%@", message);
	if (_logToFile) {
		NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
		message = [NSString stringWithFormat:@"%@ %@\r\n", [dateFormatter stringFromDate:[NSDate date]], message];
		[self.logStream write:(uint8_t *)[message UTF8String] maxLength:[message length]];
	}
}

- (void)enableLogToFile:(BOOL)enabled {
	_logToFile = enabled;
    
	if (enabled == YES) {
		NSString * logFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"iSMPLog.txt"];
		self.logStream = [NSOutputStream outputStreamToFileAtPath:logFilePath append:YES];
		[self.logStream open];
	}
    else {
		[self.logStream close];
		self.logStream = nil;
	}
}

- (NSString *)iSMPResultToString:(iSMPResult)result {
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
