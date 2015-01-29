//
//  iSMPControlManager.m
//  StandaloneSample
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Theoris. All rights reserved.
//

#import "iSMPControlManager.h"

#define DEFAULT_REFRESH_TIMEOUT     1           // 1 second is the timeout after which a refreshReceipt event is fired if no printing activity was noticed during this period


#define REQUEST_EMAIL_START         @"email_start"
#define REQUEST_EMAIL_END           @"email_end"
#define REQUEST_AMOUNT              @"amount"


//Private methods & properties of iSMPControlManager
@interface iSMPControlManager ()

@property (nonatomic, assign) ICBitmapReceipt       * bitmapReceipt;
@property (nonatomic, assign) NSUInteger              refreshTimeout;

//Callbacks triggered when becomeActive and ResignActive notification are received - This class listens for these in order to determine whether it should or shouldn't close the communication channels
-(void)appActive;
-(void)appResignActive;

//Method to be performed in background since opening the channel may take a long time
-(void)backgroundOpen;

//This function is called each time a printing request is received - it is responsible of notifying delegates that there is a printing activity
-(void)detectPrinting;

//This function is called to refresh the receipt - it internally fires an event to notify delegates that the current receipt has been updated
-(void)refreshReceipt;

-(void)processRequest:(NSString *)request;
-(void)onStartEmail;
-(void)onEndEmail:(NSString *)subject :(NSString *)receiptName :(NSArray *)receipients;

//The following function is called when the transaction is started in standalone mode from the terminal - This means the no call to doTransaction was issued from the app - The amount in this case is typed on the terminal
-(void)onReceivedAmount:(NSString *)amount;

@end


static iSMPControlManager * g_sharedISMPControlManager = nil;

@implementation iSMPControlManager

@synthesize control = _control;
@synthesize customerSignature;

+(iSMPControlManager *)sharedISMPControlManager {
    if (g_sharedISMPControlManager == nil) {
        g_sharedISMPControlManager = [[iSMPControlManager alloc] init];
    }
    return g_sharedISMPControlManager;
}


-(id)init {
    if ((self = [super init])) {
        _delegateList = (NSObject **)malloc(CALLBACK_DISPATCHER_DELEGATE_COUNT * sizeof(NSObject *));
        _delegateCount = 0;
        
        self.bitmapReceipt  = [ICBitmapReceipt sharedBitmapReceipt];
        self.refreshTimeout = DEFAULT_REFRESH_TIMEOUT;
        
        
        //FOR TESTING
        
        /*
         [self.bitmapReceipt drawText:@"Hello1"];
         self.bitmapReceipt.textXScaling = 2;
         [self.bitmapReceipt drawText:@"Hello2"];
         self.bitmapReceipt.textXScaling = 1;
         [self.bitmapReceipt drawText:@"Hello3"];
         self.bitmapReceipt.textXScaling = 2;
         [self.bitmapReceipt drawText:@"Hello4"];
         self.bitmapReceipt.textXScaling = 4;
         [self.bitmapReceipt drawText:@"Hello5"];
         */
        
        
        /*
        char letters[3] = {0xE0, 0xE1, 0xE2};
        //NSString * str = [NSString stringWithCString:letters encoding:NSUTF8StringEncoding];
        NSString * str = @"ABC";
        CFStringRef _str = (CFStringRef)str;
        UInt8 buffer[4096];
        CFIndex usedBufLen;
        CFStringGetBytes(_str, CFRangeMake(0, CFStringGetLength(_str)), kCFStringEncodingISOLatinHebrew, '?', FALSE, buffer, sizeof(buffer), &usedBufLen);
        
        CFStringRef hebrewString = CFStringCreateWithBytes(kCFAllocatorDefault, buffer, usedBufLen, kCFStringEncodingISOLatinHebrew, NO);
        //CFStringRef hebrewString = CFStringCreateWithBytes(kCFAllocatorDefault, (const UInt8 *)letters, strlen(letters), kCFStringEncodingISOLatinHebrew, NO);
        NSLog(@"HebrewString: %@", hebrewString);
        [self.bitmapReceipt drawTextAdvanced:(NSString *)hebrewString];
        
         [self.bitmapReceipt drawBitmapWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iphone_payment" ofType:@"png"]]];
         self.bitmapReceipt.textSize = 30;
         [self.bitmapReceipt drawTextAdvanced:@"Hello1"];
         self.bitmapReceipt.textSize = 20;
         [self.bitmapReceipt drawTextAdvanced:@"Hello2\n"];
         self.bitmapReceipt.textFont = @"Arial-BoldMT";
         [self.bitmapReceipt drawTextAdvanced:@"Hello3"];
         self.bitmapReceipt.textSize = 10;
         [self.bitmapReceipt drawTextAdvanced:@"Hello4\n"];
         self.bitmapReceipt.textSize = 40;
         [self.bitmapReceipt drawTextAdvanced:@"Hello5"];
         self.bitmapReceipt.textSize = 60;
         [self.bitmapReceipt drawTextAdvanced:@"Hello6**************************************************************"];
         [self.bitmapReceipt drawBitmapWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iphone_payment" ofType:@"png"]]];
         */
         
        
        _control = [ICAdministration sharedChannel];
        [_control retain];
        _control.delegate = self;
        
        //Check if open method does exist - This method has been added on versions succeeding to LibiSMP_v3.2 - In these version the ICAdministration channel is not opened automatically when the class is instantiated
        if ([_control respondsToSelector:@selector(open)]) {
            
            [self performSelectorInBackground:@selector(backgroundOpen) withObject:nil];
        }
        
        // Subscribe for appActive notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

-(oneway void)release {
    
}

//Opening the ICAdministration channel should be done in background because it may take a lot of time
-(void)backgroundOpen {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if ([_control respondsToSelector:@selector(open)]) {
        [_control open];
    }
    
    //Call the accessoryDidConnect callback on delegates so that they are notified of the state change of the admin channel
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(accessoryDidConnect:)]) {
            [(id<ICISMPDeviceDelegate>)_delegateList[i] accessoryDidConnect:self.control];
        }
    }
    
    [pool release];
}

#pragma mark ICISMPDeviceDelegate

-(void)accessoryDidConnect:(ICISMPDevice*)sender {
    NSLog(@"%s", __FUNCTION__);
    
    [self performSelectorInBackground:@selector(backgroundOpen) withObject:nil];
    
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(accessoryDidConnect:)]) {
            [(id<ICISMPDeviceDelegate>)_delegateList[i] accessoryDidConnect:sender];
        }
    }
}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {
    NSLog(@"%s", __FUNCTION__);
    
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(accessoryDidDisconnect:)]) {
            [(id<ICISMPDeviceDelegate>)_delegateList[i] accessoryDidDisconnect:sender];
        }
    }
}

#pragma mark -

#pragma mark ICAdministrationDelegate - Logging

-(void)confLogEntry:(NSString *)message withSeverity:(int)severity {
    NSLog(@"[%@][%@]", [ICISMPDevice severityLevelString:severity], message);
}

-(void)confSerialData:(NSData *)data incoming:(BOOL)isIncoming {
    NSLog(@"%s [DATA (%@), LENGTH: %lu]\n\t%@", __FUNCTION__, ((isIncoming == YES) ? @"iSMP -> iPhone" : @"iPhone -> iSMP"), (unsigned long)[data length], [data hexDump]);
}


#pragma mark -


#pragma mark Open/Close the communication channel when entering/leaving sleep mode

//Start the administration channel
-(void)start {
    NSLog(@"%s", __FUNCTION__);
    
    //Initialize the control object if not done already
    if (_control == nil) {
        _control = [ICAdministration sharedChannel];
        [_control retain];
        _control.delegate = self;
    }
    
    //Open the admin channel
    if ([_control respondsToSelector:@selector(open)]) {
        [self performSelectorInBackground:@selector(backgroundOpen) withObject:nil];
    }
}

//Stop the administration channel
-(void)stop {
    NSLog(@"%s", __FUNCTION__);
    if (_control != nil) {
        [_control release];
        _control = nil;
    }
}

//Callback triggered when the application becomes active
-(void)appActive {
    NSLog(@"%s", __FUNCTION__);
    [self start];   //Start the administration channel
}

//Callback triggered when the application resigns from active state
-(void)appResignActive {
    NSLog(@"%s", __FUNCTION__);
    
    //Check the cradle mode global parameter and decide whether to close the channel or not
    if ([[SettingsManager sharedSettingsManager] cradleMode] == NO) {
        [self stop];
    } else {
        NSLog(@"%s Cradle Mode Enabled", __FUNCTION__);
    }
}

#pragma mark -


#pragma mark Delegate Management

-(BOOL)addDelegate:(id)delegate {
    NSLog(@"%s", __FUNCTION__);
    BOOL retValue = YES;
    if (_delegateCount < CALLBACK_DISPATCHER_DELEGATE_COUNT) {
        _delegateList[_delegateCount++] = delegate;
    } else {
        retValue = NO;
    }
    return retValue;
}

-(BOOL)removeDelegate:(id)delegate {
    NSLog(@"%s", __FUNCTION__);
    BOOL retValue = NO;
    NSInteger i = 0, j = 0;
    for (i = 0; i < _delegateCount; i++) {
        if (_delegateList[i] == delegate) {
            if (i > 0) {
                for (j = i + 1; j < _delegateCount; j++) {
                    _delegateList[j - 1] = _delegateList[j];
                }
            }
            _delegateCount--;
            retValue = YES;
        }
    }
    return retValue;
}

#pragma mark -

-(BOOL)getISMPState {
    NSLog(@"%s", __FUNCTION__);
    return [ICISMPDevice isAvailable];
}

-(void)clearReceiptData {
    NSLog(@"%s", __FUNCTION__);
    [self.bitmapReceipt clearBitmap];
}

-(id)getLastReceipt {
    NSLog(@"%s", __FUNCTION__);
    return [self.bitmapReceipt getImage];
}


#pragma mark Printing

-(void)detectPrinting {
    NSLog(@"%s", __FUNCTION__);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshReceipt) object:nil];
    
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        //Start printing animation on the receiver
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(shouldStartPrintingAnimation)]) {
            [(id<PrinterDelegate>)_delegateList[i] shouldStartPrintingAnimation];
        }
    }
    
    [self performSelector:@selector(refreshReceipt) withObject:nil afterDelay:self.refreshTimeout];
}

-(void)refreshReceipt {
    NSLog(@"%s", __FUNCTION__);
    
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        //Stop the receiver's printing animation
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(shouldStopPrintingAnimation)]) {
            [(id<PrinterDelegate>)_delegateList[i] shouldStopPrintingAnimation];
        }
        
        //Refresh the receiver
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(shouldRefreshReceipt:)]) {
            //[(id<PrinterDelegate>)_delegateList[i] shouldRefreshReceipt:self.receiptData];
            [(id<PrinterDelegate>)_delegateList[i] shouldRefreshReceipt:[self getLastReceipt]];
        }
    }
}

-(void)shouldFeedPaper {
    NSLog(@"%s", __FUNCTION__);
    [self detectPrinting];
    
    [self.bitmapReceipt skipLine];
}

-(void)shouldCutPaper {
    NSLog(@"%s", __FUNCTION__);
    
    [self.bitmapReceipt skipLine];
    
    NSUInteger align = self.bitmapReceipt.textAlignment;
    self.bitmapReceipt.textAlignment = UITextAlignmentCenter;
    [self.bitmapReceipt drawTextAdvanced:@"------------------------------"];
    self.bitmapReceipt.textAlignment = align;
    
    [self.bitmapReceipt skipLine];
}

-(void)shouldPrintImage:(UIImage *)image {
    NSLog(@"%s", __FUNCTION__);
    [self detectPrinting];
    
    [self.bitmapReceipt drawBitmapWithImage:image];
}


-(void)shouldPrintText:(NSString *)text withFont:(UIFont *)font alignment:(UITextAlignment)alignment XScaling:(NSInteger)xFactor YScaling:(NSInteger)yFactor underline:(BOOL)underline {
    NSLog(@"%s", __FUNCTION__);
    
    [self detectPrinting];
    
    self.bitmapReceipt.textFont         = [font fontName];
    self.bitmapReceipt.textSize         = [[SettingsManager sharedSettingsManager] receiptTextSize];
    self.bitmapReceipt.textAlignment    = alignment;
    self.bitmapReceipt.textXScaling     = xFactor;
    self.bitmapReceipt.textYScaling     = yFactor;
    self.bitmapReceipt.textUnderlining  = underline;
    //[self.bitmapReceipt drawText:text];
    [self.bitmapReceipt drawTextAdvanced:text];
}

-(void)shouldPrintText:(NSString *)text withFont:(UIFont *)font alignment:(UITextAlignment)alignment XScaling:(NSInteger)xFactor YScaling:(NSInteger)yFactor underline:(BOOL)underline bold:(BOOL)bold {
    NSLog(@"%s", __FUNCTION__);
    
    [self detectPrinting];
    
    self.bitmapReceipt.textFont         = [font fontName];
    self.bitmapReceipt.textSize         = [[SettingsManager sharedSettingsManager] receiptTextSize];
    self.bitmapReceipt.textAlignment    = alignment;
    self.bitmapReceipt.textXScaling     = xFactor;
    self.bitmapReceipt.textYScaling     = yFactor;
    self.bitmapReceipt.textUnderlining  = underline;
    self.bitmapReceipt.textInBold       = bold;
    //[self.bitmapReceipt drawText:text];
    [self.bitmapReceipt drawTextAdvanced:text];
}


//Mark the start of a receipt when printing
-(NSInteger)shouldStartReceipt:(NSInteger)receiptType {
    NSLog(@" %s ", __FUNCTION__);
    
    [self.bitmapReceipt drawTextAdvanced:@"******** START RECEIPT ********"];
    switch(receiptType)
    {
        case 0:
            [self.bitmapReceipt drawTextAdvanced:@"MERCHANT"];
            break;
            
        case 1:
            [self.bitmapReceipt drawTextAdvanced:@"CUSTOMER"];
            break;
    }
    return 1;
}

//Mark the end of a receipt when printing
-(NSInteger)shouldEndReceipt {
    NSLog(@" %s ", __FUNCTION__);
    [self.bitmapReceipt drawTextAdvanced:@"******** END RECEIPT ********"];
    return 1;
}

-(NSInteger)shouldAddSignature {
    NSLog(@"%s", __FUNCTION__);
    
    [self shouldPrintImage:[ICSignatureView invertImageColors:self.customerSignature]];
    
    return 0;
}

-(void)printingDidEnded {
    NSLog(@"%s", __FUNCTION__);
	
    //[self refreshReceipt];
}

#pragma mark -


#pragma mark ICAdministrationDelegate - Signature Capture

-(void)shouldDoSignatureCapture:(ICSignatureData)signatureData {
    NSLog(@"%s", __FUNCTION__);
    
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(shouldDoSignatureCapture:)]) {
            [(id<ICAdministrationStandAloneDelegate>)_delegateList[i] shouldDoSignatureCapture:signatureData];
        }
    }
}

-(void)signatureTimeoutExceeded {
    NSLog(@"%s", __FUNCTION__);
    
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(signatureTimeoutExceeded)]) {
            [(id<ICAdministrationStandAloneDelegate>)_delegateList[i] signatureTimeoutExceeded];
        }
    }
}

#pragma mark -


#warning Using Tweaks and Non Official LibiSMP Version - To be removed or Implemented Properly

#pragma mark Messaging

-(void)shouldReplyToLastReceivedMessage {
    NSLog(@"%s", __FUNCTION__);
}

-(void)returnEmailReceiptStatus:(EmailReceiptStatus)status {
    NSLog(@"%s", __FUNCTION__);
    
    if ([self.control respondsToSelector:@selector(replyWithStatus:)]) {
        [self.control replyWithStatus:status];
    }
}

-(void)messageReceivedWithData:(NSData *)data {
    NSLog(@"%s", __FUNCTION__);
    
    //Convert the received data to text
    NSString * receivedRequest = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    //Log the received string
    NSLog(@"%s Received Request: %@", __FUNCTION__, receivedRequest);
    
    //Process received request
    [self processRequest:receivedRequest];
    
    [receivedRequest release];
}

-(void)processRequest:(NSString *)request {
    NSLog(@"%s", __FUNCTION__);
    
    if (request == nil) {
        NSLog(@"%s Received Invalid Request", __FUNCTION__);
    } else {
        NSArray * components = [request componentsSeparatedByString:@","];
        
        if ([components count] == 0) {
            NSLog(@"%s Empty Request", __FUNCTION__);
        } else {
            //Get the first component which is the command
            NSString * command = [components objectAtIndex:0];
            
            //Perform the appropriate action
            if ([command compare:REQUEST_EMAIL_START] == NSOrderedDescending) {
                [self onStartEmail];
            } else if ([command isEqualToString:REQUEST_EMAIL_END]) {
                if ([components count] < 4) {
                    NSLog(@"%s Invalid Number of arguments for request: %@", __FUNCTION__, REQUEST_EMAIL_END);
                } else {
                    NSString * subject      = [components objectAtIndex:1];
                    NSString * receiptName  = [components objectAtIndex:2];
                    NSArray  * receipients  = [[components objectAtIndex:3] componentsSeparatedByString:@";"];
                    
                    [self onEndEmail:subject :receiptName :receipients];
                }
            } else if ([command isEqualToString:REQUEST_AMOUNT]) {
                
                //Check the parameters
                if ([components count] < 2) {
                    NSLog(@"%s Invalid Number of Arguments for request: %@", __FUNCTION__, REQUEST_AMOUNT);
                } else {
                    
                    //Get the Amount
                    NSString * amount = [components objectAtIndex:1];
                    
                    //Notify delegates
                    [self onReceivedAmount:amount];
                }
            }
        }
    }
}

-(void)onStartEmail {
    NSLog(@"%s", __FUNCTION__);
    
    //Clear the receipt to start printing a new one
    [self clearReceiptData];
    
    //Refresh the receipt on the screen
    [self refreshReceipt];
    
    //Reply to send message
    [[iSMPControlManager sharedISMPControlManager] returnEmailReceiptStatus:EmailReceiptStatusSent];
}

-(void)onEndEmail:(NSString *)subject :(NSString *)receiptName :(NSArray *)receipients {
    NSLog(@"%s", __FUNCTION__);
    
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(shouldSendReceiptByMail::::)]) {
            [(id<ISMPControlManagerDelegate>)_delegateList[i] shouldSendReceiptByMail:subject :receiptName :[self getLastReceipt] :receipients];
        }
    }
}


-(void)onReceivedAmount:(NSString *)amount {
    NSLog(@"%s", __FUNCTION__);
    
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(shouldDisplayAmount:)]) {
            [(id<ISMPControlManagerDelegate>)_delegateList[i] shouldDisplayAmount:amount];
        }
    }
}


#pragma mark -

#pragma mark ICAdministrationDelegate - Transaction

-(void)didSpmRespondedToDoTransaction:(BOOL)response withParameters:(ICTransactionReply)_transactionReply {
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(didSpmRespondedToDoTransaction:withParameters:)]) {
            [(id<ICAdministrationStandAloneDelegate>)_delegateList[i] didSpmRespondedToDoTransaction:response withParameters:_transactionReply];
        }
    }
}

-(void)transactionDidEndWithTimeoutFlag:(BOOL)replyReceived result:(ICTransactionReply)transactionReply andData:(NSData *)extendedData {
    NSInteger i = 0;
    for (i = 0; i < _delegateCount; i++) {
        if ([(NSObject *)_delegateList[i] respondsToSelector:@selector(transactionDidEndWithTimeoutFlag:result:andData:)]) {
            [(id<ICAdministrationStandAloneDelegate>)_delegateList[i] transactionDidEndWithTimeoutFlag:replyReceived result:transactionReply andData:extendedData];
        }
    }
}

#pragma mark -



@end



