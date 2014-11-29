//
//  STBDataFormatter.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>

/* helper macro */
#define nilOrJSONObjectForKey(JSON_, KEY_) [[JSON_ objectForKey:KEY_] isKindOfClass:[NSNull null]] ? nil : [JSON_ objectForKey:KEY_];
// example usage: nickname = nilOrJSONObjectForKey(json, @"nickname");


/**
 * Utility class providing some commonly used formatters and functions used in scout24 apps.
 */
@interface STBDataFormatter : NSObject

/* Format: NSNumberFormatterDecimalStyle */
@property (strong, nonatomic) NSNumberFormatter *decimalFormatter;

/* Format: @"dd.MM.yyyy" */
@property (strong, nonatomic) NSDateFormatter *shortDateFormatter;

/* Format: @"dd. MMMM yyyy" */
@property (strong, nonatomic) NSDateFormatter *shortStyleDateFormatter;

/* Format: @"yyyyMMdd" */
@property (strong, nonatomic) NSDateFormatter *sortableDateFormatter;

/* Format: @"dd.MM.yyyy HH:mm:ss" */
@property (strong, nonatomic) NSDateFormatter *shortDateAndTimeFormatter;

/* Format: @"dd/MM/yy HH:mm" */
@property (strong, nonatomic) NSDateFormatter *veryShortDateAndTimeFormatter;

/* Format: @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'" */
@property (strong, nonatomic) NSDateFormatter *httpHeaderDateFormatter;

/* Format: 0 => "no", 1 => "yes" */
@property (strong, nonatomic) id booleanFormatter;

/**/
@property (strong, nonatomic) NSNumberFormatter *priceFormatter;

/**
 * Singleton
 */
+ (STBDataFormatter *)sharedProvider;

/**
 * Returns the current calendar week
 */
+ (NSInteger)calendarWeek;

/**
 * Returns nil if object is nil or object equals [NSNull null]
 */
+ (id)toNilIfNull:(id)object;

/**
 * Returns nil if dict is nil or dict equals [NSNull null] or dict is empty
 */
+ (id)toNilIfNullOrEmpty:(NSDictionary*)dict;

/**
 * Returns nil if [dict objectForKey:propertyName] is nil or [dict objectForKey:propertyName] equals [NSNull null]
 */
+ (id)toNilIfNull:(NSDictionary*)dict propertyName:(NSString*)propertyName;

/**
 * Returns true if email is valid.
 * Check is done with the following regex pattern:
 * @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?"
 */
+ (BOOL)isValidEmail:(NSString*)email;

/**
 * Returns a version of the string where all non-decimal characters have been removed
 */
+ (NSString*)toPhoneNumberString:(NSString*)string;

/**
 * Returns a version of the string where all non-decimal characters have been removed
 * Support International Phone Number with prefix "+"
 */
+ (NSString *)toInternationalPhoneNumberString:(NSString *)phoneNumber;

/**
 * Returns true if phone number is valid.
 */
+ (BOOL)isValidPhoneNumber:(NSString *)candidate;

/**
 *  Date with format dd.mm.yyyy
 *
 *  @param date source date
 *
 *  @return a string
 */
+ (NSString *)formattedDDMMYYYForDate:(NSDate *)date;

/**
 * Set the specified formatter as the default formatter for the property 'propertyName' of class 'className'
 */
- (void)registerFormatter:(id)formatter forPropertyName:(NSString*)propertyName inClassNamed:(NSString*)className;

/**
 * Get formatted string for a value, formatted by the specified formatter
 */
- (NSString*)formatter:(id)formatter format:(id)value;

/**
 * Get formatted string for an int value, formatted by the specified formatter
 */
- (NSString*)formatter:(id)formatter formatInt:(int)value;

/**
 * Get formatted string for an float value, formatted by the specified formatter
 */
- (NSString*)formatter:(id)formatter formatFloat:(float)value;

/**
 * Get formatted string for an double value, formatted by the specified formatter
 */
- (NSString*)formatter:(id)formatter formatDouble:(double)value;

/**
 * Get a registered formatter
 */
- (id)formatterForPropertyName:(NSString*)propertyName inClassNamed:(NSString*)className;

/**
 * Get a registered formatter
 */
- (id)formatterForPropertyName:(NSString*)propertyName inObject:(NSObject*)object;

/**
 * Returns the current date, with it's hh:mm:ss and milliseconds all set to 0.
 */
- (NSDate*)dateWithoutTime:(NSDate*)date;


@end
