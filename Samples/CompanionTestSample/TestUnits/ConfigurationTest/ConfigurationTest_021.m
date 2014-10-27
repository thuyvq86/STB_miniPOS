//
//  ConfigurationTest_032.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 19/09/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ConfigurationTest_021.h"

#define TEXT_CHARACTER_COUNT 511

@implementation ConfigurationTest_021

@synthesize buttonStartTesting;
@synthesize switchPrinter;
@synthesize buttonGetPrinterStatus;
@synthesize lastPrinterStatus;
@synthesize isTesting;

-(void)viewDidLoad {
	[super viewDidLoad];
	
    self.switchPrinter          = [self addSwitchWithTitle:@"BT Printer"];
	self.buttonStartTesting     = [self addButtonWithTitle:@"Start" andAction:@selector(startTesting)];
    self.buttonGetPrinterStatus = [self addButtonWithTitle:@"Get Printer Status" andAction:@selector(getPrinterStatus)];
    [self.switchPrinter addTarget:self action:@selector(printerValueChanged) forControlEvents:UIControlEventValueChanged];
    self.isTesting = NO;
}


+(NSString *)title {
	return @"Print Text & Reboot";
}


+(NSString *)subtitle {
	return @"Reboot iSMP When Printing";
}

+(NSString *)instructions {
	return @"Press the Start button to start printing and reseting the iSMP. Press Stop to stop the testing.";
}

+(NSString *)category {
	return @"iBP";
}


-(NSString *)printerResultToString:(iBPResult)result {
    NSString * retValue = @"";
    
    switch (result) {
        case iBPResult_OK:                              retValue = @"OK"; break;
        case iBPResult_KO:                              retValue = @"KO"; break;
        case iBPResult_TIMEOUT:                         retValue = @"TIMEOUT"; break;
        case iBPResult_ISMP_NOT_CONNECTED:              retValue = @"ISMP NOT DETECTED"; break;
        case iBPResult_PRINTER_NOT_CONNECTED:           retValue = @"PRINTER NOT CONNECTED"; break;
        case iBPResult_INVALID_PARAM:                   retValue = @"INVALID_PARAM"; break;
        case iBPResult_TEXT_TOO_LONG:                   retValue = @"TEXT TOO LONG"; break;
        case iBPResult_BITMAP_CONVERSION_ERROR:         retValue = @"BITMAP CONVERSION ERROR"; break;
        case iBPResult_WRONG_LOGO_NAME_LENGTH:          retValue = @"WRONG LOGO NAME LENGTH"; break;
        case iBPResult_PRINTING_ERROR:                  retValue = @"PRINTING ERROR"; break;
        case iBPResult_PAPER_OUT:                       retValue = @"PAPER OUT"; break;
        case iBPResult_PRINTER_LOW_BATT:                retValue = @"PRINTER IS IN LOW BATT"; break;
            
        default:                                        retValue = @"Unknown Result Code"; break;
    }
    return retValue;
}


-(void)enableUserInteraction:(NSNumber *)booleanNumber {
    [self.view setUserInteractionEnabled:[booleanNumber boolValue]]; 
}


-(void)backgroundOpen {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    [self beginTimeMeasure];
    iBPResult retValue = [self.configurationChannel iBPOpenPrinter];
    float totalTime = [self endTimeMeasure];
    
    NSString * resultString = [NSString stringWithFormat:@"Printer Open: %@", [self printerResultToString:retValue]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) 
                           withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
    
    if (retValue != iBPResult_OK) {
        self.switchPrinter.on = NO;
    }
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)backgroundClose {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    [self beginTimeMeasure];
    iBPResult retValue = [self.configurationChannel iBPClosePrinter];
    float totalTime = [self endTimeMeasure];
    
    NSString * resultString = [NSString stringWithFormat:@"Printer Close: %@", [self printerResultToString:retValue]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) 
                           withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)printerValueChanged
{
    if (self.switchPrinter.on) {
        [self.view setUserInteractionEnabled:NO];
        [self performSelectorInBackground:@selector(backgroundOpen) withObject:nil];
    } else {
        [self.view setUserInteractionEnabled:NO];
        [self performSelectorInBackground:@selector(backgroundClose) withObject:nil];
    }
}


-(void)doTesting {
    //Do the same operation again
    if (self.isTesting) {
        //[self.configurationChannel performSelector:@selector(reset:) withObject:nil afterDelay:(1000 *random())];
        [self performSelectorInBackground:@selector(backgroundPrintText) withObject:nil];
    }
}


-(void)backgroundPrintText {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSUInteger stringLength = TEXT_CHARACTER_COUNT;
    char _string[stringLength];
    memset(_string, '*', stringLength);
    NSString * stringObject = [[NSString alloc] initWithBytes:_string length:stringLength encoding:NSUTF8StringEncoding];
    
    if (self.configurationChannel.isAvailable == YES) {
        [self.configurationChannel iBPOpenPrinter];
        
        [self beginTimeMeasure];
        iBPResult retValue = [self.configurationChannel iBPPrintText:stringObject];
        float totalTime = [self endTimeMeasure];
        
        NSString * resultString = [NSString stringWithFormat:@"Print Text: %@", [self printerResultToString:retValue]];
        
        [self performSelectorOnMainThread:@selector(logMessage:) 
                               withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
        
        [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    }
    
    [self performSelectorOnMainThread:@selector(doTesting) withObject:nil waitUntilDone:NO];
    
    [stringObject release];
    
    [pool release];
}

-(void)startTesting {
    if ([self.buttonStartTesting.titleLabel.text isEqualToString:@"Start"]) {
        [self.view setUserInteractionEnabled:NO];
        self.isTesting = YES;
        [self.buttonStartTesting setTitle:@"Stop" forState:UIControlStateNormal];
        [self performSelectorOnMainThread:@selector(doTesting) withObject:nil waitUntilDone:NO];
    } else {
        [self.view setUserInteractionEnabled:YES];
        self.isTesting = NO;
        [self.buttonStartTesting setTitle:@"Start" forState:UIControlStateNormal];
    }
}


#pragma mark Get Printer Status

-(void)backgroundGetPrinterStatus {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    [self beginTimeMeasure];
    iBPResult retValue = [self.configurationChannel iBPGetPrinterStatus];
    float totalTime = [self endTimeMeasure];
    
    self.lastPrinterStatus = retValue;
    if (self.lastPrinterStatus == iBPResult_OK) {
        self.switchPrinter.on = YES;
    }
    
    NSString * resultString = [NSString stringWithFormat:@"Get Printer Status: %@", [self printerResultToString:retValue]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) 
                           withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)getPrinterStatus {
    [self.view setUserInteractionEnabled:NO];
    [self performSelectorInBackground:@selector(backgroundGetPrinterStatus) withObject:nil];
}

#pragma mark -


@end
