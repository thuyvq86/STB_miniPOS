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
 */
typedef enum{
    FUNCTION_INDEX     = 1, // function index
    
    TRANSACTION_STATUS = 39, // detect a transaction success or not
    TRANSACTION_TYPE   = 79, // sell, void
    
    CARD_NUMBER        = 2, // card number
    CARD_TYPE          = 65, // card type
    CARD_NAME          = 66, // card name
    
    TOTAL              = 4, // Total money
    
    TERMINAL_ID        = 41, // Terminal Id
    APP_CODE           = 38, // App code
    RECEIPT_NO         = 62, // Receipt No.
    
    DATE_TIME          = 12, // Date time
    EXPIRED_DATE       = 14  // Expired date
} ValueType;

#define Field(type) ([NSString stringWithFormat:@"F%i", type])

@interface PosMessage()

@end

@implementation PosMessage

- (id)initWithMessage:(NSString *)aMessage{
    self = [super init];
    if (self) {
        //Ex. F1^2|F2^4364450099631797|F4^000000001001|F12^20141008235225|F14^1804|F37^428116455333|F38^798910|F39^00|F41^60012086|F42^000000060108354|F49^704|F60^1|F62^7|F65^VISA|F66^ALL FOR YOU               |F67^M|F72^20138884|F79^SALE"
        
        NSString *parsedMsg = [aMessage stringByRemovingNewLinesAndWhitespace];
        NSDictionary *dict = [NSDictionary dictionaryFromPosMessage:parsedMsg];
        
        self.functionIndex = [[STBDataFormatter toNilIfNull:dict propertyName:Field(FUNCTION_INDEX)] intValue];
        
        self.transactionStatus = [STBDataFormatter toNilIfNull:dict propertyName:Field(TRANSACTION_STATUS)];
        self.transactionType = [STBDataFormatter toNilIfNull:dict propertyName:Field(TRANSACTION_TYPE)];
        
        self.cardNumber = [STBDataFormatter toNilIfNull:dict propertyName:Field(CARD_NUMBER)];
        self.cardType = [STBDataFormatter toNilIfNull:dict propertyName:Field(CARD_TYPE)];
        self.cardName = [[STBDataFormatter toNilIfNull:dict propertyName:Field(CARD_NAME)] stringByRemovingNewLinesAndWhitespace];
        
        self.receiptNo = [STBDataFormatter toNilIfNull:dict propertyName:Field(RECEIPT_NO)];
        self.total = [[STBDataFormatter toNilIfNull:dict propertyName:Field(TOTAL)] floatValue];
        
        NSString *dateString = [STBDataFormatter toNilIfNull:dict propertyName:Field(DATE_TIME)];
        self.dateTime = [self dateTime:dateString];
        
        self.expiredDate = [STBDataFormatter toNilIfNull:dict propertyName:Field(EXPIRED_DATE)];
        
        self.terminalId = [STBDataFormatter toNilIfNull:dict propertyName:Field(TERMINAL_ID)];
        self.appCode = [STBDataFormatter toNilIfNull:dict propertyName:Field(APP_CODE)];
    }
    
    return self;
}

- (BOOL)isSuccess{
    return [self.transactionStatus isEqualToString:@"00"] ? YES : NO;
}

- (BOOL)shouldRequireSignature{
//    return (self.functionIndex == FunctionIndexSale) ? YES : NO;
    return [self.transactionType isEqualToString:@"SALE"] ? YES : NO;
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
        NSInteger len = 4;
        NSRange needleRange = NSMakeRange(self.cardNumber.length - len, len);
        NSString *needle = [self.cardNumber substringWithRange:needleRange];
        
        return [NSString stringWithFormat:@"**** **** **** %@", needle];
    }
    
    return nil;
}

- (NSString *)formattedDateTime{
    NSDateFormatter *dateFormatter = [STBDataFormatter sharedProvider].veryShortDateAndTimeFormatter;
    return [dateFormatter stringFromDate:self.dateTime];
}

- (NSString *)formattedExpiredDate{
    if (self.expiredDate && self.expiredDate.length == 4) {
        NSInteger len = 2;
        
        NSRange yyRange = NSMakeRange(0, len);
        NSString *sYear = [self.expiredDate substringWithRange:yyRange];
        
        NSRange mmRange = NSMakeRange(self.expiredDate.length - len, len);
        NSString *sMonth = [self.expiredDate substringWithRange:mmRange];
        
        return [NSString stringWithFormat:@"%@/%@", sMonth, sYear];
    }
    
    return nil;
}

#pragma mark - Private Helpers

- (NSDate *)dateTime:(NSString *)dateString{
    if (!dateString)
        return nil;
    
    NSTimeZone *defaultTimeZone = [NSTimeZone defaultTimeZone];
    NSDateFormatter *shortDateAndTimeFormatter = [[NSDateFormatter alloc] init];
    [shortDateAndTimeFormatter setDateFormat:@"yyyyMMddHHmmss"];
    [shortDateAndTimeFormatter setTimeZone:defaultTimeZone];
    
    return [shortDateAndTimeFormatter dateFromString:dateString];
}

/*
- (BOOL)isSuccess{
    NSString *checkedValue = [self valueForField:39];
    if ([checkedValue isEqualToString:@"00"])
        return YES;
    
    return NO;
}

- (BOOL)needSignature{
    NSString *checkedValue = [self valueForField:1];
    if ([checkedValue isEqualToString:@"1"])
        return YES;
    
    return NO;
}

- (NSString *)cardType{
    return [self valueForField:CARD_TYPE];
}

- (NSString *)cardName{
    return [self valueForField:CARD_NAME];
}

- (NSString *)cardNumber{
    NSString *number = [self valueForField:CARD_NUMBER];
    
    NSInteger len = 4;
    NSRange needleRange = NSMakeRange(number.length - len, len);
    NSString *needle = [number substringWithRange:needleRange];
    NSLog(@"needle: %@", needle);
    
    return [NSString stringWithFormat:@"**** **** **** %@", needle];
}

- (NSInteger)total{
    return [[self valueForField:TOTAL] intValue];
}

- (NSDate *)dateTime{
    NSString *dateString = [self valueForField:TIME];
    if (!dateString)
        return nil;
    
    NSTimeZone *defaultTimeZone = [NSTimeZone defaultTimeZone];
    NSDateFormatter *shortDateAndTimeFormatter = [[NSDateFormatter alloc] init];
    [shortDateAndTimeFormatter setDateFormat:@"yyyyMMddHHmmss"];
    [shortDateAndTimeFormatter setTimeZone:defaultTimeZone];
    
    return [shortDateAndTimeFormatter dateFromString:dateString];
}

- (NSString *)formattedDateTime{
    NSDateFormatter *dateFormatter = [STBDataFormatter sharedProvider].veryShortDateAndTimeFormatter;
    return [dateFormatter stringFromDate:[self dateTime]];
}

- (NSString *)transactionType{
    return [self valueForField:TRANSACTION_TYPE];
}

- (NSString *)receiptNo{
    return [self valueForField:RECEIPT_NO];
}

- (NSString *)expiredDate{
    return @"YY/MM";
}

- (NSString *)appCode{
    return [self valueForField:APP_CODE];
}

- (NSString *)valueForField:(ValueType)field {
    NSString *searchedString = self.message;
    NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
    
    //NSString *pattern = @"(?:www\\.)?((?!-)[a-zA-Z0-9-]{2,63}(?<!-))\\.?((?:[a-zA-Z0-9]{2,})?(?:\\.[a-zA-Z0-9]{2,})?)";
    NSString *pattern = [NSString stringWithFormat:@"(\\|)?F%i\\^([a-z0-9A-Z ]+", field];
    NSError  *error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
    for (NSTextCheckingResult* match in matches) {
        NSString* matchText = [searchedString substringWithRange:[match range]];
        NSLog(@"match: %@", matchText);
        NSRange group1 = [match rangeAtIndex:1];
        NSRange group2 = [match rangeAtIndex:2];
        NSLog(@"group1: %@", [searchedString substringWithRange:group1]);
        NSLog(@"group2: %@", [searchedString substringWithRange:group2]);
        
        return [searchedString substringWithRange:group2];
    }
    
    return nil;
}
*/

@end
