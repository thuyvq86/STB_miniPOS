//
//  StandAlonePayment.h
//  Cartes
//
//  Created by Christophe Fontaine on 14/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>




@protocol StandAlonePaymentDelegate

@optional
-(void)initDone;
-(void)initFailed;

-(void)transactionSuccess:(id)userInfo;
-(void)transactionFailed:(id)userInfo;
-(void)transactionTimeout;

-(void)cancellationFailed:(id)userInfo;
-(void)cancellationSucceeded:(id)userInfo;

-(void)totalizationFailed:(id)userInfo;
-(void)totalizationSucceeded:(id)userInfo;

-(void)duplicataFailed:(id)userInfo;
-(void)duplicataSucceeded:(id)userInfo;

-(void)newMessage:(NSString*)message;
-(void)userShouldProvideSignatureWithSize:(CGSize)size;

@end


@interface StandalonePaymentManager : NSObject <ICISMPDeviceDelegate, ICAdministrationStandAloneDelegate>


@property (nonatomic, assign) iSMPControlManager            * iSMPControl;
@property (nonatomic, assign) id<StandAlonePaymentDelegate>	  delegate;

@property (nonatomic, assign) NSInteger              requestReference;
@property (nonatomic, assign) NSInteger              paymentApplicationNumber;


+(StandalonePaymentManager *)sharedStandAlonePaymentManager;


//Payment Methods
-(void)requireDebitPayment:(NSNumber*)amount extendedData:(NSData *)extraData;
-(void)requireCreditPayment:(NSNumber*)amount extendedData:(NSData *)extraData;

-(void)cancellation:(NSNumber *)amount;
-(void)duplicata:(NSNumber *)amount;
-(void)totalization;

-(void)performExtendedDoTransactionWithTransactionRequest:(ICTransactionRequest)request;
-(NSDictionary *)analyseExtendedDoTransactionReplyWith:(NSData *)extendedData;

//Signature Capture
-(void)provideSignature:(UIImage *)signature;

@end
