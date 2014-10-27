//
//  SecondViewController.m
//  InteractivePayment
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import "SecondViewController.h"

#import <ImageIO/ImageIO.h>

@implementation SecondViewController

@synthesize webView;
@synthesize activityIndicator;
@synthesize printerManager;
@synthesize control;
@synthesize theReceipt;
@synthesize printEmailSaveActionSheet;


#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"185-printer"];
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
    
    self.title = NSLocalizedString(@"RECEIPT", @"");
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
    
    //Set the PrinterManager delegate to self
    self.printerManager = [PrinterManager sharedPrinterManager];
    self.printerManager.delegate = self;
    
    //Subscribe as delegate of iSMPControlManager (used also for printing)
    self.control = [iSMPControlManager sharedISMPControlManager];
    [self.control addDelegate:self];
    
    [self shouldRefreshReceipt:[[ICBitmapReceipt sharedBitmapReceipt] getImage]];
    
    self.printEmailSaveActionSheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self 
                                                            cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") destructiveButtonTitle:nil
                                                            otherButtonTitles:@"AirPrint", NSLocalizedString(@"EMAIL", @""), NSLocalizedString(@"SAVE_TO_PHOTO_LIBRARY", @""), nil] autorelease];
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


#pragma mark UI Actions

-(IBAction)clearWebView:(id)sender {
    [self.printerManager clearReceiptData];
    [self.control clearReceiptData];
    [self shouldRefreshReceipt:nil];
}

-(IBAction)save:(id)sender {
    if ([self.theReceipt isKindOfClass:[UIImage class]]) {
        //UIImageWriteToSavedPhotosAlbum(self.theReceipt, self, @selector(onSave), NULL);
        UIImageWriteToSavedPhotosAlbum(self.theReceipt, nil, nil, NULL);
        
        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SAVE", @"") message:NSLocalizedString(@"RECEIPT_SAVED_MESSAGE", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"CLOSE", @"") otherButtonTitles:nil, nil] autorelease];
        [alert show];
    } else if ([self.theReceipt isKindOfClass:[NSData class]]) {
        
    }
}


-(IBAction)printEmailSave:(id)sender {
    [self.printEmailSaveActionSheet showFromBarButtonItem:sender animated:YES];
}

-(void)onSave {
    UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SAVE", @"") message:NSLocalizedString(@"RECEIPT_SAVED_MESSAGE", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"CLOSE", @"") otherButtonTitles:nil, nil] autorelease];
    [alert show];
}

#pragma mark -


#pragma mark PrinterDelegate

-(void)shouldRefreshReceipt:(id)receipt {
    NSLog(@"%s", __FUNCTION__);
    
    self.theReceipt = receipt;
    if ([receipt isKindOfClass:[UIImage class]]) {
        [webView loadData:UIImagePNGRepresentation(receipt) MIMEType:@"image/png" textEncodingName:@"utf-8" baseURL:nil];
        UIImage * image = self.theReceipt;
        NSLog(@"%s Width: %f, Height: %f", __FUNCTION__, image.size.width, image.size.height);
    } else if ([receipt isKindOfClass:[NSData class]]) {
        [webView loadData:receipt MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
    } else {
        [webView loadHTMLString:@"" baseURL:nil];
    }
    
    [webView scalesPageToFit];
}

-(void)shouldStartPrintingAnimation {
    [self.activityIndicator startAnimating];
}

-(void)shouldStopPrintingAnimation {
    [self.activityIndicator stopAnimating];
}

#pragma mark -


#pragma mark UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)_webView
{
    [_webView stringByEvaluatingJavaScriptFromString:@"window.scrollTo(document.body.scrollWidth, document.body.scrollHeight);"];
    //[webView scalesPageToFit];
}

#pragma mark -


#pragma mark Save & Print & Email

-(IBAction)printReceipt:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
	UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.delegate = self;
	
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"Interactive Payment";
    pic.printInfo = printInfo;
	
    pic.printingItem = self.theReceipt;
    pic.showsPageRange = NO;
	
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
	^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
		if (!completed && error) {
			NSLog(@"Printing could not complete because of error: %@", error);
		}
	};
	
    [pic presentAnimated:YES completionHandler:completionHandler];	
}

-(IBAction)sendReceiptByMail:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
	if([MFMailComposeViewController canSendMail]) {
		
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		NSMutableString * subject  = [[NSMutableString alloc] initWithString:@"Printed Document"];
		[subject appendString:[[NSDate date] description]];
		[picker setSubject:subject];
		
		// Set up recipients
		//NSArray *toRecipients = [NSArray arrayWithObject:@"hichem.boussetta@ingenico.com"]; 
		//[picker setToRecipients:toRecipients];
        
        if ([self.theReceipt isKindOfClass:[UIImage class]]) {
            if ([[SettingsManager sharedSettingsManager] emailedReceiptTiffConversion] == YES) {
                [picker addAttachmentData:[self.theReceipt TIFFRepresentation] mimeType:@"image/tiff" fileName:@"attachement.tiff"];
            } else {
                [picker addAttachmentData:UIImagePNGRepresentation(self.theReceipt) mimeType:@"image/png" fileName:@"attachement.png"];
            }
        } else if ([self.theReceipt isKindOfClass:[NSData class]]) {
            [picker addAttachmentData:self.theReceipt mimeType:@"application/pdf" fileName:@"attachement.pdf"];
        }
		
		[self presentModalViewController:picker animated:YES];
		[subject release];
		[picker release];		
		
	} else {
        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FAILURE", @"") message:NSLocalizedString(@"EMAIL_NO_ACCOUNT", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"CLOSE", @"") otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	UIAlertView * alert = [[UIAlertView alloc] init];
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
			alert.title = NSLocalizedString(@"EMAIL_CANCELED", @"");
			//alert.message = @"Result: canceled";
			break;
        case MFMailComposeResultSaved:
			alert.title = NSLocalizedString(@"EMAIL_SAVED", @"");
			//alert.message = @"Result: saved";
			break;
        case MFMailComposeResultSent:
			alert.title = NSLocalizedString(@"EMAIL_SENT", @"");
			//alert.message = @"mail sent";
			break;
        case MFMailComposeResultFailed:
			alert.title = NSLocalizedString(@"ERROR", @"");
			//alert.message = @"Result: failed";
			break;
        default:
			alert.title = NSLocalizedString(@"ERROR", @"");
			//alert.message = @"Result: not sent";
			break;
    }
	[alert addButtonWithTitle:NSLocalizedString(@"CLOSE", @"")];
	[alert show];
	[alert release];
    [self dismissModalViewControllerAnimated:YES];	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
			
		case 0: // Print Wifi
			[self printReceipt:nil];
			break;
			
		case 1: // Send Mail
			[self sendReceiptByMail:nil];
			break;
        case 2: // Save to photo library
            [self save:nil];
            break;
			
		default:
			break;
	}
}

#pragma mark -

@end
