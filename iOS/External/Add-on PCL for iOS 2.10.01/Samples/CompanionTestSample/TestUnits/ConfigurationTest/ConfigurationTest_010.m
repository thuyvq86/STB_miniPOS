//
//  ConfigurationTest_027.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 14/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ConfigurationTest_010.h"

@implementation ConfigurationTest_010

@synthesize buttonPrintBitmap;
@synthesize buttonSelectBitmap;
@synthesize switchPrinter;
@synthesize textSelectedBitmap;
@synthesize selectedBitmap;
@synthesize buttonGetPrinterStatus;
@synthesize lastPrinterStatus;
@synthesize preferredWidth;
@synthesize preferredHeight;
@synthesize popover;

-(void)viewDidLoad {
	[super viewDidLoad];
	
    self.switchPrinter      = [self addSwitchWithTitle:@"BT Printer"];
	self.buttonSelectBitmap = [self addButtonWithTitle:@"Select Bitmap" andAction:@selector(selectBitmap)];
    self.textSelectedBitmap = [self addTextFieldWithTitle:@"Bitmap Dimensions"];
    [self.textSelectedBitmap setEnabled:NO];
    self.buttonPrintBitmap  = [self addButtonWithTitle:@"Print Bitmap" andAction:@selector(printBitmap)];
    self.buttonGetPrinterStatus = [self addButtonWithTitle:@"Get Printer Status" andAction:@selector(getPrinterStatus)];
    self.preferredWidth     = [self addTextFieldWithTitle:@"Preferred Width"];
    self.preferredHeight    = [self addTextFieldWithTitle:@"Preferred Height"];
    
    //Set default values for preferred width and height
    self.preferredWidth.text    = @"384";
    self.preferredHeight.text   = @"1024";
    
    [self.switchPrinter addTarget:self action:@selector(printerValueChanged) forControlEvents:UIControlEventValueChanged];
}


+(NSString *)title {
	return @"Print Bitmap";
}


+(NSString *)subtitle {
	return @"Print Bitmap from photo library";
}

+(NSString *)instructions {
	return @"Open the printer. Select a picture from the photo library and print it.";
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


#pragma mark Open/Close Printer

-(void)backgroundOpen {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    [self beginTimeMeasure];
    BOOL retValue = [self.configurationChannel iBPOpenPrinter];
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

#pragma mark -


#pragma mark Print Bitmap

-(void)selectBitmap {
    UIImagePickerController * imagePicker = [[[UIImagePickerController alloc] init] autorelease];
    imagePicker.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popover = [[[UIPopoverController alloc] initWithContentViewController: imagePicker] autorelease];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:CGRectMake(self.buttonSelectBitmap.frame.origin.x, self.buttonSelectBitmap.frame.origin.y + self.buttonSelectBitmap.frame.size.height, 200, 200) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
    self.selectedBitmap = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.textSelectedBitmap.text = [NSString stringWithFormat:@"Width: %f, Height: %f", self.selectedBitmap.size.width, self.selectedBitmap.size.height];
    NSLog(@"%s [Width: %f, Height: %f]", __FUNCTION__, self.selectedBitmap.size.width, self.selectedBitmap.size.height);
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    self.selectedBitmap = nil;
    self.textSelectedBitmap.text = @"";
}




-(void)enableUserInteraction:(NSNumber *)booleanNumber {
    [self.view setUserInteractionEnabled:[booleanNumber boolValue]]; 
}

-(void)backgroundPrintBitmap {
    NSLog(@"%s", __FUNCTION__);
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSLog(@"%s Bitmap Info: [Name: %@, Width: %d, Height: %d]", __FUNCTION__, self.textSelectedBitmap.text, (int)self.selectedBitmap.size.width, (int)self.selectedBitmap.size.height);
    
    [self beginTimeMeasure];  
    iBPResult retValue = [self.configurationChannel iBPPrintBitmap:self.selectedBitmap size:CGSizeMake([self.preferredWidth.text floatValue], [self.preferredHeight.text floatValue]) alignment:(UITextAlignment)NSTextAlignmentLeft];
    float totalTime = [self endTimeMeasure];
    
    NSString * resultString = [NSString stringWithFormat:@"Print Bitmap: %@", [self printerResultToString:retValue]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) 
                           withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)printBitmap {
    NSLog(@"%s", __FUNCTION__);
    [self.view setUserInteractionEnabled:NO];
    [self performSelectorInBackground:@selector(backgroundPrintBitmap) withObject:nil];
}

#pragma mark -


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
