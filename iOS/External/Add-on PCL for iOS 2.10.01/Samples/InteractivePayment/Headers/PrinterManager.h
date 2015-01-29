//
//  PrinterManager.h
//  InteractivePayment
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>




//This protocol is to be implemented by classes capable of printing receipts
@protocol PrinterProtocol

//Request to clear the current receipt on a class that performs printing - This goes for iSMPControlManager and PrinterManager each of which implements a kind of printing supported by the iSMP
-(void)clearReceiptData;

//Request to retrieve the current receipt
-(id)getLastReceipt;

@end


//This protocol is to be implmented by receivers that may be interested of displaying receipts
@protocol PrinterDelegate

//Callback received by delegates to inform them that the printed receipt has changed
-(void)shouldRefreshReceipt:(id)receipt;

//Callback that are triggered when there is or there is no printing activity - Delegates may start an animation when the printing goes on, and stop it when it stops
-(void)shouldStartPrintingAnimation;
-(void)shouldStopPrintingAnimation;

@end



//This class is a singleton wrapper to ICPrinter object
@interface PrinterManager : NSObject <ICISMPDeviceDelegate, ICPrinterDelegate, PrinterProtocol>

@property (nonatomic, assign)   id<PrinterDelegate>   delegate;


+(PrinterManager *)sharedPrinterManager;

//Start or Stop the PrinterManager - These will open/close the printer channel
-(void)start;
-(void)stop;

@end
