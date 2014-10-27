//
//  StandAlonePayment.m
//  Cartes
//
//  Created by Christophe Fontaine on 14/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "StandalonePaymentManager.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

#import "derTlv.h"


#define EXT_DO_TRANSACTION_CTAG_REQUEST         0xFC
#define EXT_DO_TRANSACTION_CTAG_REPLY           0xFD
#define EXT_DO_TRANSACTION_TAG_REQUEST_REF      0xDD
#define EXT_DO_TRANSACTION_TAG_REQUEST_TYPE     0xDC
#define EXT_DO_TRANSACTION_TAG_TRANSACTION_REF  0xDE
#define EXT_DO_TRANSACTION_TAG_CVM              0x9F34
#define EXT_DO_TRANSACTION_LEN_TRANSACTION_REF  4
#define EXT_DO_TRANSACTION_LEN_CVM              3
#define EXT_DO_TRANSACTION_MAX_REQUEST_REF      1000


#define PDA_RQ_REVERSAL_TXN                     2
#define PDA_RQ_PURCHASE_TXN                     10
#define PDA_RQ_REFUND_TXN                       11
#define PDA_RQ_TIPABLE_TXN                      12
#define PDA_RQ_TIP_TXN_UPDATE                   13
#define PDA_RQ_TIP_TXN_TOTAL                    14
#define PDA_RQ_CLEARING                         15
#define PDA_RQ_LAST_TXN_CHECK                   16


typedef enum {
    TRANSACTION_TYPE_DEBIT          = '0',
    TRANSACTION_TYPE_CREDIT         = '1',
    TRANSACTION_TYPE_CANCELLATION   = '2',
    TRANSACTION_TYPE_DUPLICATA      = '3',
    TRANSACTION_TYPE_TOTALIZATION   = '4'
} TransactionType;


@interface StandalonePaymentManager ()

-(void)setDoTransactionTimeout;
-(NSString *)getCurrentCurrencyIsoCode;

@property (nonatomic, assign) TransactionType           transactionType;

@end


@implementation StandalonePaymentManager
@synthesize delegate;
@synthesize iSMPControl;
@synthesize requestReference = _requestReference;
@synthesize paymentApplicationNumber;


static StandalonePaymentManager * g_sharedStandalonePaymentManager = nil;

+(id)sharedStandAlonePaymentManager {
	@synchronized(g_sharedStandalonePaymentManager) {
		if(g_sharedStandalonePaymentManager == nil) {
			g_sharedStandalonePaymentManager = [[StandalonePaymentManager alloc] init];
		}
		return g_sharedStandalonePaymentManager;		
	}
}

-(id)init {
	if ((self = [super init])) {
        
		self.iSMPControl                = [iSMPControlManager sharedISMPControlManager];
        self.requestReference              = 1;
        self.paymentApplicationNumber   = 0;
        [self.iSMPControl addDelegate:self];
	}
	return self;
}


-(id) retain {
	return self;
}

-(oneway void) release {
	
}

-(id) autorelease {
	return self;
}

-(NSUInteger)retainCount {
	return -1;
}


-(void)setDoTransactionTimeout {
    SettingsManager * settingsManager = [SettingsManager sharedSettingsManager];
    NSUInteger timeout = settingsManager.doTransactionTimeout;
    if (timeout == 0) {
        timeout = DEFAULT_DO_TRANSACTION_TIMEOUT;
    }
    [self.iSMPControl.control setDoTransactionTimeout:timeout];
}


-(NSString *)getCurrentCurrencyIsoCode {
    NSLog(@"%s", __FUNCTION__);
    
    //Set the appropriate currency symbol
    NSNumberFormatter * formatter = [[[NSNumberFormatter alloc] init] autorelease];
    NSString * currencyCode = [formatter currencyCode];
    NSString * isoCode = nil;
    
    if ([currencyCode isEqualToString:@"EUR"]) {
        isoCode = @"978";
    } else if ([currencyCode isEqualToString:@"USD"]) {
        //isoCode = @"840";
        isoCode = @"978";   //For testing since the terminal apps used do not work with USD
    } else if ([currencyCode isEqualToString:@"ILS"]) {
        isoCode = @"376";
    } else if ([currencyCode isEqualToString:@"GBP"]) {
        isoCode = @"999";
    } else {
        //return EUR iso code by default
        isoCode = @"978";
    }
    
    return isoCode;
}

#pragma mark IngenicoMobilePaymentProtocol

-(void)impInit {
	if([(id<NSObject>)self.delegate respondsToSelector:@selector(initDone)]) {
		[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(initDone) withObject:nil waitUntilDone:NO];
	}	
}


-(void)requireDebitPayment:(NSNumber *)amount extendedData:(NSData *)extraData {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    SettingsManager * settings = [SettingsManager sharedSettingsManager];
	ICTransactionRequest request;
    
    //Set the transaction type - this is necessary to determine which callback should be performed when the transaction is done
    self.transactionType = TRANSACTION_TYPE_DEBIT;
    
	const char * c_amount = [[NSString stringWithFormat:@"%08d", (int)([amount doubleValue] * 100)] UTF8String];
	strncpy(request.amount, c_amount, (unsigned int)sizeof(request.amount));
	request.accountType = '0';
	memcpy(request.currency, [[self getCurrentCurrencyIsoCode] UTF8String], 3);
	request.specificField = '1';
	request.transactionType = '0';      // Debit
	strncpy(request.privateData, "0000000000", (unsigned int)sizeof(request.privateData));
	request.posNumber = settings.cashNumber;
	request.delay = '0';
	request.authorization = '0';
    
    [self setDoTransactionTimeout];
    
	if ([iSMPControl getISMPState] == YES) {
        
		if (extraData != nil) {
            //[self performExtendedDoTransactionWithTransactionRequest:request];
            
            [iSMPControl.control doTransaction:request withData:extraData andApplicationNumber:settings.paymentApplicationNumber];
            
        } else {
            [iSMPControl.control doTransaction:request];
        }
	}
	else {
		if([(id<NSObject>)self.delegate respondsToSelector:@selector(transactionFailed:)]) {
			[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(transactionFailed:) withObject:nil waitUntilDone:NO];
		}
	}
	[pool release];
}


-(void)requireCreditPayment:(NSNumber *)amount extendedData:(NSData *)extraData {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    SettingsManager * settings = [SettingsManager sharedSettingsManager];
	ICTransactionRequest request;
    
    //Set the transaction type - this is necessary to determine which callback should be performed when the transaction is done
    self.transactionType = TRANSACTION_TYPE_CREDIT;
    
	const char * c_amount = [[NSString stringWithFormat:@"%08d", (int)([amount doubleValue] * 100)] UTF8String];
	strncpy(request.amount, c_amount, (unsigned int)sizeof(request.amount));
	request.accountType = '0';
	memcpy(request.currency, [[self getCurrentCurrencyIsoCode] UTF8String], 3);
	request.specificField = '1';
	request.transactionType = '1';      // Credit
	strncpy(request.privateData, "0000000000", (unsigned int)sizeof(request.privateData));
	request.posNumber = settings.cashNumber;
	request.delay = '0';
	request.authorization = '0';
    
    [self setDoTransactionTimeout];
    
	if ([iSMPControl getISMPState] == YES) {
        
        if (extraData != nil) {
            //[self performExtendedDoTransactionWithTransactionRequest:request];
            
            [iSMPControl.control doTransaction:request withData:extraData andApplicationNumber:settings.paymentApplicationNumber];
            
        } else {
            [iSMPControl.control doTransaction:request];
        }
	}
	else {
		if([(id<NSObject>)self.delegate respondsToSelector:@selector(transactionFailed:)]) {
			[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(transactionFailed:) withObject:nil waitUntilDone:NO];
		}
	}
	[pool release];
}


-(void)performExtendedDoTransactionWithTransactionRequest:(ICTransactionRequest)request {
    NSLog(@"%s", __FUNCTION__);
    SettingsManager * settings = [SettingsManager sharedSettingsManager];
    
    //Build Der Tlv Tree
    unsigned char buffer[512];
    unsigned int object_table_capacity = 8;
    size_t objects[object_table_capacity];
    uint8_t requestType = PDA_RQ_PURCHASE_TXN;
    errorId_t r = OK;
    tlvContext_t context;
    
    tlvContextInitialize(&context,
                         buffer, sizeof(buffer),
                         objects, object_table_capacity);
    
    r += tlvContextObjectAdd(&context, EXT_DO_TRANSACTION_TAG_REQUEST_TYPE, &requestType, sizeof(uint8_t));
    r += tlvContextObjectAdd(&context, EXT_DO_TRANSACTION_TAG_REQUEST_REF, &_requestReference, sizeof(NSInteger));
    r += tlvContextConstructedObjectAdd(&context, EXT_DO_TRANSACTION_CTAG_REQUEST, 2);
    
    if (r != OK) {
        NSLog(@"%s Failed to build the tlv object", __FUNCTION__);
    } else {
        size_t tlvObjectSize = tlvContextObjectSizeGet(&context);
        void * tlvBuffer = tlvContextObjectGet(&context);
        
        NSData * tlvData = [NSData dataWithBytes:tlvBuffer length:tlvObjectSize];
        NSLog(@"%s Transaction Request Data: %@", __FUNCTION__, [tlvData hexDump]);
        
        [iSMPControl.control doTransaction:request withData:tlvData andApplicationNumber:settings.paymentApplicationNumber];
    }
}


-(NSDictionary *)analyseExtendedDoTransactionReplyWith:(NSData *)extendedData {
    NSLog(@"%s", __FUNCTION__);
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    NSString * error = nil;
    
    if (extendedData == nil) {
        NSLog(@"%s NO Extended Data Provided", __FUNCTION__);
    } else {
        
        errorId_t r = OK;
        unsigned long tag;
        size_t valueLength;
        const unsigned char *value;
        
        r += tlvObjectDecode([extendedData bytes], [extendedData length], &tag, &valueLength, &value);
        
        if ((r == OK) && (valueLength > 0)) {
            
            //Check the header of the response
            if ((tag == EXT_DO_TRANSACTION_CTAG_REPLY) || (tag == EXT_DO_TRANSACTION_CTAG_REQUEST)) {
                
                unsigned int subObjectOffset    = 0;
                size_t subLength   = 0;
                unsigned long subTag = 0;
                const unsigned char * subValue = NULL;
                
                NSInteger       returnedRequestReference    = -1;
                uint32_t        realTransactionID           = -1;
                NSData *        CVM                         = nil;
                
                while (subObjectOffset < valueLength) {
                    r += tlvObjectDecode(&value[subObjectOffset], valueLength - subObjectOffset, &subTag, &subLength, &subValue);
                    
                    if (r == OK) {
                        
                        switch (subTag) {
                            case EXT_DO_TRANSACTION_TAG_REQUEST_REF:
                                //Get the returned session transaction ID
                                memcpy(&returnedRequestReference, subValue, subLength);
                                
                                //Check if the returned request reference matches the one used for the current transaction
                                if (returnedRequestReference == self.requestReference) {
                                    NSLog(@"%s Returned Request ID [%d] is valid", __FUNCTION__, returnedRequestReference);
                                } else {
                                    error = @"The returned transaction ID does not match the one used for the transaction";
                                    NSLog(@"%s %@ [Current ID: %d, Returned ID: %d]", __FUNCTION__, error, self.requestReference, returnedRequestReference);
                                    [result setObject:error forKey:@"error"];
                                }
                                
                                break;
                                
                            case EXT_DO_TRANSACTION_TAG_TRANSACTION_REF:
                                //Get the real transaction ID generated by the payment application
                                memcpy(&realTransactionID, subValue, subLength);
                                
                                //Transform from network to hardware byte order
                                realTransactionID = ntohl(realTransactionID);
                                
                                [result setValue:[NSNumber numberWithUnsignedInteger:realTransactionID] forKey:@"transaction_reference"];
                                break;
                                
                            case EXT_DO_TRANSACTION_TAG_CVM:
                                //Get the CVM data
                                CVM = [NSData dataWithBytes:subValue length:subLength];
                                
                                //Based on the content of CVM, check if signature capture is required
                                uint8_t signatureCaptureFrame[3] = {0x1E, 0x00, 0x00};
                                if ([CVM isEqualToData:[NSData dataWithBytes:signatureCaptureFrame length:3]]) {
                                    NSLog(@"%s Signature required", __FUNCTION__);
                                    [result setValue:[NSNumber numberWithBool:YES] forKey:@"signature"];
                                }
                                break;
                                
                            default:
                                error = @"Unrecognized transaction response parameters";
                                NSLog(@"%s %@", __FUNCTION__, error);
                                [result setObject:error forKey:@"error"];
                                break;
                        }
                        
                    } else {
                        NSLog(@"%s Parsing Error", __FUNCTION__);
                        break;
                    }
                    
                    subObjectOffset += subLength + (subValue - &value[subObjectOffset]);
                }
                
            } else {
                error = @"Unrecognized response header";
                NSLog(@"%s %@", __FUNCTION__, error);
                [result setObject:error forKey:@"error"];
            }
            
        } else {
            error = @"NO Data Found";
            NSLog(@"%s %@", __FUNCTION__, error);
            [result setObject:error forKey:@"error"];
        }
    }
    
    return result;
}


-(void)cancellation:(NSNumber *)amount {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    SettingsManager * settings = [SettingsManager sharedSettingsManager];
	ICTransactionRequest request;
    
    //Set the transaction type - this is necessary to determine which callback should be performed when the transaction is done
    self.transactionType = TRANSACTION_TYPE_CANCELLATION;
    
    const char * c_amount = [[NSString stringWithFormat:@"%08d", (int)([amount doubleValue] * 100)] UTF8String];
	strncpy(request.amount, c_amount, (unsigned int)sizeof(request.amount));
	request.accountType = '0';
	memcpy(request.currency, [[self getCurrentCurrencyIsoCode] UTF8String], 3);
	request.specificField = '1';
	request.transactionType = '2';      //Cancellation
	strncpy(request.privateData, "0000000000", (unsigned int)sizeof(request.privateData));
	request.posNumber = settings.cashNumber;
	request.delay = '0';                //The delay parameter must be set to '0' in order to avoid blocking the execution of PCL until the transaction is done
	request.authorization = '0';
    
    [self setDoTransactionTimeout];
    
	if ([iSMPControl getISMPState] == YES) {
        
		if (settings.useExtendedTransaction == YES) {
            [self performExtendedDoTransactionWithTransactionRequest:request];
        } else {
            [iSMPControl.control doTransaction:request];
        }
	}
	else {
		if([(id<NSObject>)self.delegate respondsToSelector:@selector(cancellationFailed:)]) {
			[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(cancellationFailed:) withObject:nil waitUntilDone:NO];
		}
	}
	[pool release];
}

-(void)duplicata:(NSNumber *)amount {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    SettingsManager * settings = [SettingsManager sharedSettingsManager];
	ICTransactionRequest request;
    
    //Set the transaction type - this is necessary to determine which callback should be performed when the transaction is done
    self.transactionType = TRANSACTION_TYPE_DUPLICATA;
    
	const char * c_amount = [[NSString stringWithFormat:@"%08d", (int)([amount doubleValue] * 100)] UTF8String];
	strncpy(request.amount, c_amount, (unsigned int)sizeof(request.amount));
	request.accountType = '0';
	memcpy(request.currency, [[self getCurrentCurrencyIsoCode] UTF8String], 3);
	request.specificField = '1';
	request.transactionType = '3';      //Duplicata
	strncpy(request.privateData, "0000000000", (unsigned int)sizeof(request.privateData));
	request.posNumber = settings.cashNumber;
	request.delay = '0';                //The delay parameter must be set to '0' in order to avoid blocking the execution of PCL until the transaction is done
	request.authorization = '0';
    
    [self setDoTransactionTimeout];
    
	if ([iSMPControl getISMPState] == YES) {
        
		if (settings.useExtendedTransaction == YES) {
            [self performExtendedDoTransactionWithTransactionRequest:request];
        } else {
            [iSMPControl.control doTransaction:request];
        }
	}
	else {
		if([(id<NSObject>)self.delegate respondsToSelector:@selector(cancellationFailed:)]) {
			[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(cancellationFailed:) withObject:nil waitUntilDone:NO];
		}
	}
	[pool release];
}

-(void)totalization {
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    SettingsManager * settings = [SettingsManager sharedSettingsManager];
	ICTransactionRequest request;
    
    //Set the transaction type - this is necessary to determine which callback should be performed when the transaction is done
    self.transactionType = TRANSACTION_TYPE_TOTALIZATION;
    
    //Put zero amount
	const char * c_amount = [[NSString stringWithFormat:@"%08d", 0] UTF8String];
	strncpy(request.amount, c_amount, (unsigned int)sizeof(request.amount));
    
	request.accountType = '0';
	memcpy(request.currency, [[self getCurrentCurrencyIsoCode] UTF8String], 3);
	request.specificField = '1';
	request.transactionType = '4';      //Totalization
	strncpy(request.privateData, "0000000000", (unsigned int)sizeof(request.privateData));
	request.posNumber = settings.cashNumber;
	request.delay = '0';                //The delay parameter must be set to '0' in order to avoid blocking the execution of PCL until the transaction is done
	request.authorization = '0';
    
    [self setDoTransactionTimeout];
    
	if ([iSMPControl getISMPState] == YES) {
        
		if (settings.useExtendedTransaction == YES) {
            [self performExtendedDoTransactionWithTransactionRequest:request];
        } else {
            [iSMPControl.control doTransaction:request];
        }
	}
	else {
		if([(id<NSObject>)self.delegate respondsToSelector:@selector(cancellationFailed:)]) {
			[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(cancellationFailed:) withObject:nil waitUntilDone:NO];
		}
	}
	[pool release];
}

#pragma mark -


#pragma mark ICAdministrationDelegate

-(void)transactionDidEndWithTimeoutFlag:(BOOL)replyReceived result:(ICTransactionReply)transactionReply andData:(NSData *)extendedData {
    NSLog(@"%s", __FUNCTION__);
    
	if (replyReceived == NO) {
		if([(id<NSObject>)self.delegate respondsToSelector:@selector(transactionTimeout)]) {
			[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(transactionTimeout) withObject:nil waitUntilDone:NO];
		}
		return;
	} else {
        char _amount[sizeof(transactionReply.amount)+1];
        char currency[sizeof(transactionReply.currency)+1];
        char privateData[sizeof(transactionReply.privateData)+1];
        char pan[sizeof(transactionReply.PAN)+1];
        char cardValidity[sizeof(transactionReply.cardValidity)+1];
        char cmc7[sizeof(transactionReply.CMC7)+1];
        char iso2[sizeof(transactionReply.ISO2)+1];
        char fnci[sizeof(transactionReply.FNCI)+1];
        char guarantor[sizeof(transactionReply.guarantor)+1];
        strncpy(_amount, transactionReply.amount, sizeof(transactionReply.amount));
        strncpy(currency, transactionReply.currency, sizeof(transactionReply.currency));
        strncpy(privateData, transactionReply.privateData, sizeof(transactionReply.privateData));
        strncpy(pan, transactionReply.PAN, sizeof(transactionReply.PAN));
        strncpy(cardValidity, transactionReply.cardValidity, sizeof(transactionReply.cardValidity));
        strncpy(cmc7, transactionReply.CMC7, sizeof(transactionReply.CMC7));
        strncpy(iso2, transactionReply.ISO2, sizeof(transactionReply.ISO2));
        strncpy(fnci, transactionReply.FNCI, sizeof(transactionReply.FNCI));
        strncpy(guarantor, transactionReply.guarantor, sizeof(transactionReply.guarantor));
        _amount[sizeof(transactionReply.amount)] = '\0';
        currency[sizeof(transactionReply.currency)] = '\0';
        privateData[sizeof(transactionReply.privateData)] = '\0';
        pan[sizeof(transactionReply.PAN)] = '\0';
        cardValidity[sizeof(transactionReply.cardValidity)] = '\0';
        cmc7[sizeof(transactionReply.CMC7)] = '\0';
        iso2[sizeof(transactionReply.ISO2)] = '\0';
        fnci[sizeof(transactionReply.FNCI)] = '\0';
        guarantor[sizeof(transactionReply.guarantor)] = '\0';
        
        NSString * transactionParameters = 
        [NSString stringWithFormat:@"posNumber: %d\noperationStatus: %c\namount: %s\naccount type: %c\ncurrency: %s\nprivate data: %s\nPAN: %s\ncard validity: %s\nauthorization number: %s\nCMC7: %s\nISO2: %s\nFNCI: %s\nGuarantor: %s",
         transactionReply.posNumber, transactionReply.operationStatus, _amount, transactionReply.accountType, currency,
         privateData, pan, cardValidity, transactionReply.authorizationNumber, cmc7,
         iso2, fnci, guarantor];
        NSLog(@"%s Transaction Reply:\n%@", __FUNCTION__, transactionParameters);
        
        //Analyse Extended Transaction Data
        //NSDictionary * extendedResult = [self analyseExtendedDoTransactionReplyWith:extendedData];
        
        //Increment the request reference
        self.requestReference = (++self.requestReference) % EXT_DO_TRANSACTION_MAX_REQUEST_REF;
        
        //Provide result to delegate according to the transaction type
        switch (self.transactionType) {
            case TRANSACTION_TYPE_CREDIT:
            case TRANSACTION_TYPE_DEBIT:
                
                switch (transactionReply.operationStatus) {
                    case '0':
                        NSLog(@"%s Transaction Succeeded", __FUNCTION__);
                        if([(id<NSObject>)self.delegate respondsToSelector:@selector(transactionSuccess:)]) {
                            //[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(transactionSuccess:) withObject:extendedResult waitUntilDone:NO];
                            [(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(transactionSuccess:) withObject:extendedData waitUntilDone:NO];
                        }
                        
                        break;
                    case '7':   //Failure
                    default:
                        //Default to Failure
                        NSLog(@"%s Transaction Failed", __FUNCTION__);
                        if([(id<NSObject>)self.delegate respondsToSelector:@selector(transactionFailed:)]) {
                            //[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(transactionFailed:) withObject:extendedResult waitUntilDone:NO];
                            [(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(transactionFailed:) withObject:extendedData waitUntilDone:NO];
                        }
                        break;
                }
                
                break;
            
            case TRANSACTION_TYPE_CANCELLATION:
                
                switch (transactionReply.operationStatus) {
                    case '0':
                        NSLog(@"%s Cancellation Succeeded", __FUNCTION__);
                        if([(id<NSObject>)self.delegate respondsToSelector:@selector(cancellationSucceeded:)]) {
                            //[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(cancellationSucceeded:) withObject:extendedResult waitUntilDone:NO];
                            [(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(cancellationSucceeded:) withObject:extendedData waitUntilDone:NO];
                        }
                        
                        break;
                    case '7':   //Failure
                    default:
                        //Default to Failure
                        NSLog(@"%s Cancellation Failed", __FUNCTION__);
                        if([(id<NSObject>)self.delegate respondsToSelector:@selector(cancellationFailed:)]) {
                            //[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(cancellationFailed:) withObject:extendedResult waitUntilDone:NO];
                            [(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(cancellationFailed:) withObject:extendedData waitUntilDone:NO];
                        }
                        break;
                }
                
                break;
                
            case TRANSACTION_TYPE_DUPLICATA:
                
                switch (transactionReply.operationStatus) {
                    case '0':
                        NSLog(@"%s Duplicata Succeeded", __FUNCTION__);
                        if([(id<NSObject>)self.delegate respondsToSelector:@selector(duplicataSucceeded:)]) {
                            //[(NSObject<StandAlonePaymentDelegate>*) delegate performSelectorOnMainThread:@selector(duplicataSucceeded:) withObject:extendedResult waitUntilDone:NO];
                            [(NSObject<StandAlonePaymentDelegate>*) delegate performSelectorOnMainThread:@selector(duplicataSucceeded:) withObject:extendedData waitUntilDone:NO];
                        }
                        
                        break;
                    case '7':   //Failure
                    default:
                        //Default to Failure
                        NSLog(@"%s Duplicata Failed", __FUNCTION__);
                        if([(id<NSObject>)delegate respondsToSelector:@selector(duplicataFailed:)]) {
                            //[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(duplicataFailed:) withObject:extendedResult waitUntilDone:NO];
                            [(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(duplicataFailed:) withObject:extendedData waitUntilDone:NO];
                        }
                        break;
                }
                
                break;
                
            case TRANSACTION_TYPE_TOTALIZATION:
                
                switch (transactionReply.operationStatus) {
                    case '0':
                        NSLog(@"%s Totalization Succeeded", __FUNCTION__);
                        if([(id<NSObject>)self.delegate respondsToSelector:@selector(totalizationSucceeded:)]) {
                            //[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(totalizationSucceeded:) withObject:extendedResult waitUntilDone:NO];
                            [(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(totalizationSucceeded:) withObject:extendedData waitUntilDone:NO];
                        }
                        
                        break;
                    case '7':   //Failure
                    default:
                        //Default to Failure
                        NSLog(@"%s Totalization Failed", __FUNCTION__);
                        if([(id<NSObject>)self.delegate respondsToSelector:@selector(totalizationFailed:)]) {
                            //[(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(totalizationFailed:) withObject:extendedResult waitUntilDone:NO];
                            [(NSObject<StandAlonePaymentDelegate>*)self.delegate performSelectorOnMainThread:@selector(totalizationFailed:) withObject:extendedData waitUntilDone:NO];
                        }
                        break;
                }
                
                break;
                
            default:
                break;
        }
    }
}


-(void)shouldDoSignatureCapture:(ICSignatureData)signatureData {
    NSLog(@"%s", __FUNCTION__);
    
    if ([(NSObject *)delegate respondsToSelector:@selector(userShouldProvideSignatureWithSize:)]) {
        [delegate userShouldProvideSignatureWithSize:CGSizeMake(signatureData.screenWidth, signatureData.screenHeight)];
    }
}

-(void)signatureTimeoutExceeded {
    NSLog(@"%s", __FUNCTION__);
    
    UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Signature Capture Timeout" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
    [alert show];
}

-(void)provideSignature:(UIImage *)signature {
    NSLog(@"%s", __FUNCTION__);
    
    [self.iSMPControl.control submitSignatureWithImage:signature];
    
    //Save the signature for later use
    self.iSMPControl.customerSignature = signature;
}

#pragma mark -

-(void)logEntry:(NSString *)message withSeverity:(int)severity {
    NSLog(@"%@", message);
}


@end
