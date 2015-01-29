//
//  FirstViewController.m
//  InteractivePayment
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import "FirstViewController.h"


#define UIALERTVIEW_TAG_EMAIL_EXTENDED_DATA         0

@interface FirstViewController ()

@property (nonatomic, retain) NSString * amountProvidedByTerminal;

-(void)disableViewUserInteraction;
-(void)enableViewUserInteraction;

-(NSData *)getExtendedDataFromHexString:(NSString *)hexString;
-(void)displayAlertViewWithTitle:(NSString *)title andResult:(NSString *)result;

@end


@implementation FirstViewController

@synthesize labelAmount;
@synthesize currency;
@synthesize labelISMPState;
@synthesize buttonDoTransaction;
@synthesize segmentCreditDebit;
@synthesize activityIndicator;
@synthesize iSMPControl;
@synthesize doTransactionTimeout;
@synthesize paymentManager;
@synthesize amountProvidedByTerminal;
@synthesize textExtendedData;
@synthesize labelExtendedData;


#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"192-credit-card"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Set default amount to 5.00
    self.labelAmount.text = @"5.00";
    
    //Set the appropriate currency symbol
    NSNumberFormatter * formatter = [[[NSNumberFormatter alloc] init] autorelease];
    self.currency.text = [formatter currencySymbol];
    
    //Get the iSMPControlManager
    self.iSMPControl = [iSMPControlManager sharedISMPControlManager];
    [self.iSMPControl addDelegate:self];
    
    //Get the payment object
    paymentManager = [StandalonePaymentManager sharedStandAlonePaymentManager];
    paymentManager.delegate = self;
    
    self.title = NSLocalizedString(@"DO_TRANSACTION", @"");
    
    //Initialize the other operations actionSheet
    self.otherOperations = [[[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"CANCEL", @"")
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Cancellation", @"Duplicata", @"Totalization", nil] autorelease];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Refresh the ISMP State
    [self updateISMPState:[self.iSMPControl getISMPState]];
    
    //Update the Debit/Credit Segment Control
    if ([SettingsManager sharedSettingsManager].creditEnabled) {
        //Show the segmented control
        self.segmentCreditDebit.hidden = NO;
    } else {
        self.segmentCreditDebit.hidden = YES;
    }
    
    //Show the extended data text field when required
    if ([SettingsManager sharedSettingsManager].useExtendedTransaction) {
        self.labelExtendedData.hidden   = NO;
        self.textExtendedData.hidden    = NO;
    } else {
        self.labelExtendedData.hidden   = YES;
        self.textExtendedData.hidden    = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


/*
//Deprecated in iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIDeviceOrientationIsPortrait(interfaceOrientation);
}
*/


//Replacement in iOS 6 of shouldAutorotateToInterfaceOrientation
-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark -


#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -

#pragma mark UI Actions

-(void)disableViewUserInteraction {
    NSLog(@"%s", __FUNCTION__);
    
    [self.activityIndicator startAnimating];
    [self.view setUserInteractionEnabled:NO];
}

-(void)enableViewUserInteraction {
    NSLog(@"%s", __FUNCTION__);
    
    [self.activityIndicator stopAnimating];
    [self.view setUserInteractionEnabled:YES];
}

-(IBAction)openSettings:(id)sender {
    ConfigurationController * configurationController = [[[ConfigurationController alloc] init] autorelease];
    [self presentViewController:configurationController animated:YES completion:nil];
}

-(void)setAmount:(NSNumber *)amount {
    self.labelAmount.text = [NSString stringWithFormat:@"%.02f", [amount doubleValue]];
}

-(IBAction)inputAmount:(id)sender {
    InputAmount * inputAmountController = [[[InputAmount alloc] init] autorelease];
    inputAmountController.parent = self;
    [self presentModalViewController:inputAmountController animated:YES];
}

-(void)updateISMPState:(BOOL)available {
    if (available == YES) {
        self.labelISMPState.text            = NSLocalizedString(@"ISMP_AVAILABLE", @"");
        self.labelISMPState.backgroundColor = [UIColor greenColor];
    } else {
        self.labelISMPState.text            = NSLocalizedString(@"ISMP_UNAVAILABLE", @"");
        self.labelISMPState.backgroundColor = [UIColor redColor];
    }
}


-(NSData *)getExtendedDataFromHexString:(NSString *)hexString {
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
            scanner = [[[NSScanner alloc] initWithString:hexCharStr] autorelease];
            [scanner scanHexInt:&anInt];
            
            //Append the parsed byte to the result
            [result appendBytes:&anInt length:1];
        }
    }
    
    return result;
}


-(IBAction)doTransaction:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    //If the segmented control is hidden, perform a debit. In the other case, check for the user's choice
    if (self.segmentCreditDebit.hidden) {
        
        //Check if we are in extended transaction mode
        if (self.textExtendedData.hidden == YES) {
            [paymentManager requireDebitPayment:[NSNumber numberWithDouble:[labelAmount.text doubleValue]] extendedData:nil];
        } else {
            [paymentManager requireDebitPayment:[NSNumber numberWithDouble:[labelAmount.text doubleValue]] extendedData:[self getExtendedDataFromHexString:self.textExtendedData.text]];
        }
    } else {
        if (segmentCreditDebit.selectedSegmentIndex == 0) {
            //Check if we are in extended transaction mode
            if (self.textExtendedData.hidden == YES) {
                [paymentManager requireCreditPayment:[NSNumber numberWithDouble:[labelAmount.text doubleValue]] extendedData:nil];
            } else {
                [paymentManager requireCreditPayment:[NSNumber numberWithDouble:[labelAmount.text doubleValue]] extendedData:[self getExtendedDataFromHexString:self.textExtendedData.text]];
            }
        } else {
            //Check if we are in extended transaction mode
            if (self.textExtendedData.hidden == YES) {
                [paymentManager requireDebitPayment:[NSNumber numberWithDouble:[labelAmount.text doubleValue]] extendedData:nil];
            } else {
                [paymentManager requireDebitPayment:[NSNumber numberWithDouble:[labelAmount.text doubleValue]] extendedData:[self getExtendedDataFromHexString:self.textExtendedData.text]];
            }
        }
    }
    
    //Disable UI
    [self disableViewUserInteraction];
}


-(IBAction)onOtherOperationsPressed:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    [self.otherOperations showFromBarButtonItem:sender animated:YES];
}

#pragma mark -

#pragma mark IMPDelegate

-(NSString *)analyseTransactionReply:(NSData *)extendedData {
    NSLog(@"%s", __FUNCTION__);
    
    NSMutableString *   result = nil;
    
    if (extendedData != nil) {
        result = [NSMutableString stringWithFormat:@"%@", extendedData];
    }
    
    /*
    NSString *          error                       = nil;
    BOOL                shouldCaptureSignature      = NO;
    NSInteger           transactionReference        = -1;
    
    
    if ((error = [userInfo valueForKey:@"error"]) != nil) {
        [resultMessage appendFormat:@"\n[ERROR: %@]", error];
    }
    
    transactionReference = [(NSNumber *)[userInfo valueForKey:@"transaction_reference"] intValue];
    [resultMessage appendFormat:@"\n[Trace-Nr. %06d]", transactionReference];
    
    if ((shouldCaptureSignature = [(NSNumber *)[userInfo valueForKey:@"signature"] boolValue])) {
        [resultMessage appendFormat:@"\n[Signature Required]"];
    }
    */
    
    
    
    return result;
}

-(void)displayAlertViewWithTitle:(NSString *)title andResult:(NSString *)result {
    NSLog(@"%s", __FUNCTION__);
    
    UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CLOSE", @"") otherButtonTitles:@"Email", nil] autorelease];
    
    alert.tag = UIALERTVIEW_TAG_EMAIL_EXTENDED_DATA;
    
    if ((result != nil) && ([result length] > 0)) {
        
        //Print extended result
        [[ICBitmapReceipt sharedBitmapReceipt] drawTextAdvanced:[NSString stringWithFormat:@"Extended Data: %@", result]];
        
        alert.message = result;
        
        //alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        //UITextField * textField = [alert textFieldAtIndex:0];
        //textField.text = result;
        
        //UITextRange *textRange = [textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument];
        //[textField setSelectedTextRange:textRange];
    }
    
    [alert show];
}

-(void)transactionFailed:(id)userInfo {
    NSLog(@"%s", __FUNCTION__);
    
    [self enableViewUserInteraction];
    
    NSString * resultString = [self analyseTransactionReply:userInfo];
    
    [self displayAlertViewWithTitle:NSLocalizedString(@"TRANSACTION_FAILED", @"") andResult:resultString];
}

-(void)transactionSuccess:(id)userInfo {
    NSLog(@"%s", __FUNCTION__);
    
    [self enableViewUserInteraction];
    
    NSString * resultString = [self analyseTransactionReply:userInfo];
    
    [self displayAlertViewWithTitle:NSLocalizedString(@"TRANSACTION_DONE", @"") andResult:resultString];
}

-(void)transactionTimeout {
    NSLog(@"%s", __FUNCTION__);
    
    [self enableViewUserInteraction];
    
    [self displayAlertViewWithTitle:NSLocalizedString(@"TRANSACTION_TIMEOUT", @"") andResult:@""];
}

//Cancellation Result
-(void)cancellationSucceeded:(id)userInfo {
    NSLog(@"%s", __FUNCTION__);
    
    [self enableViewUserInteraction];
    
    UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"Cancellation Succeeded" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
    [alert show];
}

-(void)cancellationFailed:(id)userInfo {
    NSLog(@"%s", __FUNCTION__);
    
    [self enableViewUserInteraction];
    
    UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"Cancellation Failed" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
    [alert show];
}


//Duplicata Result
-(void)duplicataSucceeded:(id)userInfo {
    NSLog(@"%s", __FUNCTION__);
    
    [self enableViewUserInteraction];
    
    UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"Duplicata Succeeded" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
    [alert show];
}

-(void)duplicataFailed:(id)userInfo {
    NSLog(@"%s", __FUNCTION__);
    
    [self enableViewUserInteraction];
    
    UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"Duplicata Failed" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
    [alert show];
}


//Totalization Result
-(void)totalizationSucceeded:(id)userInfo {
    NSLog(@"%s", __FUNCTION__);
    
    [self enableViewUserInteraction];
    
    UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"Totalization Succeeded" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
    [alert show];
}

-(void)totalizationFailed:(id)userInfo {
    NSLog(@"%s", __FUNCTION__);
    
    [self enableViewUserInteraction];
    
    UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"Totalization Failed" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
    [alert show];
}

-(void)userShouldProvideSignatureWithSize:(CGSize)size {
    NSLog(@"%s", __FUNCTION__);
    
    
    SignatureViewController * signatureViewController   = [[[SignatureViewController alloc] init] autorelease];
    signatureViewController.parent                      = self;
    
    if ((size.width > 320) || (size.height > 190)) {
        signatureViewController.signatureCanvasWidth        = 320;
        signatureViewController.signatureCanvasHeight       = 190;
    } else {
        signatureViewController.signatureCanvasWidth        = size.width;
        signatureViewController.signatureCanvasHeight       = size.height;
    }
    
    //If the amount is typed on the terminal, then the terminalProvidedByTerminal property is not nil - Display this amount, otherwise, display the amount typed on the app
    if (self.amountProvidedByTerminal != nil) {
        
        signatureViewController.amount = self.amountProvidedByTerminal;
        
        //Reset the amount provided by terminal
        self.amountProvidedByTerminal = nil;
        
    } else if ([self.currency.text isEqualToString:@"€"]) {
        signatureViewController.amount                      = [NSString stringWithFormat:@"%@ %@", self.labelAmount.text, self.currency.text];
    } else {
        signatureViewController.amount                      = [NSString stringWithFormat:@"%@ %@", self.currency.text, self.labelAmount.text];
    }
    
    [self presentModalViewController:signatureViewController animated:YES];
    
    
    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] loadSignatureViewInLandscapeModeWithSize:size andParent:self];
}

-(void)forwardCustomerSignatureToPaymentObject:(UIImage *)signature {
    NSLog(@"%s", __FUNCTION__);
    
    //Dismiss all the stacked modal view controllers
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.paymentManager provideSignature:signature];
}

#pragma mark -

#pragma mark ICISMPDeviceDelegate

-(void)accessoryDidConnect:(ICISMPDevice *)sender {
    [self updateISMPState:[self.iSMPControl getISMPState]];
}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {
    [self updateISMPState:NO];
}

#pragma mark -


#pragma mark EmailingProtocolDelegate

-(void)shouldSendReceiptByMail:(NSString *)subject :(NSString *)receiptName :(UIImage *)receipt :(NSArray *)receipients {
    NSLog(@"%s", __FUNCTION__);
    
    if([MFMailComposeViewController canSendMail]) {
		
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:subject];
		
		// Set up recipients
		[picker setToRecipients:receipients];
        
        //Add attachments
        if ([[SettingsManager sharedSettingsManager] emailedReceiptTiffConversion] == YES) {
            [picker addAttachmentData:[receipt TIFFRepresentation] mimeType:@"image/tiff" fileName:receiptName];
        } else {
            [picker addAttachmentData:UIImagePNGRepresentation(receipt) mimeType:@"image/png" fileName:receiptName];
        }
		
		[self presentModalViewController:picker animated:YES];
		[picker release];
		
	} else {
        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FAILURE", @"") message:NSLocalizedString(@"EMAIL_NO_ACCOUNT", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"CLOSE", @"") otherButtonTitles:nil, nil] autorelease];
        [alert show];
        
        //Send back the result
        [[iSMPControlManager sharedISMPControlManager] returnEmailReceiptStatus:EmailReceiptStatusNoAccount
         ];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    
    EmailReceiptStatus emailStatus = EmailReceiptStatusFailed;
    
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
			emailStatus = EmailReceiptStatusCancelled;
			break;
        case MFMailComposeResultSaved:
			emailStatus = EmailReceiptStatusSaved;
			break;
        case MFMailComposeResultSent:
			emailStatus = EmailReceiptStatusSent;
			break;
        case MFMailComposeResultFailed:
			emailStatus = EmailReceiptStatusFailed;
			break;
        default:
			break;
    }
	
    //Send back the result
    [[iSMPControlManager sharedISMPControlManager] returnEmailReceiptStatus:emailStatus];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)shouldDisplayAmount:(NSString *)amount {
    NSLog(@"%s [Amount: %@]", __FUNCTION__, amount);
    
    self.amountProvidedByTerminal = amount;
}

#pragma mark -


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
	switch (buttonIndex) {
			
		case 0: // Cancellation
			
            //Disable UI
            [self disableViewUserInteraction];
            
            [paymentManager cancellation:[NSNumber numberWithDouble:[labelAmount.text doubleValue]]];
            
			break;
			
		case 1: // Duplicata
			
            //Disable UI
            [self disableViewUserInteraction];
            
            [paymentManager duplicata:[NSNumber numberWithDouble:[labelAmount.text doubleValue]]];
            
			break;
        case 2: // Totalization
            
            //Disable UI
            [self disableViewUserInteraction];
            
            [paymentManager totalization];
            
            break;
            
        case 3:
            
            break;
			
		default:
			break;
	}
}

#pragma mark -


#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case UIALERTVIEW_TAG_EMAIL_EXTENDED_DATA:
            switch (buttonIndex) {
                case 0:             //Cancel
                    //Do Nothing
                    break;
                    
                case 1:             //Email
                    
                    if([MFMailComposeViewController canSendMail]) {
                        
                        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                        picker.mailComposeDelegate = self;
                        
                        [picker setSubject:@"InteractivePayment Returned Extended Data"];
                        
                        // Set up recipients
                        [picker setToRecipients:[NSArray arrayWithObject:@"armands@temporarius.com"]];
                        
                        [picker setMessageBody:alertView.message isHTML:NO];
                        
                        [self presentModalViewController:picker animated:YES];
                        [picker release];
                        
                    } else {
                        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FAILURE", @"") message:NSLocalizedString(@"EMAIL_NO_ACCOUNT", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"CLOSE", @"") otherButtonTitles:nil, nil] autorelease];
                        [alert show];
                    }
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark -



@end
