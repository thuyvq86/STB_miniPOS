//
//  NSString+Extended.m
//  Anibis
//
//  Created by Nam Nguyen on 11/13/13.
//  Copyright (c) 2013 Xmedia AG. All rights reserved.
//

#import "NSString+Extended.h"
#import "GTMNSString+HTML.h"

@implementation NSString (Extended)

#pragma mark - Utilities

- (NSString *)stringByRemovingNewLinesAndWhitespace{
    if (!self || [[NSNull null] isEqual:self] || self.length == 0)
        return nil;
    
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedString isEqualToString:@""] || [[NSNull null] isEqual:trimmedString]) {
        trimmedString = nil;
    }
    
    return trimmedString;
}

#pragma mark - Validation

- (BOOL)isInteger{
    if (!self || self.length == 0)
        return NO;
    
    NSScanner *scan = [NSScanner scannerWithString:self];
    int holder;
    return [scan scanInt:&holder] && [scan isAtEnd];
}

- (BOOL)isDouble{
    if (!self || self.length == 0)
        return NO;
    
    NSScanner *scan = [NSScanner scannerWithString:self];
    double holder;
    return [scan scanDouble:&holder] && [scan isAtEnd];
}

#pragma mark - Related URL

// Encode a string to embed in an URL.
//Ref: http://stackoverflow.com/questions/8088473/url-encode-an-nsstring
- (NSString *)urlencode {
    if (!self || self.length == 0)
        return nil;
    
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSString *)urldecode
{
    if (!self || self.length == 0)
        return nil;
    
    NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //can't decode
    if (!result || result.length == 0)
        result = self;
    
    return result;
}

//Add query parameter to URL string
- (NSString *)URLStringByAppendingParameter:(NSString *)parameter {
    if (!parameter || [parameter length] == 0)
        return self;
    
    return [NSString stringWithFormat:@"%@%@%@", self,
            [self rangeOfString:@"?"].length > 0 ? @"&" : @"?", parameter];
}

- (NSString *)URLStringByAppendingQuery:(NSString *)query{
    if (!query || [query length] == 0)
        return self;
    
    if ([query length] > 1 && [[query substringToIndex:1] isEqualToString:@"?"])
        query = [query stringByReplacingOccurrencesOfString:@"?" withString:@""];
    
    return [NSString stringWithFormat:@"%@%@%@", self,
            [self rangeOfString:@"?"].length > 0 ? @"&" : @"?", query];
}

#pragma mark - HTML string

//convert NSString HTML markup to Plain text
- (NSString *)stringByConvertingHTMLToPlainText {
    NSString *retString = nil;
    
    // Find first & and short-cut if we can
	NSUInteger ampIndex = [self rangeOfString:@"<" options:NSLiteralSearch].location;
    NSUInteger ampersandIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
    
	if (ampIndex == NSNotFound && ampersandIndex == NSNotFound) {
        retString = [self stringByRemovingNewLinesAndWhitespace];
    }
    else{
        //replace tags with space or empty
        retString = [self stringByStrippingTags];
        //convert HTML markup to Symbols
        retString = [retString stringByDecodingHTMLEntities];
    }

	return retString;
}

- (NSString *)stringByDecodingHTMLEntities {
    // Can return self so create new string if we're a mutable string
    return [NSString stringWithString:[self gtm_stringByUnescapingFromHTML]];
}

- (NSString *)stringByStrippingTags {
	// Find first & and short-cut if we can
	NSUInteger ampIndex = [self rangeOfString:@"<" options:NSLiteralSearch].location;
	if (ampIndex == NSNotFound)
		return [NSString stringWithString:self]; // return copy of string as no tags found
	
	// Scan and find all tags
	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableSet *tags = [[NSMutableSet alloc] init];
	NSString *tag;
	do {
		
		// Scan up to <
		tag = nil;
		[scanner scanUpToString:@"<" intoString:NULL];
		[scanner scanUpToString:@">" intoString:&tag];
		
		// Add to set
		if (tag) {
			NSString *t = [[NSString alloc] initWithFormat:@"%@>", tag];
			[tags addObject:t];
		}
		
	} while (![scanner isAtEnd]);
	
	// Strings
	NSMutableString *result = [[NSMutableString alloc] initWithString:self];
	NSString *finalString;
	
	// Replace tags
	NSString *replacement;
	for (NSString *tagName in tags) {
        BOOL dontReplaceTagWithSpace = ([tagName rangeOfString:@"a"].location != NSNotFound ||
                                        [tagName rangeOfString:@"b"].location != NSNotFound ||
                                        [tagName rangeOfString:@"i"].location != NSNotFound ||
                                        [tagName rangeOfString:@"q"].location != NSNotFound ||
                                        [tagName rangeOfString:@"span"].location != NSNotFound ||
                                        [tagName rangeOfString:@"em"].location != NSNotFound ||
                                        [tagName rangeOfString:@"strong"].location != NSNotFound ||
                                        [tagName rangeOfString:@"cite"].location != NSNotFound ||
                                        [tagName rangeOfString:@"abbr"].location != NSNotFound ||
                                        [tagName rangeOfString:@"acronym"].location != NSNotFound ||
                                        [tagName rangeOfString:@"label"].location != NSNotFound
                                        );
        
        // Replace tag with space unless it's an inline element
        replacement = dontReplaceTagWithSpace ? @"" : @" ";
        
		// Replace
		[result replaceOccurrencesOfString:tagName
								withString:replacement
								   options:NSLiteralSearch
									 range:NSMakeRange(0, result.length)];
	}
	
	// Remove multi-spaces and line breaks
	finalString = [result stringByRemovingNewLinesAndWhitespace];
	
	// Return
    return finalString;
}

@end
