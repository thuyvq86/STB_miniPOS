//
//  STBDataFormatter.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBDataFormatter.h"

@interface STBDataFormatter ()

/* The mapping of formatters for properties */
@property (strong, nonatomic) NSMutableDictionary *registeredProperties;

/* @"yes" */
@property (strong, nonatomic) NSString *localizedStringForYes;

/* @"no" */
@property (strong, nonatomic) NSString *localizedStringForNo;

/* @"months" */
@property (strong, nonatomic) NSString *localizedStringForMonths;

@end

@implementation STBDataFormatter


@synthesize decimalFormatter;
@synthesize shortDateFormatter;
@synthesize sortableDateFormatter;
@synthesize shortDateAndTimeFormatter;
@synthesize veryShortDateAndTimeFormatter;
@synthesize shortStyleDateFormatter;
@synthesize httpHeaderDateFormatter;
@synthesize booleanFormatter;
@synthesize registeredProperties;


@synthesize localizedStringForYes;
@synthesize localizedStringForNo;
@synthesize localizedStringForMonths = _localizedStringForMonths;




+ (STBDataFormatter*)sharedProvider {
    static STBDataFormatter *_sharedProvider = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedProvider = [[self alloc] init];
    });
    
    return _sharedProvider;
}


+ (NSInteger)calendarWeek {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSWeekCalendarUnit fromDate:[NSDate date]];
    return [components week];
}


+ (id)toNilIfNull:(id)object {
    if(!object || [[NSNull null] isEqual:object])
        return nil;
    else 
        return object;
}

+ (id)toNilIfNullOrEmpty:(NSDictionary*)dict {
    if(!dict || [[NSNull null] isEqual:dict] || [dict allKeys].count == 0)
        return nil;
    else 
        return dict;
}


+ (id)toNilIfNull:(NSDictionary*)dict propertyName:(NSString*)propertyName {
    
    id value = [dict valueForKey:propertyName];
    
    if([[NSNull null] isEqual:value])
        return nil;
    else if([value isKindOfClass:[NSNumber class]] && [value intValue] == 0)
        return nil;
    else if([value isKindOfClass:[NSString class]] && [value isEqual:@""])
        return nil;
    else
        return value;
}

+ (BOOL)isValidEmail:(NSString*)email {
    NSString *emailRegEx = @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?"; 
    
    NSPredicate *regExPredicate =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:email];
}

+ (NSString*)toPhoneNumberString:(NSString*)string {
    NSString *converted = [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    return converted;
}

+ (NSString *)toInternationalPhoneNumberString:(NSString *)phoneNumber {
    phoneNumber = [phoneNumber stringByRemovingNewLinesAndWhitespace];
    
    NSString *firstCharacter = nil;
    if (phoneNumber.length > 1)
        firstCharacter = [phoneNumber substringToIndex:1];
    
    NSString *converted = [self toPhoneNumberString:phoneNumber];
    if (firstCharacter && [firstCharacter isEqualToString:@"+"])
        converted = [NSString stringWithFormat:@"%@%@", firstCharacter, converted];
    
    return converted;
}

+ (BOOL)isValidPhoneNumber:(NSString *)candidate {
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)NSTextCheckingTypePhoneNumber error:&error];
    NSArray *matches = [detector matchesInString:candidate options:0 range:NSMakeRange(0, [candidate length])];
    if (matches != nil) {
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypePhoneNumber) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (BOOL)_isValidPhoneNumber:(NSString *)phoneNumber{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [self toPhoneNumberString:phoneNumber]]];
    if(![[UIApplication sharedApplication] canOpenURL:phoneUrl])
        return NO;
    
    return YES;
}

//Date with format dd.mm.yyyy
+ (NSString *)formattedDDMMYYYForDate:(NSDate *)date{
    unsigned theUnitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSCalendar* theCalendar = [NSCalendar currentCalendar];
	
	NSDateComponents *theComps = [theCalendar components:theUnitFlags fromDate:date];
    
    NSString *sDay = [NSString stringWithFormat:(theComps.day < 10) ? @"0%i" : @"%i", theComps.day];
    NSString *sMonth = [NSString stringWithFormat:(theComps.month < 10) ? @"0%i" : @"%i", theComps.month];
    NSString *sYear = [NSString stringWithFormat:@"%i", theComps.year];
    
    return [NSString stringWithFormat:@"%@.%@.%@", sDay, sMonth, sYear];
}

- (id)init {
	if(self = [super init]) {
		// initialize formatters
        self.booleanFormatter = self;

        self.localizedStringForMonths = @"months";
        self.localizedStringForYes    = @"yes";
        self.localizedStringForNo     = @"no";
        
        NSTimeZone *defaultTimeZone = [NSTimeZone defaultTimeZone];

        self.decimalFormatter = [[NSNumberFormatter alloc] init];
        [self.decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        self.sortableDateFormatter = [[NSDateFormatter alloc] init];
        [self.sortableDateFormatter setDateFormat:@"yyyyMMdd"];
        [self.sortableDateFormatter setTimeZone:defaultTimeZone];
         
        self.shortDateFormatter = [[NSDateFormatter alloc] init];
        [self.shortDateFormatter setDateFormat:@"dd.MM.yyyy"];
        [self.shortDateFormatter setTimeZone:defaultTimeZone];
        
		self.shortStyleDateFormatter = [[NSDateFormatter alloc] init];
		[self.shortStyleDateFormatter setDateFormat:@"dd. MMMM yyyy"];
        [self.shortStyleDateFormatter setTimeZone:defaultTimeZone];

        self.shortDateAndTimeFormatter = [[NSDateFormatter alloc] init];
        [self.shortDateAndTimeFormatter setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
        [self.shortDateAndTimeFormatter setTimeZone:defaultTimeZone];
        
        self.veryShortDateAndTimeFormatter = [[NSDateFormatter alloc] init];
        [self.veryShortDateAndTimeFormatter setDateFormat:@"dd/MM/yy HH:mm"];
        [self.veryShortDateAndTimeFormatter setTimeZone:defaultTimeZone];
        
        self.httpHeaderDateFormatter = [[NSDateFormatter alloc] init];
        self.httpHeaderDateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        self.httpHeaderDateFormatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
        //As the textual parts must be english (see RFC 1123 for all the wording), I add
        self.httpHeaderDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        
        self.priceFormatter = [[NSNumberFormatter alloc] init];
        [self.priceFormatter setNumberStyle:NSNumberFormatterNoStyle];
        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        [self.priceFormatter setGroupingSeparator:groupingSeparator];
        [self.priceFormatter setGroupingSize:3];
        [self.priceFormatter setAlwaysShowsDecimalSeparator:NO];
        [self.priceFormatter setUsesGroupingSeparator:YES];
	}
	return self;
}

- (void)registerFormatter:(id)formatter forPropertyName:(NSString*)propertyName inClassNamed:(NSString*)className {

    if(self.registeredProperties == nil) 
        self.registeredProperties = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *classFormatters = [self.registeredProperties objectForKey:className];
    if(!classFormatters) {
        classFormatters = [NSMutableDictionary dictionary];
        [self.registeredProperties setObject:classFormatters forKey:className];
    }
    [classFormatters setObject:formatter forKey:propertyName];
}

- (id)formatterForPropertyName:(NSString*)propertyName inClassNamed:(NSString*)className {
    id formatter = nil;
    NSMutableDictionary *classFormatters = [self.registeredProperties objectForKey:className];
    if(classFormatters) 
        formatter = [classFormatters objectForKey:propertyName];
    return formatter;
}

- (id)formatterForPropertyName:(NSString*)propertyName inObject:(NSObject*)object {
    return [self formatterForPropertyName:propertyName inClassNamed:[object.class description]]; 
}

- (NSString*)formatter:(id)formatter format:(id)value {

    if(formatter == self.booleanFormatter) {
        if(value) {
            if([value intValue] > 0)
                return self.localizedStringForYes;
            else
                return self.localizedStringForNo;
        }
        else
            return nil; 
    }
                
    NSString *result = nil;
    if([formatter isKindOfClass:[NSNumberFormatter class]])
        result = [formatter performSelector:@selector(stringFromNumber:) withObject:value];
    else if([formatter isKindOfClass:[NSDateFormatter class]])
        result =  [formatter performSelector:@selector(stringFromDate:) withObject:value];
    return result;
}

- (NSString*)formatter:(id)formatter formatInt:(int)value {
    return [self formatter:formatter format:[NSNumber numberWithInt:value]];
}

- (NSString*)formatter:(id)formatter formatFloat:(float)value {
    return [self formatter:formatter format:[NSNumber numberWithFloat:value]];    
}

- (NSString*)formatter:(id)formatter formatDouble:(double)value {
    return [self formatter:formatter format:[NSNumber numberWithDouble:value]];    
}


- (NSDate *)dateWithoutTime:(NSDate*)date {
	unsigned theUnitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSCalendar* theCalendar = [NSCalendar currentCalendar];
	
	NSDateComponents* theComps = [theCalendar components:theUnitFlags fromDate:date];
	[theComps setHour:0];
	[theComps setMinute:0];
	[theComps setSecond:0];
	
	NSDate* theNormalizedDate = [theCalendar dateFromComponents:theComps];	
	return theNormalizedDate;
}


@end
