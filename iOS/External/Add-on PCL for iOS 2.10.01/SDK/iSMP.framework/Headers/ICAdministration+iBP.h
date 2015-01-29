//
//  ICAdministration+iBP.h
//  PCL
//
//  Created by Hichem Boussetta on 02/01/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ICAdministration.h"

enum eiBPResult {
    iBPResult_OK,                               /**< Request Success */
    iBPResult_KO,                               /**< Request Failure due to a wrong parameters passed to the Companion */
    iBPResult_TIMEOUT,                          /**< Request timeout meaning that no response came from the terminal */
    iBPResult_ISMP_NOT_CONNECTED,               /**< Failure because the iDevice and the Companion are not synchronized */
    iBPResult_PRINTER_NOT_CONNECTED,                 /**< Request failure due to the printer not being open. @ref iBPOpenPrinter should be called to recover from this error */
    iBPResult_INVALID_PARAM,                    /**< Request failure because the parameters passed to the API are irrelevant (null parameter) */
    iBPResult_TEXT_TOO_LONG,                    /**< Request failure because the text provided is longer than 512 characters */
    iBPResult_BITMAP_CONVERSION_ERROR,          /**< Request failure if the provided bitmap can not be converted to monochrome configuration */
    iBPResult_WRONG_LOGO_NAME_LENGTH,           /**< The logo name passed as argument is inappropriate (number of characters should be in the range [4, 8]) */
    iBPResult_PRINTING_ERROR,                   /**< Printer Error */
    iBPResult_PAPER_OUT,                        /**< No more paper in the printer */
    iBPResult_PRINTER_LOW_BATT                  /**< Printer is in low battery condition */
};

typedef enum eiBPResult iBPResult;

@interface ICAdministration (iBP)

-(iBPResult)iBPOpenPrinter;

-(iBPResult)iBPClosePrinter;

/**
    @anchor     iBPPrintText
    @brief      Request to print the text provided as parameter
    <p>
        The length of the string to be printed should not exceed 512 characters otherwise the call will fail.<br />
        This call is blocking and has a timeout of 15 seconds.
    </p>
    @param      text NSString object of the text to be printed. The  length of this string must be 512 characters at most.
    @result     One of the enumerations of @ref eiBPResult. It is iBPResult_OK when the call succeeds.
*/
-(iBPResult)iBPPrintText:(NSString *)text;

-(iBPResult)iBPPrintBitmap:(UIImage *)image;

-(iBPResult)iBPPrintBitmap:(UIImage *)image lastBitmap:(BOOL)isLastBitmap;

-(iBPResult)iBPPrintBitmap:(UIImage *)image size:(CGSize)bitmapSize alignment:(UITextAlignment)alignment;

-(iBPResult)iBPPrintBitmap:(UIImage *)image size:(CGSize)bitmapSize alignment:(UITextAlignment)alignment lastBitmap:(BOOL)isLastBitmap;

-(iBPResult)iBPStoreLogoWithName:(NSString *)name andImage:(UIImage *)logo;

-(iBPResult)iBPPrintLogoWithName:(NSString *)name;

-(iBPResult)iBPGetPrinterStatus;

@property (nonatomic, readonly, getter = iBPMaxBitmapWidth) NSUInteger iBPMaxBitmapWidth;

@property (nonatomic, readonly, getter = iBPMaxBitmapHeight) NSUInteger iBPMaxBitmapHeight;

@end
