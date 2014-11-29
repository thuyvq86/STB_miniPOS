//
//  ConfigurationController.h
//  InteractivePayment
//
//  Created by Hichem Boussetta on 09/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface ConfigurationController : UIViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate, SettingsManagerDelegate>

@property (nonatomic, retain) IBOutlet UITextField          * tpvNumber;
@property (nonatomic, retain) IBOutlet UITextField          * cashNumber;
@property (nonatomic, retain) IBOutlet UITextField          * paymentApplicationNumber;
@property (nonatomic, retain) IBOutlet UITextField          * transactionTimeout;
@property (nonatomic, retain) IBOutlet UISwitch             * useExtendedTransaction;
@property (nonatomic, retain) IBOutlet UITextField          * receiptTextSize;
@property (nonatomic, retain) IBOutlet UIScrollView         * scrollView;
@property (nonatomic, retain) IBOutlet UISwitch             * cradleMode;
@property (nonatomic, retain) IBOutlet UISwitch             * emailedReceiptTiffConversion;
@property (nonatomic, retain) IBOutlet UISwitch             * creditEnabled;

-(IBAction)done:(id)sender;
-(IBAction)sendTracesByMail:(id)sender;
-(IBAction)infoButtonPressed;

-(void)loadConfiguration;

@end
