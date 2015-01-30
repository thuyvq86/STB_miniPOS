//
//  PosMessage.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "PosMessage.h"

/**
 *  List of value types
 *  Ex. F1^2|F2^4364450099631797|F4^000000001001|F12^20141008235225|F14^1804|F37^428116455333|F38^798910|F39^00|F41^60012086|F42^000000060108354|F49^704|F60^1|F62^7|F65^VISA|F66^ALL FOR YOU               |F67^M|F72^20138884|F79^SALE"
 *
 F1: index cho loại giao dịch
 F2: số thẻ chiều dài biến động
 F4: tổng số tiền chiều dài 12 con số
 F12: thời gian giao dịch 06 con số
 F13: ngày tháng năm giao dịch (DD/MM/YYYY)
 F14: ngày hết hạn của thẻ 04 con số
 F37: số ref 12 con số
 F38: số approve code 06 con số
 F39: mã trả về 02 con số
 F41: Terminal ID 08 con số
 F42: Merchant ID 15 con số
 F49: loại tiền tệ chiều dài 3 con số
 F54: số tiền TIP 12 con số
 F60: Batch number 06 con số
 F62: mã số hóa đơn 06 con số
 F65: tên loại thẻ chiều dài biến động
 F66: card holder name chiều dài biến động
 F67: kiểu input thẻ (C: chip, S: quẹt thẻ, M: Manual key, F: Fallback) 1 ký tự
 F68: BASE AMOUNT 12 con số
 F69: application name chiều dài biến động
 F70: application ID chiều dài biến động
 F71: TC chiều dài biến động
 F72: serial number POS chiều dài biến động
 F82: diễn giải mã trả về
*/
typedef enum{
    FUNCTION_INDEX     = 1, // function index
    
    TRANSACTION_STATUS = 39, // detect a transaction success or not
    TRANSACTION_TYPE   = 79, // sell, void
    
    CARD_NUMBER        = 2, // card number
    CARD_TYPE          = 65, // card type
    CARD_NAME          = 66, // card name
    INPUT_CARD_TYPE    = 67, // input card type
    CARD_EXPIRED_DATE  = 14,  // Card Expired date
    
    MONEY_TOTAL = 4, // Total money
    MONEY_UNIT = 49, // Unit of money
    MONEY_TIP = 54, // Tip
    MONEY_BASE_AMOUNT = 68, // Tip
    
    TERMINAL_ID        = 41, // Terminal Id
    MERCHAINT_ID        = 42, // Merchant ID
    APPROVE_CODE = 38, // App code
    
    BATCH_NUMBER       = 60, // Batch number
    RECEIPT_NO         = 62, // Receipt No.
    
    TRANSACTION_DATE_TIME = 12 // Date time
    
} ValueType;

#define Field(type) ([NSString stringWithFormat:@"F%i", type])

@interface PosMessage()

@end

@implementation PosMessage

- (id)initWithMessage:(NSString *)aMessage{
    self = [super init];
    if (self) {
        self.message = aMessage;
        
        NSString *parsedMsg = [aMessage stringByRemovingNewLinesAndWhitespace];
        NSDictionary *dict = [NSDictionary dictionaryFromPosMessage:parsedMsg];
        
        self.functionIndex = [[STBDataFormatter toNilIfNull:dict propertyName:Field(FUNCTION_INDEX)] intValue];
        
        self.transactionStatus = [STBDataFormatter toNilIfNull:dict propertyName:Field(TRANSACTION_STATUS)];
        self.transactionType = [STBDataFormatter toNilIfNull:dict propertyName:Field(TRANSACTION_TYPE)];
        
        self.cardNumber = [STBDataFormatter toNilIfNull:dict propertyName:Field(CARD_NUMBER)];
        self.cardType = [STBDataFormatter toNilIfNull:dict propertyName:Field(CARD_TYPE)];
        self.inputCardType = [STBDataFormatter toNilIfNull:dict propertyName:Field(INPUT_CARD_TYPE)];
        self.cardName = [[STBDataFormatter toNilIfNull:dict propertyName:Field(CARD_NAME)] stringByRemovingNewLinesAndWhitespace];
        self.cardExpiredDate = [STBDataFormatter toNilIfNull:dict propertyName:Field(CARD_EXPIRED_DATE)];
        
        self.receiptNo = [STBDataFormatter toNilIfNull:dict propertyName:Field(RECEIPT_NO)];
        self.batchNumber = [STBDataFormatter toNilIfNull:dict propertyName:Field(BATCH_NUMBER)];
        
        self.moneyTotal = [[STBDataFormatter toNilIfNull:dict propertyName:Field(MONEY_TOTAL)] floatValue];
        self.moneyUnit = [STBDataFormatter toNilIfNull:dict propertyName:Field(MONEY_UNIT)];
        self.moneyBaseAmount = [[STBDataFormatter toNilIfNull:dict propertyName:Field(MONEY_BASE_AMOUNT)] floatValue];
        self.moneyTip = [[STBDataFormatter toNilIfNull:dict propertyName:Field(MONEY_TIP)] floatValue];
        
        NSString *dateString = [STBDataFormatter toNilIfNull:dict propertyName:Field(TRANSACTION_DATE_TIME)];
        self.dateTime = [self dateTime:dateString];
        
        self.terminalId = [STBDataFormatter toNilIfNull:dict propertyName:Field(TERMINAL_ID)];
        self.merchantId = [STBDataFormatter toNilIfNull:dict propertyName:Field(MERCHAINT_ID)];
        self.appCode = [STBDataFormatter toNilIfNull:dict propertyName:Field(APPROVE_CODE)];
    }
    
    return self;
}

- (BOOL)isSuccess{
    return [self.transactionStatus isEqualToString:@"00"] ? YES : NO;
}

- (BOOL)shouldRequireSignature{
    return (self.functionIndex == FunctionIndexSale) ? YES : NO;
}

/**
 *  Return the next function
 *
 * F1 = 1 (Sale)    ⇒ Capture Signature
 * F1 = 2 (Void)    ⇒ Reversal
 * F1 = 20(RePrint)	⇒ RePrint
 */
- (FunctionType)function{
    FunctionType func = FunctionTypeUnknown;
    
    switch (self.functionIndex) {
        case FunctionIndexSale:
            func = FunctionTypeCaptureSignature;
            break;
            
        case FunctionIndexVoid:
            func = FunctionTypeReversal;
            break;
            
        case FunctionIndexRePrint:
            func = FunctionTypeRePrint;
            break;
            
        default:
            break;
    }
    
    return func;
}

- (NSString *)formattedCardNumber{
    if (self.cardNumber) {
        NSString *newCardNumber = [self secureCardNumber:self.cardNumber];
        NSString *cardNumberWithSpaces = [self insertSpacesEveryFourDigitsIntoString:newCardNumber];
        
        return cardNumberWithSpaces;
    }
    
    return nil;
}

- (NSString *)formattedCardExpiredDate{
    if (self.cardExpiredDate && self.cardExpiredDate.length == 4) {
        NSInteger len = 2;
        
        NSRange yyRange = NSMakeRange(0, len);
        NSString *sYear = [self.cardExpiredDate substringWithRange:yyRange];
        
        NSRange mmRange = NSMakeRange(self.cardExpiredDate.length - len, len);
        NSString *sMonth = [self.cardExpiredDate substringWithRange:mmRange];
        
        return [NSString stringWithFormat:@"%@/%@", sMonth, sYear];
    }
    
    return nil;
}

- (NSString *)formattedDateTime{
    NSDateFormatter *dateFormatter = [STBDataFormatter sharedProvider].veryShortDateAndTimeFormatter;
    return [dateFormatter stringFromDate:self.dateTime];
}

- (NSString *)formattedMoneyTotal{
    NSNumberFormatter *formatter = [STBDataFormatter sharedProvider].priceFormatter;
    return [formatter stringFromNumber:[NSNumber numberWithFloat:self.moneyTotal]];
}

- (NSString *)formattedMoneyUnit{
    if ([self.moneyUnit isEqualToString:@"704"])
        return @"VND";
    
    return @"USD";
}

- (NSString *)formattedMoneyBaseAmount{
    NSNumberFormatter *formatter = [STBDataFormatter sharedProvider].priceFormatter;
    return [formatter stringFromNumber:[NSNumber numberWithFloat:self.moneyBaseAmount]];
}

- (NSString *)formattedMoneyTip{
    NSNumberFormatter *formatter = [STBDataFormatter sharedProvider].priceFormatter;
    return [formatter stringFromNumber:[NSNumber numberWithFloat:self.moneyTip]];
}

#pragma mark - Helpers

- (NSArray *)displayableProperties {
    if (!self.presentedProperties) {
        NSMutableArray *properties = [NSMutableArray array];
        
        NSString *_merchant = [NSString stringWithFormat:@"MID : %@", self.merchantId];
        NSString *_terminal = [NSString stringWithFormat:@"TID : %@", self.terminalId];

        [properties addObject:@[@(TextTypeNormal), _merchant, _terminal]];
//        [properties addObject:@[@(TextTypeNormal), @"TID", self.terminalId]];
        [properties addObject:@[@(TextTypeNormal), @"DATE / TIME", self.formattedDateTime]];
        [properties addObject:@[@(TextTypeNormal), @"", @""]]; //break line
        
        [properties addObject:@[@(TextTypeBold), [NSString stringWithFormat:@"%@ (%@)", self.cardType, self.inputCardType], self.formattedCardNumber]];
        [properties addObject:@[@(TextTypeNormal), self.cardName, @""]];
        [properties addObject:@[@(TextTypeNormal), @"EXPIRY DATE", self.formattedCardExpiredDate]];
        [properties addObject:@[@(TextTypeNormal), @"", @""]]; //break line
        if(self.receiptNo)
            [properties addObject:@[@(TextTypeNormal), @"REF No", self.receiptNo]];
        if(self.appCode)
            [properties addObject:@[@(TextTypeNormal), @"APP CODE", self.appCode]];
        
        [properties addObject:@[@(TextTypeNormal), @"", @"------------------"]]; //break line
        
        if (self.moneyBaseAmount > 0)
            [properties addObject:@[@(TextTypeNormal), @"BASE", self.formattedMoneyBaseAmount]];
        if (self.moneyTip > 0)
            [properties addObject:@[@(TextTypeNormal), @"TIP", self.formattedMoneyTip]];
        
        [properties addObject:@[@(TextTypeBold), [NSString stringWithFormat:@"TOTAL (%@)", self.formattedMoneyUnit], [NSString stringWithFormat:@"%@", self.formattedMoneyTotal]]];
        
        self.presentedProperties = properties;
    }
    
    return self.presentedProperties;
}

- (NSString *)base64EncodedSignature{
    NSString *base64EncodedSignature = nil;
    if (self.signature){
        NSData *imageData = UIImagePNGRepresentation(self.signature);
        imageData = [imageData base64EncodedDataWithOptions:0];
        
        //convert data to string
        if (imageData)
            base64EncodedSignature = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
    }
    
    return base64EncodedSignature;
}

#pragma mark - Private Helpers

/*
 Secure card number, just show the first 5 digits and last 4 digits
 */
- (NSString *)secureCardNumber:(NSString *)cardNumber{
    NSString *newCardNumber = cardNumber;
    
    NSInteger startLen = 5;
    NSInteger endLen = 4;
    
    if (newCardNumber.length > startLen + endLen) {
        NSInteger replaceLength = newCardNumber.length - startLen - endLen;
        NSRange replaceRange = NSMakeRange(startLen, replaceLength);
        
        NSMutableString *replaceString = [NSMutableString string];
        for (int i = 0; i < replaceLength; i++)
            [replaceString appendString:@"X"];
        
        newCardNumber = [newCardNumber stringByReplacingCharactersInRange:replaceRange withString:replaceString];
    }
    
    return newCardNumber;
}

/*
 Inserts spaces into the string to format it as a credit card number
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string
{
    NSInteger len = 4;
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < [string length]; i += len)
        [array addObject:[string substringWithRange:NSMakeRange(i, MIN(len, [string length] - i))]];
    NSString *stringWithAddedSpaces = [array componentsJoinedByString:@" "];
    
    return stringWithAddedSpaces;
}

/*
 Convert string to date
 */
- (NSDate *)dateTime:(NSString *)dateString{
    if (!dateString)
        return nil;
    
    NSTimeZone *defaultTimeZone = [NSTimeZone defaultTimeZone];
    NSDateFormatter *shortDateAndTimeFormatter = [[NSDateFormatter alloc] init];
    [shortDateAndTimeFormatter setDateFormat:@"yyyyMMddHHmmss"];
    [shortDateAndTimeFormatter setTimeZone:defaultTimeZone];
    
    return [shortDateAndTimeFormatter dateFromString:dateString];
}

@end
