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
//Utils
#import "NSMutableArray+QueueAdditions.h"
//STB API
#import "STBAPIClient.h"
#import "PosMessage+Operations.h"

@interface STBMessagingViewController ()<SignatureViewDelegate>
//iSMP
@property (nonatomic, strong) NSMutableArray *posMessageQueue;
@property (nonatomic, strong) PosMessage *posMessage;
@property (nonatomic, strong) NSArray *displayableArray;
//Capture Signature
@property (nonatomic) BOOL shouldCaptureSignature;

//
@property (nonatomic) NSInteger requestSendCount;

@end

@implementation STBMessagingViewController

@synthesize iSMPControl;
@synthesize paymentManager;
@synthesize profile = _profile;
@synthesize requestSendCount = _requestSendCount;

#pragma mark - Private const

static NSString *const kTransactionInfoCell = @"TransactionInfoCell";
static NSString *const kSignatureCell       = @"SignatureCell";
static NSString *const kMessageFromPOSCell  = @"MessageFromPOSCell";

#pragma mark - Testing

- (void)testing{
    NSString *jsonFile = [[NSBundle mainBundle] pathForResource:@"message" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFile];
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    for (NSString *key in [dict allKeys])
        [self receivedRequest:[dict objectForKey:key]];
}

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
    
    //init data
    _shouldCaptureSignature = YES;
    _requestSendCount = 0;
    self.posMessageQueue = [NSMutableArray array];
    [self pop];
    
    //Get the iSMPControlManager
    self.iSMPControl = [iSMPControlManager sharedISMPControlManager];
    [self.iSMPControl addDelegate:self];
    
    //Get the payment object
    paymentManager = [StandalonePaymentManager sharedStandAlonePaymentManager];
    paymentManager.delegate = self;
    
#if TARGET_IPHONE_SIMULATOR
    [self testing];
#endif
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Refresh the ISMP State
    [self updateISMPState:[self.iSMPControl getISMPState]];
    
    /*
     //Update the Debit/Credit Segment Control
     BOOL creditEnabled = [SettingsManager sharedSettingsManager].creditEnabled;
     self.segmentCreditDebit.hidden = !creditEnabled;
     
     //Show the extended data text field when required
     BOOL useExtendedTransaction = [SettingsManager sharedSettingsManager].useExtendedTransaction;
     self.labelExtendedData.hidden  = !useExtendedTransaction;
     self.textExtendedData.hidden   = !useExtendedTransaction;
     */
    
    [_tableView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ISMPControlManagerDelegate

- (void)shouldSendReceiptByMail:(NSString *)subject :(NSString *)receiptName :(UIImage *)receipt :(NSArray *)receipients{
}

- (void)shouldDisplayAmount:(NSString *)amount{
}

- (void)receivedRequest:(NSString *)request{
    [self.posMessageQueue enqueue:request];
    
    //process the top object
    if (!_posMessage)
        [self pop];
}

- (void)pop{
    self.posMessage = nil; //reset object
    
    //pop a message
    NSString *request = [self.posMessageQueue dequeue];
    if (request)
        self.posMessage = [[PosMessage alloc] initWithMessage:request];
    self.posMessage.merchantId = self.profile.merchantId;
    
    self.displayableArray = [self displayableArrayWithPosMessage:_posMessage];
    
    //update table view
    [_tableView reloadData];
    _navItem.rightBarButtonItem.enabled = (self.posMessage) ? YES : NO;
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
    _navItem.leftBarButtonItem = [self barButtonItemWithTitle:@"Back" style:UIBarButtonItemStylePlain action:@selector(buttonBackTouch:)];
    _navItem.rightBarButtonItem = [self barButtonItemWithTitle:@"Send" style:UIBarButtonItemStyleDone action:@selector(buttonSendTouch:)];;
    
    if([_navigationBar respondsToSelector:@selector(setBarTintColor:)])
        [_navigationBar setBarTintColor:PRIMARY_BACKGROUND_COLOR];
    else
        [_navigationBar setTintColor:PRIMARY_BACKGROUND_COLOR];
    [_navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                             NSFontAttributeName:[UIFont systemFontOfSize:21.0f]
                                             }];
    
    [self setupPlainTableView:_tableView showScrollIndicator:NO hasBorder:NO hasSeparator:NO];
}

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title style:(NSInteger)style action:(SEL)action{
    UIBarButtonItem *button = nil;
    
    button = [[UIBarButtonItem alloc] initWithTitle:title style:style target:self action:action];
    [button setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    return button;
}

#pragma mark - Handle user's actions

- (void)buttonBackTouch:(UIBarButtonItem *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonSendTouch:(UIBarButtonItem *)sender{
    
    //validate data
    if (_posMessage && _posMessage.shouldRequireSignature && !_posMessage.signature) {
        [UIAlertView alertViewWithTitle:@"" message:@"Please sign to pay the total amount according to your card issuer agreement." cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:^(NSInteger buttonIndex, NSString *buttonTitle) {
            //
        } onCancel:^{
            //do next process
            [self doSignatureCapture];
        }];
        return;
    }
    
    //check email - do later
    
    //send the request, when finish, do next process
    _requestSendCount = 0;
    [self sendBill];
}

#pragma mark - STB - APIs

- (void)sendBill{
    _requestSendCount++;
    [_posMessage sendBillWithProfile:_profile completionBlock:^(id responseObject, NSError *error) {
        if (responseObject) {
            DLog(@"success:\n%@", responseObject);
            //continue with the next request
            _requestSendCount = 0;
            [self pop];
        }
        else{
            DLog(@"failure:\n%@", error);
            //send request again if less than third times
            if (_requestSendCount < 3)
                [self sendBill];
            else
                [self failure:error];
        }
    }];
}

- (void)failure:(NSError *)error{
    NSString *msg = [NSString stringWithFormat:@"Error %i", [error code]];
    [UIAlertView alertViewWithTitle:@"" message:msg cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:^(NSInteger buttonIndex, NSString *buttonTitle) {
    } onCancel:^{
        //do next process
        [self pop];
    }];
}

#pragma mark - ICDeviceDelegate

- (void)accessoryDidConnect:(ICISMPDevice *)sender {
    [self updateISMPState:[self.iSMPControl getISMPState]];
}

- (void)accessoryDidDisconnect:(ICISMPDevice *)sender {
	[self updateISMPState:NO];
}

#pragma mark - Run in background

- (void)applicationBecameInactive:(NSNotification *)notification {
    DLog();
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    DLog();
}

- (void)onAccessoryDidConnect:(NSNotification *)notification {
    DLog();
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
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        BOOL available = [self.iSMPControl getISMPState];
        cell.textLabel.text = available ? @"Waiting for the transaction..." : @"";
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
    signatureViewController.posMessage = _posMessage;
    
    [self presentPopupViewController:signatureViewController animationType:MJPopupViewAnimationSlideBottomBottom];
}

- (void)signatureWithImage:(UIImage *)signature email:(NSString *)email{
    //close view
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    
    if (signature)
        _posMessage.signature = signature;
    _posMessage.email = email;
    
    [_tableView reloadData];
}

#pragma mark - Helpers

- (void)updateISMPState:(BOOL)available{
    NSString *statusText     = available ? @"Device ready" : @"Device not ready";
    UIColor *backgroundColor = available ? [UIColor greenColor] : [UIColor redColor];
    
    _lbliSpmConnectionState.backgroundColor = backgroundColor;
    _lbliSpmConnectionState.text			= statusText;
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

- (NSData *)getExtendedDataFromHexString:(NSString *)hexString {
    NSLog(@"%s [Extended Data String: %@]", __FUNCTION__, ((hexString != nil) ? hexString : @"NULL String"));
    
    NSMutableData * result = nil;
    
    if ((hexString != nil) && ([hexString length] > 0)) {
        result = [NSMutableData data];
        
        NSUInteger i = 0, len = [hexString length], anInt = 0;
        NSScanner * scanner = nil;
        
        for (i = 0; i < len - 1; i += 2) {
            
            //Get two hex characeters in each iteration
            NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
            
            //Parse the two hex characters and convert them to an int value
            scanner = [[NSScanner alloc] initWithString:hexCharStr];
            [scanner scanHexInt:&anInt];
            
            //Append the parsed byte to the result
            [result appendBytes:&anInt length:1];
        }
    }
    
    return result;
}

@end
