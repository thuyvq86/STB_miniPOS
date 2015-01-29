//
//  FirstViewController.h
//  InteractivePayment
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface FirstViewController : UIViewController <ICISMPDeviceDelegate, StandAlonePaymentDelegate, UITextFieldDelegate, ISMPControlManagerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>


@property (nonatomic, retain) IBOutlet UILabel                      * labelAmount;
@property (nonatomic, retain) IBOutlet UILabel                      * currency;
@property (nonatomic, retain) IBOutlet UILabel                      * labelISMPState;
@property (nonatomic, retain) IBOutlet UIButton                     * buttonDoTransaction;
@property (nonatomic, retain) IBOutlet UISegmentedControl           * segmentCreditDebit;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView      * activityIndicator;
@property (nonatomic, retain) IBOutlet UITextField                  * doTransactionTimeout;
@property (nonatomic, retain) IBOutlet UITextField                  * textExtendedData;
@property (nonatomic, retain) IBOutlet UILabel                      * labelExtendedData;

@property (nonatomic, assign) iSMPControlManager                    * iSMPControl;
@property (nonatomic, assign) StandalonePaymentManager              * paymentManager;
@property (nonatomic, retain) UIActionSheet                         * otherOperations;


-(IBAction)inputAmount:(id)sender;
-(IBAction)doTransaction:(id)sender;
-(IBAction)onOtherOperationsPressed:(id)sender;

-(void)setAmount:(NSNumber *)amount;
-(void)updateISMPState:(BOOL)available;

-(IBAction)openSettings:(id)sender;

-(void)forwardCustomerSignatureToPaymentObject:(UIImage *)signature;

@end
