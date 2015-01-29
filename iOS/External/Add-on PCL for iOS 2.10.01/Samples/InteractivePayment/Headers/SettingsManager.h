//
//  SettingsManager.h
//  CardTest
//
//  Created by Hichem Boussetta on 15/11/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SettingsManagerDelegate

-(void)settingsDidChange;

@end


@interface SettingsManager : NSObject

@property (nonatomic, retain) NSDictionary          * currencyTable;

//Exported properties
@property (nonatomic, assign) NSInteger               doTransactionTimeout;
@property (nonatomic, retain) NSString              * currency;
@property (nonatomic, assign) NSInteger               tpvNumber;
@property (nonatomic, assign) NSInteger               cashNumber;
@property (nonatomic, assign) NSInteger               paymentApplicationNumber;
@property (nonatomic, assign) BOOL                    useExtendedTransaction;
@property (nonatomic, assign) NSInteger               receiptTextSize;
@property (nonatomic, assign) NSInteger               signatureOrientation;     //O: landscape - 1: portrait
@property (nonatomic, assign) BOOL                    cradleMode;
@property (nonatomic, assign) BOOL                    emailedReceiptTiffConversion;
@property (nonatomic, assign) BOOL                    creditEnabled;

@property (nonatomic, assign) id<SettingsManagerDelegate>   delegate;


+(SettingsManager *)sharedSettingsManager;

-(void)saveSettings;
-(void)loadSettings;
-(NSString *)getCurrentCurrencyCode;

@end
