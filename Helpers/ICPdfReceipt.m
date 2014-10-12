//
//  ICPdfReceipt.m
//  EasyPayEMVCradle
//
//  Created by Hichem Boussetta on 30/09/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "ICPdfReceipt.h"
#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>

/*!
    @header ICPdfReceipt.m
    @abstract   PDF Generation
    @discussion receipt
*/


/*!
    @category
    @abstract    This category contains the private methods of ICPdfReceipt
    @discussion  Private ICPdfReceipt's methods are kept inside the implementation file so that they are not called from outside.
*/
@interface ICPdfReceipt (Private)

/*!
 @method     
 @abstract   This initializes the ICPdfReceipt to render monochrome black & white bitmaps
 @discussion This method must be called before drawing a bitmap from a raw pixel buffer. If the raw data does not 
 correspond to a monochrome configuration, the rendering of the bitmap will fail
 */
-(void)_loadMonochromeConfiguration;

/*!
 @method     
 @abstract   draws a raw bitmap to a provided graphics context at a given position
 @discussion 
 @param		 data The raw bitmap buffer
 @param		 imageWidth The width in pixels of the bitmap
 @param		 bottomLeft The position where the bottom left corner of the bitmap will be drawn. 
 */
-(void)_drawBitmapWithRawData:(NSData *)data andWidth:(NSUInteger)imageWidth toContext:(CGContextRef)graphicsContext atPosition:(CGPoint)bottomLeft;

@end



@implementation ICPdfReceipt

@synthesize pdfTitle, pdfCreator, pdfTextFont, pdfTextSize, pdfTextAlignment;

-(id)init {
	if ((self = [super init])) {
		pdfCreator				= [[NSString alloc] initWithString:@"iSMP"];
		pdfTitle				= [[NSString alloc] initWithString:@"iSMP Ticket"];
		pdfTextFont				= [[NSString alloc] initWithString:@"Verdana"];
		pdfTextSize				= 10;
		pdfTextAlignment		= UITextAlignmentLeft;
		_pdfContext				= NULL;
		_pdfDataConsumer		= NULL;
		_colorDecodeArray		= NULL;
		_colorSpace				= NULL;
		isSinglePageDocument	= YES;
		_pdfData				= nil;
		_dataProviderSources	= [[NSMutableArray alloc] init];
		[self _loadMonochromeConfiguration];
	}
	return self;
}


-(void)dealloc {
	[pdfTitle release];
	[pdfCreator release];
	[pdfTextFont release];
	[_dataProviderSources removeAllObjects];
	[_dataProviderSources release];
	CGColorSpaceRelease(_colorSpace);
	if (_pdfContext != NULL) {
		CGContextRelease(_pdfContext);
	}
    if (_pdfDataConsumer != NULL) {
		CGDataConsumerRelease(_pdfDataConsumer);
		_pdfDataConsumer = NULL;
	}
	if (_colorDecodeArray != NULL) {
		free(_colorDecodeArray);
	}
	[super dealloc];
}


#pragma mark Drawing Routines

-(CGSize)drawText:(NSString *)text atPosition:(CGPoint)topLeft {
	//CGContextSetCharacterSpacing(graphicsContext, 1);
	CGContextSetRGBFillColor(_pdfContext, 0, 0, 0, 100);
	CGContextSetRGBStrokeColor(_pdfContext, 0, 0, 0, 100);
	CGRect textRect = {{kHorizontalMargin + topLeft.x, kVerticalMargin - kPdfPageHeight + topLeft.y}, {kPdfPageWidth - 2 * kHorizontalMargin - topLeft.x, kPdfPageHeight - 2 * kVerticalMargin - topLeft.y}};
	UIFont * textFont = [UIFont fontWithName:pdfTextFont size:pdfTextSize];
	CGSize actualTextRectSize;
	
	//The graphics context where the text is drawn should be set as the actual rendering context and should be unset just after
	//in order for drawInRect method to work properly
	UIGraphicsPushContext(_pdfContext);
	
	//Reverse the coordinates so that the text is drawn correctly
	CGContextScaleCTM(_pdfContext, 1.0, -1.0);
	
	actualTextRectSize = [text drawInRect:textRect withFont:textFont lineBreakMode:NSLineBreakByWordWrapping alignment:pdfTextAlignment];
	CGContextScaleCTM(_pdfContext, 1.0, -1.0);
	UIGraphicsPopContext();
	
	return actualTextRectSize;
}


-(void)_drawBitmapWithRawData:(NSData *)data andWidth:(NSUInteger)imageWidth toContext:(CGContextRef)graphicsContext atPosition:(CGPoint)bottomLeft {
	CGImageRef bitmap = NULL;
	CGDataProviderRef bitmapData = NULL;
	NSUInteger bytesPerRow = (imageWidth * _bitsPerPixel + 7) / 8;
	CGRect canvas = {{bottomLeft.x, bottomLeft.y}, {imageWidth, [data length] / bytesPerRow}};
	bitmapData = CGDataProviderCreateWithData(NULL, [data bytes], [data length], NULL);
	if (bitmapData != NULL) {
		bitmap = CGImageCreate(imageWidth, [data length] / bytesPerRow, _bitsPerPixelComponent, _bitsPerPixel, bytesPerRow,
							   _colorSpace, kCGBitmapByteOrderDefault, bitmapData, _colorDecodeArray, NULL, kCGRenderingIntentDefault);
		if (bitmap != NULL) {
			CGContextDrawImage(graphicsContext, canvas, bitmap);
			CGImageRelease(bitmap);
		}
		else {
			// [POSLogger logError:@"%sFailed to create bitmap", __FUNCTION__];
		}
		CFRelease(bitmapData);
	}
	else {
		// [POSLogger logError:@"%sNo data provider for the bitmap", __FUNCTION__];
	}
}



-(CGSize)drawBitmapWithRawData:(NSData *)data andWidth:(NSUInteger)imageWidth atPosition:(CGPoint)topLeft {
	[self _loadMonochromeConfiguration];
	CGImageRef bitmap = NULL;
	CGDataProviderRef bitmapData = NULL;
	CGSize retValue;
	NSUInteger bytesPerRow = (imageWidth * _bitsPerPixel + 7) / 8;
	if ((bytesPerRow == 0)||(data == nil)) {
		// [POSLogger logError:@"%sInvalid Bitmap Data", __FUNCTION__];
		retValue = CGSizeMake(0, 0);
	}
	else {
		NSUInteger imageHeight = [data length] / bytesPerRow;
		
		//Compute the scaling factor
		CGFloat scaleFactor = 1;
		
		if (imageWidth > kPdfPageWidth - 2 * kHorizontalMargin) {
			scaleFactor = ((CGFloat)(kPdfPageWidth - 2 * kHorizontalMargin)) / (CGFloat)imageWidth;
		}
		
		
		CGRect canvas = {{kHorizontalMargin / scaleFactor + topLeft.x, (kPdfPageHeight - kVerticalMargin) / scaleFactor - imageHeight - topLeft.y}, {imageWidth, imageHeight}};
		[_dataProviderSources addObject:data];
		NSData * tmpData = [_dataProviderSources lastObject];
		bitmapData = CGDataProviderCreateWithData(NULL, [tmpData bytes], [tmpData length], NULL);
		if (bitmapData != NULL) {
			bitmap = CGImageCreate(imageWidth, imageHeight, _bitsPerPixelComponent, _bitsPerPixel, bytesPerRow,
								   _colorSpace, kCGBitmapByteOrderDefault, bitmapData, _colorDecodeArray, NULL, kCGRenderingIntentDefault);
			if (bitmap != NULL) {
				CGContextScaleCTM(_pdfContext, scaleFactor, scaleFactor);
				CGContextDrawImage(_pdfContext, canvas, bitmap);
				CGContextScaleCTM(_pdfContext, 1 / scaleFactor, 1 / scaleFactor);
				CGImageRelease(bitmap);
				retValue = CGSizeMake(imageWidth * scaleFactor, imageHeight * scaleFactor);
			}
			else {
				// [POSLogger logError:@"%sFailed to create bitmap", __FUNCTION__];
				retValue = CGSizeMake(0, 0);
			}
			CGDataProviderRelease(bitmapData);
		}
		else {
			// [POSLogger logError:@"%sNo data provider for the bitmap", __FUNCTION__];
			retValue = CGSizeMake(0, 0);
		}
	}

	return retValue;
}

-(CGSize)drawBitmapWithImage:(UIImage *)image atPosition:(CGPoint)topLeft {
	if (_pdfContext == NULL) {
		return CGSizeMake(0, 0);
	}
	if (image == nil) {
		// [POSLogger logError:@"%sResource not found or inappropriate", __FUNCTION__];
		return CGSizeMake(0, 0);
	}
	
	//Compute the scaling factor
	CGFloat scaleFactor = 1;
	NSUInteger imageWidth = image.size.width;
	NSUInteger imageHeight = image.size.height;
	if (imageWidth > kPdfPageWidth - 2 * kHorizontalMargin) {
		scaleFactor = ((CGFloat)(kPdfPageWidth - 2 * kHorizontalMargin)) / (CGFloat)imageWidth;
	}
	CGRect canvas = {{kHorizontalMargin / scaleFactor + topLeft.x, (kPdfPageHeight - kVerticalMargin) / scaleFactor - imageHeight - topLeft.y}, {imageWidth, imageHeight}};
	CGContextScaleCTM(_pdfContext, scaleFactor, scaleFactor);
	CGContextDrawImage(_pdfContext, canvas, image.CGImage);
	CGContextScaleCTM(_pdfContext, 1 / scaleFactor, 1 / scaleFactor);
	return canvas.size;
}


#pragma mark -



#pragma mark Bitmap Configuration Routines

-(void)_loadMonochromeConfiguration {
	if(_colorSpace != NULL){
		CGColorSpaceRelease(_colorSpace);
	}
	_colorSpace				= CGColorSpaceCreateDeviceGray();
	_bitsPerPixel			= 1;
	_bitsPerPixelComponent	= 1;
	if(_colorDecodeArray != NULL) {
		free(_colorDecodeArray);
	}
	_colorDecodeArray		= (CGFloat *)malloc(2 * sizeof(CGFloat));
	_colorDecodeArray[0]	= 1;
	_colorDecodeArray[1]	= 0;
}

#pragma mark -


//Generate a PDF receipt from a microline buffer
-(NSData *)createPdfReceiptWithMicrolineData:(NSData *)microlineData andLineCount:(NSUInteger)lineCount {
	CGContextRef pdfContext = NULL;
	CFMutableDictionaryRef pdfProperties = NULL;
	static CGSize PdfPageSizeWithoutMargins = {kPdfPageWidth - 2 * kHorizontalMargin, kPdfPageHeight - 2 * kVerticalMargin};
	
	//Load the microline configuration
	[self _loadMonochromeConfiguration];
	
	//Check the image's data
	if ((lineCount == 0) || (microlineData == nil)) {
		// [POSLogger logError:@"%sInvalid image data", __FUNCTION__];
		return nil;
	}
	
	//Determine the size of the receipt
	NSUInteger imageWidth  = [microlineData length] * 8 / lineCount;
	
	//Set the PDF properties
	pdfProperties = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionarySetValue(pdfProperties, kCGPDFContextTitle, (CFStringRef)pdfTitle);
	CFDictionarySetValue(pdfProperties, kCGPDFContextCreator, (CFStringRef)pdfCreator);
	
	//Draw the PDF's content
	CGRect pdfCanvas = {{0, 0}, {kPdfPageWidth, kPdfPageHeight}};
	CGFloat scaleFactor = 1;
	if (imageWidth > PdfPageSizeWithoutMargins.width) {
		scaleFactor = PdfPageSizeWithoutMargins.width / imageWidth;
	}
	NSMutableData * pdfData = [[NSMutableData alloc] init];
	CGDataConsumerRef pdfDataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfData);
	pdfContext = CGPDFContextCreate(pdfDataConsumer, &pdfCanvas, pdfProperties);
	CFRelease(pdfProperties);
	if (pdfContext == NULL) {
		// [POSLogger logError:@"%sFailed to initialize a PDF context", __FUNCTION__];
		CGDataConsumerRelease(pdfDataConsumer);
		[pdfData release];
		return nil;
	}
	else {
		NSUInteger offset = 0;
		NSUInteger len = [microlineData length];
		char * microlineBuffer = (char *)[microlineData bytes];
		CGPoint position = {kHorizontalMargin / scaleFactor, 0};
		while (offset < len) {
			NSData * data = nil;
			if (isSinglePageDocument == YES) {
				pdfCanvas.size.height = (lineCount + 2 * kVerticalMargin) * scaleFactor;
				data = [[[NSData alloc] initWithBytes:&microlineBuffer[offset] length:[microlineData length]] autorelease];
				position.y = (pdfCanvas.size.height - kVerticalMargin) / scaleFactor - ([data length] * 8) / imageWidth;
			}
			else {
				data = [[[NSData alloc] initWithBytes:&microlineBuffer[offset] length:MIN(len - offset, (PdfPageSizeWithoutMargins.height / scaleFactor) * imageWidth / 8)] autorelease];
				position.y = kVerticalMargin / scaleFactor + PdfPageSizeWithoutMargins.height / scaleFactor - ([data length] * 8) / imageWidth;
			}
			offset += [data length];
			CGContextBeginPage(pdfContext, &pdfCanvas);
			CGContextScaleCTM(pdfContext, scaleFactor, scaleFactor);
			[self _drawBitmapWithRawData:data andWidth:imageWidth toContext:pdfContext atPosition:position];
			//[data release];
			CGContextEndPage(pdfContext);
		}
		CGContextRelease(pdfContext);
		CGDataConsumerRelease(pdfDataConsumer);
	}
	return [pdfData autorelease];
}



#pragma mark Sequential PDF Generation Routines

-(BOOL)beginPdfCreate {
	
	CFMutableDictionaryRef pdfProperties = NULL;
	_pdfCanvas.origin.x		= 0;
	_pdfCanvas.origin.y		= 0;
	_pdfCanvas.size.width	= kPdfPageWidth;
	_pdfCanvas.size.height	= kPdfPageHeight;
	
	//Set the PDF properties
	pdfProperties = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionarySetValue(pdfProperties, kCGPDFContextTitle, (CFStringRef)pdfTitle);
	CFDictionarySetValue(pdfProperties, kCGPDFContextCreator, (CFStringRef)pdfCreator);
	
	//Create the PDF context
	_pdfData = [[NSMutableData alloc] init];
	_pdfDataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)_pdfData);
	_pdfContext = CGPDFContextCreate(_pdfDataConsumer, &_pdfCanvas, pdfProperties);
	CFRelease(pdfProperties);
	
	if (_pdfContext == NULL) {
		// [POSLogger logError:@"%sFailed to initialize a PDF context", __FUNCTION__];
		return NO;
	}
	else {
		CGContextBeginPage(_pdfContext, &_pdfCanvas);
	}
	return YES;
}

-(NSData *)endPdfCreate {
	if (_pdfContext != NULL) {
		CGContextEndPage(_pdfContext);
		CGContextRelease(_pdfContext);
		_pdfContext = NULL;
	}
	[_dataProviderSources removeAllObjects];
	NSData * outData = [NSData dataWithData:_pdfData];
	if (_pdfDataConsumer != NULL) {
		CGDataConsumerRelease(_pdfDataConsumer);
		_pdfDataConsumer = NULL;
	}
	[_pdfData release];
	_pdfData = nil;
	return outData;
}

#pragma mark -



@end
