//
//  PosMessage.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  enum function indexes
 *
 * F1 = 1 (Sale)    ⇒ Capture Signature
 * F1 = 2 (Void)    ⇒ Reversal
 * F1 = 20(RePrint)	⇒ RePrint
 */
typedef enum{
    FunctionIndexSale = 1,
    FunctionIndexVoid = 2,
    FunctionIndexRePrint = 20
} FunctionIndex;

/**
 * enum functions
 */
typedef enum{
    FunctionTypeUnknown = -1,
    FunctionTypeCaptureSignature = 0,
    FunctionTypeReversal,
    FunctionTypeRePrint
} FunctionType;

/**
 * Text Type
 */
typedef enum{
    TextTypeNormal = 0,
    TextTypeBold   = 1,
    TextTypeItalic = 2
} TextType;

@interface PosMessage : NSObject

@property (nonatomic) FunctionIndex functionIndex;

@property (nonatomic, strong) NSString *transactionStatus;
@property (nonatomic, strong) NSString *transactionType;

@property (nonatomic, strong) NSString *cardType;
@property (nonatomic, strong) NSString *cardName;
@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong) NSString *expiredDate; // format: MM/YY

@property (nonatomic) CGFloat total;

@property (nonatomic, strong) NSDate *dateTime;

@property (nonatomic, strong) NSString *terminalId;
@property (nonatomic, strong) NSString *receiptNo;
@property (nonatomic, strong) NSString *appCode;

@property (nonatomic, strong) UIImage *signature;
@property (nonatomic, strong) id presentedProperties;

- (id)initWithMessage:(NSString *)aMessage;

- (FunctionType)function;

- (BOOL)isSuccess;
- (BOOL)shouldRequireSignature;

- (NSString *)formattedCardNumber;
- (NSString *)formattedDateTime;

- (NSArray *)displayableProperties;

@end
