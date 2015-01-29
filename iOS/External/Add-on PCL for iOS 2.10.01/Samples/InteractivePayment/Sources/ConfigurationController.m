//
//  ConfigurationController.m
//  InteractivePayment
//
//  Created by Hichem Boussetta on 09/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ConfigurationController.h"

@implementation ConfigurationController

@synthesize tpvNumber;
@synthesize cashNumber;
@synthesize paymentApplicationNumber;
@synthesize transactionTimeout;
@synthesize useExtendedTransaction;
@synthesize receiptTextSize;
@synthesize scrollView;
@synthesize cradleMode;
@synthesize emailedReceiptTiffConversion;
@synthesize creditEnabled;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Set the scroll view's size
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 700)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Load the configuration from the settings manager
    [self loadConfiguration];
    
    //Register to SettingsManager Events
    [[SettingsManager sharedSettingsManager] setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    //Unregister to SettingsManager Events
    [[SettingsManager sharedSettingsManager] setDelegate:nil];
    
    [super viewWillDisappear:animated];
}


//Deprecated in iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//Replacement in iOS 6 of shouldAutorotateToInterfaceOrientation
-(BOOL)shouldAutorotate {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -


#pragma mark UI Actions

-(void)infoButtonPressed {
    AppInfoController * infoController = [[[AppInfoController alloc] init] autorelease];
    [self presentModalViewController:infoController animated:YES];
}

-(void)loadConfiguration {
    //Get the settings manager
    SettingsManager * settingsManager = [SettingsManager sharedSettingsManager];
    
    //Update UI Elements
    self.tpvNumber.text                             = [NSString stringWithFormat:@"%ld", (long)settingsManager.tpvNumber];
    self.cashNumber.text                            = [NSString stringWithFormat:@"%ld", (long)settingsManager.cashNumber];
    self.paymentApplicationNumber.text              = [NSString stringWithFormat:@"%ld", (long)settingsManager.paymentApplicationNumber];
    self.transactionTimeout.text                    = [NSString stringWithFormat:@"%ld", (long)settingsManager.doTransactionTimeout];
    self.useExtendedTransaction.on                  = settingsManager.useExtendedTransaction;
    self.receiptTextSize.text                       = [NSString stringWithFormat:@"%ld", (long)settingsManager.receiptTextSize];
    self.cradleMode.on                              = settingsManager.cradleMode;
    self.emailedReceiptTiffConversion.on            = settingsManager.emailedReceiptTiffConversion;
    self.creditEnabled.on                           = settingsManager.creditEnabled;
    
    if ([self.transactionTimeout.text intValue] == 0) {
        self.transactionTimeout.text = [NSString stringWithFormat:@"%d", DEFAULT_DO_TRANSACTION_TIMEOUT]; 
    }
    
    if ([self.receiptTextSize.text intValue] <= 0) {
        self.receiptTextSize.text = [NSString stringWithFormat:@"%d", DEFAULT_RECEIPT_TEXT_SIZE];
    }
}

-(IBAction)done:(id)sender {
    //Get the settings manager
    SettingsManager * settingsManager = [SettingsManager sharedSettingsManager];
    
    settingsManager.tpvNumber                       = [self.tpvNumber.text intValue];
    settingsManager.cashNumber                      = [self.cashNumber.text intValue];
    settingsManager.paymentApplicationNumber        = [self.paymentApplicationNumber.text intValue];
    
    if ([self.transactionTimeout.text intValue] > 0) {
        settingsManager.doTransactionTimeout        = [self.transactionTimeout.text intValue];
    }
    settingsManager.doTransactionTimeout            = [self.transactionTimeout.text intValue];
    settingsManager.useExtendedTransaction          = self.useExtendedTransaction.on;
    
    if ([self.receiptTextSize.text intValue] > 0) {
        settingsManager.receiptTextSize             = [self.receiptTextSize.text intValue];
    }
    
    settingsManager.cradleMode                      = self.cradleMode.on;
    settingsManager.emailedReceiptTiffConversion    = self.emailedReceiptTiffConversion.on;
    settingsManager.creditEnabled                   = self.creditEnabled.on;
    
    //Save the configuration
    [settingsManager saveSettings];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -


#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -



#pragma mark Send Traces By Mail


-(IBAction)sendTracesByMail:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    if([MFMailComposeViewController canSendMail]) {
		
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		NSMutableString * subject  = [[NSMutableString alloc] initWithString:@"Printed Document"];
		[subject appendString:[[NSDate date] description]];
		[picker setSubject:subject];
		
		// Set up recipients
		NSArray *toRecipients = [NSArray arrayWithObject:@"hichem.boussetta@ingenico.com"];
		[picker setToRecipients:toRecipients];
        
        NSString * appTraces = [[CrashReporterManager sharedCrashReporterManager] getApplicationLogs];
        [picker addAttachmentData:[NSData dataWithBytes:[appTraces UTF8String] length:[appTraces length]] mimeType:@"text/plain" fileName:@"appLogs.txt"];
		
		[self presentModalViewController:picker animated:YES];
		[subject release];
		[picker release];
		
	} else {
        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"No Email Account" message:@"Please configure an email account in order to be able to send traces" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	UIAlertView * alert = [[UIAlertView alloc] init];
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
			alert.title = @"Canceled";
			//alert.message = @"Result: canceled";
			break;
        case MFMailComposeResultSaved:
			alert.title = @"Mail saved";
			//alert.message = @"Result: saved";
			break;
        case MFMailComposeResultSent:
			alert.title = @"Mail Sent";
			//alert.message = @"mail sent";
			break;
        case MFMailComposeResultFailed:
			alert.title = @"Error";
			//alert.message = @"Result: failed";
			break;
        default:
			alert.title = @"Error";
			//alert.message = @"Result: not sent";
			break;
    }
	[alert addButtonWithTitle:@"Close"];
	[alert show];
	[alert release];
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -

#pragma mark SettingsManagerDelegate

-(void)settingsDidChange {
    NSLog(@"%s", __FUNCTION__);
    
    //Reload the settings
    [self loadConfiguration];
}

#pragma mark -


@end
