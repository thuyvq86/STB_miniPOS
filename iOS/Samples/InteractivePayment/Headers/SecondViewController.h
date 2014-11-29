//
//  SecondViewController.h
//  InteractivePayment
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SecondViewController : UIViewController <PrinterDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate, UIWebViewDelegate>


@property (nonatomic, retain) IBOutlet UIWebView                * webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView  * activityIndicator;
@property (nonatomic, assign) PrinterManager                    * printerManager;
@property (nonatomic, assign) iSMPControlManager                * control;
@property (nonatomic, retain) id                                  theReceipt;
@property (nonatomic, retain) UIActionSheet                     * printEmailSaveActionSheet;

-(IBAction)clearWebView:(id)sender;
-(IBAction)save:(id)sender;
-(IBAction)printEmailSave:(id)sender;
-(void)onSave;

@end
