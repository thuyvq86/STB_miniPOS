//
//  STBMessagingViewController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBMessagingViewController.h"
//Views
#import "TransactionInfoCell.h"
#import "SignatureCell.h"
//Controllers
#import "STBSignatureViewController.h"

@interface STBMessagingViewController ()<ICISMPDeviceDelegate, ICAdministrationDelegate, ICISMPDeviceExtensionDelegate, ICISMPDeviceDelegate, SignatureViewDelegate, NSStreamDelegate, UITextFieldDelegate>{
    NSDate				*startDate;
	NSDate				*resignActiveDate;
	
	NSUInteger			  _vCursor;
	
	NSUInteger			  entryNumber;
	NSUInteger			  trashTextLength;
	
	BOOL				 _logToFile;
}
@property (nonatomic, strong) NSOutputStream *logStream;
//iSMP
@property (nonatomic, strong) ICAdministration *configurationChannel;
@property (nonatomic, strong) PosMessage *posMessage;

//data for displayable cells
@property (nonatomic, strong) NSArray *displayableArray;

//
@property (nonatomic) BOOL shouldCaptureSignature;

@end

@implementation STBMessagingViewController

@synthesize logStream = _logStream;
@synthesize configurationChannel = _configurationChannel;

#pragma mark - Private const

static NSString *const kTransactionInfoCell = @"TransactionInfoCell";
static NSString *const kSignatureCell       = @"SignatureCell";
static NSString *const kMessageFromPOSCell  = @"MessageFromPOSCell";

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
    // Do any additional setup after loading the view.
    [self setupUI];
    
    //Set texts
    _navItem.title = @"iSMP->iPhone";
    
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
    
    //init data
    _shouldCaptureSignature = YES;
    
    //receive message
    [self pay];
    
#warning Data for testing..
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"message" ofType:@"json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    self.posMessage = [[PosMessage alloc] initWithMessage:[dict objectForKey:@"SALE"]];
    self.displayableArray = [self displayableArrayWithPosMessage:_posMessage];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self initializeConfigurationChannel];
    
    [_tableView reloadData];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load content

- (NSArray *)displayableArrayWithPosMessage:(PosMessage *)aPosMessage{
    NSMutableArray *array = [NSMutableArray array];
    
    if (aPosMessage) {
        [array addObject:kTransactionInfoCell];
        if ([aPosMessage shouldRequireSignature])
            [array addObject:kSignatureCell];
    }
    else{
        [array addObject:kMessageFromPOSCell];
    }
    
    return array;
}

#pragma mark - UI

- (void)setupUI{
    UIBarButtonItem *customBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(buttonBackTouch:)];
    _navItem.leftBarButtonItem = customBackButton;
    
    UIBarButtonItem *customDoneButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(buttonSendTouch:)];
    _navItem.rightBarButtonItem = customDoneButton;
    
    UIColor *barColor   = [UIColor colorWithRed:161.0/255.0 green:164.0/255.0 blue:166.0/255.0 alpha:1.0];
    UIColor *titleColor = [UIColor colorWithRed:55.0/255.0 green:70.0/255.0 blue:77.0/255.0 alpha:1.0];
    
    if([_navigationBar respondsToSelector:@selector(setBarTintColor:)])
        [_navigationBar setBarTintColor:barColor];
    else
        [_navigationBar setTintColor:barColor];
    
    NSDictionary *navBarTitleDict;
    navBarTitleDict = @{NSForegroundColorAttributeName:titleColor,
                        NSFontAttributeName:[UIFont systemFontOfSize:21.0f]
                        };
    [_navigationBar setTitleTextAttributes:navBarTitleDict];
    
    [self setupPlainTableView:_tableView showScrollIndicator:NO hasBorder:NO hasSeparator:NO];
}

#pragma mark - Handle user's actions

- (void)buttonBackTouch:(UIBarButtonItem *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonSendTouch:(UIBarButtonItem *)sender{
    [UIAlertView alertViewWithTitle:@"" message:@"We are implementing this function. It will be come soon :-)" cancelButtonTitle:@"Okay"];
}

#pragma mark - iSpm Info

- (void)initializeConfigurationChannel{
    //Check the settings to know how to initialize the ICAdministration object
    if ([[SettingsManager sharedSettingsManager] pclInterfaceType] == SERIAL) {
        DLog(@"Using PCL over Serial");
        
        self.configurationChannel = [ICAdministration sharedChannel];
        _configurationChannel.delegate = self;
        
        [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
    }
    else if ([[SettingsManager sharedSettingsManager] pclInterfaceType] == TCP) {
        DLog(@"Using PCL over TCP/IP");
        //Do Nothing - Wait for the PPP channel to open
    }
}

#pragma mark - ICAdministrationDelegateStandAlone

- (void)messageReceivedWithData:(NSData *)data {
	NSString *msg = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
	[self logMessage:@"Just received a message from the iSMP"];
	[self logMessage:[NSString stringWithFormat:@"Content: %@", msg]];
    
//    [self performSelector:@selector(send) withObject:nil afterDelay:0];
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
	resignActiveDate = [NSDate date];
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
	startDate = [NSDate date];
}

- (NSTimeInterval)endTimeMeasure {
	NSTimeInterval interval =- [startDate timeIntervalSinceNow];
    
	return interval;
}

- (void)clearLog {
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
    NSString *retValue = @"";
    
    switch (result) {
        case ISMP_Result_SUCCESS:                         retValue = @"OK"; break;
        case ISMP_Result_Failure:                         retValue = @"KO"; break;
        case ISMP_Result_TIMEOUT:                         retValue = @"TIMEOUT"; break;
        case ISMP_Result_ISMP_NOT_CONNECTED:              retValue = @"ISMP NOT CONNECTED"; break;
        case ISMP_Result_ENCRYPTION_KEY_INVALID:          retValue = @"ENCRYPTION KEY INVALID"; break;
        case ISMP_Result_ENCRYPTION_KEY_NOT_FOUND:        retValue = @"ENCRYPTION KEY NOT FOUND"; break;
        case ISMP_Result_ENCRYPTION_DLL_MISSING:          retValue = @"ENCRYPTION DLL Missing"; break;
        default:                                          retValue = [NSString stringWithFormat:@"Unknown Result Code %x", result];
            break;
    }
    
    return retValue;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_displayableArray && [_displayableArray count] > 0)
        return [_displayableArray count];
    
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    NSString *cellKey = [_displayableArray objectAtIndex:indexPath.row];
    
    if ([cellKey isEqualToString:kTransactionInfoCell]) {
        cell = [self tableView:tableView transactionInfoCellAtIndexPath:indexPath];
    }
    else if ([cellKey isEqualToString:kSignatureCell]) {
        cell = [self tableView:tableView signatureCellAtIndexPath:indexPath];
    }
    else{
        NSString *CellIdentifier = kMessageFromPOSCell;
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
        
        cell.textLabel.text = @"Please waiting for the transction...";
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView transactionInfoCellAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TransactionInfoCell";
    TransactionInfoCell *cell = (TransactionInfoCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[TransactionInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [cell setPosMessage:_posMessage];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView signatureCellAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SignatureCell";
    SignatureCell *cell = (SignatureCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[SignatureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    //[cell setParentView:self];
    [cell setPosMessage:_posMessage];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    CGFloat width  = CGRectGetWidth(tableView.frame);
    
    NSString *cellKey = [_displayableArray objectAtIndex:indexPath.row];
    
    if ([cellKey isEqualToString:kTransactionInfoCell]) {
        height = [TransactionInfoCell heightForPosMessage:_posMessage parentWidth:width];
    }
    else if ([cellKey isEqualToString:kSignatureCell]) {
        height = [SignatureCell heightForPosMessage:_posMessage parentWidth:width];
    }
    else{
        height = tableView.rowHeight;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellKey = [_displayableArray objectAtIndex:indexPath.row];
    if ([cellKey isEqualToString:kSignatureCell]) {
        [self doSignatureCapture];
    }
}

#pragma mark - Signature Capture

- (void)pay {
    //Prepare the transaction request
	ICTransactionRequest request;
	NSString * str_amount = nil;
    str_amount = [NSString stringWithFormat:@"%08d", 5];
	
	strncpy(request.amount, [str_amount UTF8String], (unsigned int)sizeof(request.amount));
	request.accountType = '0';
	strncpy(request.currency, "978", (unsigned int)sizeof(request.currency));
	request.specificField = '1';
	request.transactionType = '0';
	strncpy(request.privateData, "0000000000", (unsigned int)sizeof(request.privateData));
	request.posNumber = 1;
	request.delay = '1';
	request.authorization = '0';
    
    //Perform the transaction
	[self.configurationChannel doTransaction:request];
}

- (void)shouldDoSignatureCapture:(ICSignatureData)signatureData {
	DLog(@"Draw Signature Request Received");
    
    [self doSignatureCapture];
    
    DLog(@"You have %d seconds to draw your signature", signatureData.userSignTimeout);
}

- (void)signatureTimeoutExceeded {
	DLog(@"Signature Capture Timeout");
    [UIAlertView alertViewWithTitle:@"" message:@"Signature Capture Timeout"];
}

- (void)doSignatureCapture{
    STBSignatureViewController *signatureViewController = [[STBSignatureViewController alloc] initWithNibName:@"STBSignatureViewController" bundle:nil];
    signatureViewController.delegate = self;
    [self presentPopupViewController:signatureViewController animationType:MJPopupViewAnimationSlideBottomBottom];
    
    _shouldCaptureSignature = YES;
    [self beginTimeMeasure];
}

- (void)signatureWithImage:(UIImage *)signature{
    //close view
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    if (!_shouldCaptureSignature) return;
    
    //submit
    [self.configurationChannel submitSignatureWithImage:signature];
    
    DLog(@"Signature submitted. Total Time: %f", [self endTimeMeasure]);
    _shouldCaptureSignature = NO;
    
    if (signature)
        _posMessage.signature = signature;
    [_tableView reloadData];
}

@end
