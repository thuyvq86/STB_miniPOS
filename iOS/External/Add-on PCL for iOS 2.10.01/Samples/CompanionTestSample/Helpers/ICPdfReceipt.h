//
//  ICPdfReceipt.h
//  EasyPayEMVCradle
//
//  Created by Hichem Boussetta on 30/09/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIImage.h>


/*!
    @header ICPdfReceipt
    @abstract   Header file of ICPdfReceipt
    @discussion 
*/



/*!
    @defined 
    @abstract   Horizontal margin length used when generating a PDF receipt from raw monochrome data
    @discussion The margin is applied on both sides of the document (left and top)
*/
#define kHorizontalMargin	100


/*!
	@defined 
	@abstract   Vertical margin length used when generating a PDF receipt from raw monochrome data
	@discussion The margin is applied both on top and bottom of the PDF document
*/
#define kVerticalMargin		100




/*!
    @defined 
    @abstract   The PDF Document's Page Width
    @discussion 
*/
#define kPdfPageWidth		500



/*!
 @defined 
 @abstract   The PDF Document's Page Height
 @discussion 
 */
#define kPdfPageHeight		3200





/*!
    @class
    @abstract    Purchase Receipt Generation in PDF File Format
    @discussion  This class offers the basic functionalities for generating receipts in PDF file format.
				 The PDF document may be built of text, bitmap resources or raw buffers
*/
@interface ICPdfReceipt : NSObject {
	
#pragma mark Bitmap configuration
	//Number of bits per pixel color component
	NSUInteger			  _bitsPerPixelComponent;
	
	//Number of bits per pixel
	NSUInteger			  _bitsPerPixel;
	
	//The color space to be used for the PDF's graphics context initialization
	CGColorSpaceRef		  _colorSpace;
	
	//This decode array is to be defined before rendering a PDF context when willing to change the 2D engine's default rendering behaviour
	CGFloat				* _colorDecodeArray;
	
#pragma mark -
	
#pragma mark PDF Document Properties
	//The PDF title
	NSString			* pdfTitle;
	
	//The PDF creator's name
	NSString			* pdfCreator;
	
	//The current font name used to draw text within the current PDF context
	NSString			* pdfTextFont;
	
	//The current font size used to draw text within the current PDF context
	NSUInteger			  pdfTextSize;
	
	//The text alignement
	NSUInteger			  pdfTextAlignment;
	
	//Tells whether the PDF document has only one page
	BOOL				  isSinglePageDocument;
#pragma mark -
	
#pragma mark Sequential PDF Generation Variables
	//A reference to the current PDF graphics context
	CGContextRef		  _pdfContext;
	
	//The PDF's dimension. This is initialized within the createPdfWithNameandSize
	CGRect				  _pdfCanvas;
	
	//This array holds all the data sources needed to render the PDF context. These sources are freed when endPdfCreate is called.
	NSMutableArray		* _dataProviderSources;
	
	//The PDF file data consumer
	CGDataConsumerRef	  _pdfDataConsumer;
	
	//The PDF file data
	NSMutableData		* _pdfData;

#pragma mark -
}



/*!
    @method     
    @abstract   The title of the PDF document to be generated
    @discussion This attribute should be set before generating the PDF in order to be applied, and it is different 
				from the file's name. The title is viewed in the title bar of the PDF reader
*/
@property (nonatomic, copy) NSString * pdfTitle;


/*!
	@method     
	@abstract   The creator of the PDF document to be generated
	@discussion This attribute should be set before generating the PDF in order to be applied
*/
@property (nonatomic, copy) NSString * pdfCreator;

/*!
	@method     
	@abstract   The font used to draw text to the PDF receipt
	@discussion The default value is Verdana and it may be changed as needed before generating the PDF document
*/
@property (nonatomic, copy) NSString * pdfTextFont;


/*!
	@method     
	@abstract   The font size of the text to be drawn to the PDF receipt
	@discussion The default value is 10 and it may be changed as needed before generating the PDF document
*/
@property (nonatomic, assign) NSUInteger pdfTextSize;




/*!
	@method     
	@abstract   The alignment of the text to be drawn to the PDF receipt
	@discussion By default, the text is aligned to the left
 */
@property (nonatomic, assign) NSUInteger pdfTextAlignment;



#pragma mark Sequential PDF Generation Routines


/*!
    @method     
    @abstract   Initializes a PDF receipt generation session
    @discussion This method prepares for the generation of a PDF document by initializing a new graphics context 
				with a drawing canvas of a given size
	@result		YES if a PDF context was created successfully, NO otherwise.
*/
-(BOOL)beginPdfCreate;



/*!
	@method     
	@abstract   Ends the PDF's document generation
	@discussion This method saves the PDF document to disk and destroys the graphics context used for rendering
	@result		A NSData containing the PDF. This may be written to a file on disk.
*/
-(NSData *)endPdfCreate;



/*!
	@method     
	@abstract   This method draws a text string to a given graphics context at a given position
	@discussion 
	@param		text The text to be drawn to the graphics context
	@param		topLeft The position where the top left corner of the text string will be drawn.
	@result		The actual size of the rendered text.
*/
-(CGSize)drawText:(NSString *)text atPosition:(CGPoint)topLeft;


/*!
	@method     
	@abstract   This method draws a bitmap provided as a resource name to a given graphics context at a given position
	@discussion 
	@param		image A UIImage object to be drawn to the receipt
	@param		topLeft The position where the bottom left corner of the bitmap will be drawn. 
*/
-(CGSize)drawBitmapWithImage:(UIImage *)image atPosition:(CGPoint)topLeft;

/*!
	@method
	@abstract   This method calculate the bitmap size
	@discussion
	@param		image A UIImage object to be drawn to the receipt
 */
-(CGSize)getBitmapSizeWithImage:(UIImage *)image;

#pragma mark -




/*!
 @method     
 @abstract   draws a raw bitmap to a provided graphics context at a given position
 @discussion 
 @param		data The raw bitmap buffer
 @param		imageWidth The width in pixels of the bitmap
 @param		topLeft The position where the top left corner of the bitmap will be drawn. 
 @result	The size of the rectangle occupied by the bitmap. This may be different of the actual size in pixels of the image 
			in case it undergoes a scaling transformation to fit the text borders in the PDF document
 */
-(CGSize)drawBitmapWithRawData:(NSData *)data andWidth:(NSUInteger)imageWidth atPosition:(CGPoint)topLeft;




/*!
	@method     
	@abstract    Creates a PDF document from raw monochronme bitmap data
	@discussion 
	@param		 microlineData The raw data from which the PDF should be generated. Pixels should be 1-bit encoded.
	@param		 lineCount The number of rows of the bitmap, which is also its height
 	@result		 A NSData containing the receipt data in PDF. The result is nil if an error occured during the receipt generation.
*/
-(NSData *)createPdfReceiptWithMicrolineData:(NSData *)microlineData andLineCount:(NSUInteger)lineCount;


@end

