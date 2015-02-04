//
//  iSMPControlManager.h
//  StandaloneSample
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Theoris. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PrinterManager.h"

#define CALLBACK_DISPATCHER_DELEGATE_COUNT      50           //Max count of iSMPControlManager's delegates


typedef enum  {
    EmailReceiptStatusSent       = 0,
    EmailReceiptStatusCancelled,
    EmailReceiptStatusSaved,
    EmailReceiptStatusFailed,
    EmailReceiptStatusNoAccount
} EmailReceiptStatus;


@protocol ISMPControlManagerDelegate

-(void)shouldSendReceiptByMail:(NSString *)subject :(NSString *)receiptName :(UIImage *)receipt :(NSArray *)receipients;

-(void)shouldDisplayAmount:(NSString *)amount;

- (void)receivedRequest:(NSString *)request;

@end



//This class is singleton wrapper to the ICAdministration object
@interface iSMPControlManager : NSObject <ICISMPDeviceDelegate, ICAdministrationStandAloneDelegate, PrinterProtocol> {
    __strong NSObject       ** _delegateList;
    NSInteger         _delegateCount;
}


@property (nonatomic, readonly) ICAdministration    * control;
@property (nonatomic, retain)   UIImage             * customerSignature;

+(iSMPControlManager *)sharedISMPControlManager;

//Get the state of the iSMP - Connected or not to the iSMP device
-(BOOL)getISMPState;

-(void)returnEmailReceiptStatus:(EmailReceiptStatus)status;

-(BOOL)addDelegate:(id)delegate;
-(BOOL)removeDelegate:(id)delegate;


//Start or Stop the iSMPControlManager - These will open/close the administration channel
-(void)start;
-(void)stop;

@end
