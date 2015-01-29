//
//  SettingsManager.m
//  CardTest
//
//  Created by Hichem Boussetta on 15/11/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import "SettingsManager.h"

static SettingsManager * g_sharedSettingsManager = nil;


@interface SettingsManager ()

//-(void)onBatteryStateChanged;

@end


@implementation SettingsManager

@synthesize currencyTable;
@synthesize currency;
@synthesize doTransactionTimeout;
@synthesize tpvNumber;
@synthesize cashNumber;
@synthesize paymentApplicationNumber;
@synthesize useExtendedTransaction;
@synthesize receiptTextSize;
@synthesize signatureOrientation;
@synthesize cradleMode;
@synthesize delegate;
@synthesize creditEnabled;


+(SettingsManager *)sharedSettingsManager {
    if (g_sharedSettingsManager == nil) {
        g_sharedSettingsManager = [[SettingsManager alloc] init];
    }
    return g_sharedSettingsManager;
}


-(id)init {
    if ((self = [super init])) {
        [self loadSettings];
        self.currencyTable  = nil;
        self.delegate       = nil;
        
        //[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBatteryStateChanged) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    }
    return self;
}

-(oneway void)release {
    
}

-(void)loadSettings {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Dump User Defaults
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleId = [bundleInfo objectForKey: @"CFBundleIdentifier"];
    
    NSUserDefaults *appUserDefaults = [[NSUserDefaults alloc] init];
    NSLog(@"Start dumping userDefaults for %@", bundleId);
    NSLog(@"userDefaults dump: %@", [appUserDefaults persistentDomainForName: bundleId]);
    NSLog(@"Finished dumping userDefaults for %@", bundleId);
    [appUserDefaults release];
    
    //Load the user defaults
    self.doTransactionTimeout           = [userDefaults integerForKey:@"do_transaction_timeout"];
    self.currency                       = [userDefaults stringForKey:@"currency"];
    self.tpvNumber                      = [userDefaults integerForKey:@"tpv_number"];
    self.cashNumber                     = [userDefaults integerForKey:@"cash_number"];
    self.paymentApplicationNumber       = [userDefaults integerForKey:@"payment_application_number"];
    self.useExtendedTransaction         = [userDefaults boolForKey:@"use_extended_transaction"];
    self.receiptTextSize                = [userDefaults integerForKey:@"receipt_font_size"];
    self.signatureOrientation           = [userDefaults integerForKey:@"signature_orientation"];
    self.emailedReceiptTiffConversion   = [userDefaults boolForKey:@"emailed_receipt_tiff_conversion"];
    self.creditEnabled                  = [userDefaults boolForKey:@"credit_enabled"];
}

-(void)saveSettings {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Save the user defaults
    [userDefaults setInteger:self.doTransactionTimeout forKey:@"do_transaction_timeout"];
    [userDefaults setObject:self.currency forKey:@"currency"];
    [userDefaults setInteger:self.tpvNumber forKey:@"tpv_number"];
    [userDefaults setInteger:self.cashNumber forKey:@"cash_number"];
    [userDefaults setInteger:self.paymentApplicationNumber forKey:@"payment_application_number"];
    [userDefaults setBool:self.useExtendedTransaction forKey:@"use_extended_transaction"];
    [userDefaults setInteger:self.receiptTextSize forKey:@"receipt_font_size"];
    [userDefaults setInteger:self.signatureOrientation forKey:@"signature_orientation"];
    [userDefaults setBool:self.emailedReceiptTiffConversion forKey:@"emailed_receipt_tiff_conversion"];
    [userDefaults setBool:self.creditEnabled forKey:@"credit_enabled"];
}

-(NSString *)getCurrentCurrencyCode {
    return [self.currencyTable objectForKey:self.currency];
}



#pragma mark Cradle Mode Management

//Battery State Change Handler
/*
-(void)onBatteryStateChanged {
    NSLog(@"%s", __FUNCTION__);
    
    UIDeviceBatteryState batteryState = [[UIDevice currentDevice] batteryState];
    
    if ((batteryState == UIDeviceBatteryStateCharging) || (batteryState == UIDeviceBatteryStateFull)) {
        self.cradleMode = YES;
        NSLog(@"%s Cradle Mode Enabled", __FUNCTION__);
        
        //Open the communication channels if were previously closed
        [[iSMPControlManager sharedISMPControlManager] start];
        [[PrinterManager sharedPrinterManager] start];
        [[GateWayManager sharedGateWayManager] start];
        
    } else {
        self.cradleMode = NO;
        NSLog(@"%s Cradle Mode Disabled", __FUNCTION__);
    }
    
    //Notify the delegate of settings change
    if ([(NSObject *)self.delegate respondsToSelector:@selector(settingsDidChange)]) {
        [self.delegate settingsDidChange];
    }
}
*/

#pragma mark -


@end
