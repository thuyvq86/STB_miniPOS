//
//  ICSignatureView.h
//  EasyPayEMVCradle
//
//  Created by Hichem Boussetta on 01/10/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>



/*!
 @header ICSignatureView
 @abstract   Header file for ICSignatureView class
 @discussion 
 */





/*!
 @class
 @abstract    This class handles signature drawing and encoding to the format expected by the SPM
 @discussion  
 */

@interface ICSignatureView : UIView {
	
	//The ICSignatureView's width
	NSUInteger			_width;
	
	//The ICSignatureView's height
	NSUInteger			_height;
	
	//Number of bits per color component
	NSUInteger			_bitsPerComponent;
	
	//Number of bits per pixel (= number of bits per component multiplied by number of components per pixel)
	NSUInteger			_bitsPerPixel;
	
	//Size of the buffer containing the bitmap pixel's data
	NSUInteger			_bitmapBufferSize;
	
	//Number of bytes per row
	NSUInteger			_bytesPerRow;
	
	//The buffer containing the bitmap's data
	char				* _bitmapBuffer;
	
	//The graphics context used to draw the bitmap
	CGContextRef		_bitmapContext;
	
	//The color space to be used to render the bitmap
	CGColorSpaceRef		_colorSpace;
	
	//A line path structure holding the line segments of a signature
	CGMutablePathRef	_linePath;
}


@property (nonatomic, assign) BOOL blackBackground;


/*!
 @method     
 @abstract   Initializes the view with a frame
 @discussion This is an overload of the UIView initWithFrame method
 @param		frame A CGRect structure that defines the region that should be occupied by the view
 @result		The initialized receiver
 */
-(id)initWithFrame:(CGRect)frame;



/*!
 @method     
 @abstract   Returns the signature's data
 @discussion <p align="justify">This method returns the raw data of the signature's drawing. Other methods are provided in order to transform the data according 
 to the application's need. The <b>from8to1BitPerPixel</b> method, for instance, encodes each pixel of 
 the graphics on a single bit, and thus, reduces by approximately a factor of 8 the size of the data. The <b>reverseBitmapWithData</b> 
 method reverses the data buffer, so that the first byte maps to the top left pixel of the graphics.</p>
 @result		An UIImage containing the signature.
 */
-(UIImage *)getSignatureData;



/*!
 @method     
 @abstract   Returns the data within the bounding box containing the signature
 @discussion <p  align="justify">Use this method instead to retrieve only the data bytes within the bounding box 
 containing the signature. The <b>getSignatureData</b> method is to be used if the dimensions of the graphics 
 are fixed in advance.</p>
 @result	 NSData containing the signature bytes. Each byte represents a pixel, and the first corresponds to the bottom left pixel of the bitmap.
 */
-(UIImage *)getSignatureDataAtBoundingBox;


/*!
 @method     
 @abstract   This class method transforms from one byte encoding to one bit encoding the pixels of a bitmap.
 @discussion <p align="justify">This method may be applied to the data returned by the <b>getSignatureData</b> 
 or the <b>getSignatureDataAtBoundingBox</b> which return bitmaps with one-byte encoded pixels 
 to get a bitmap with one-bit encoeded pixels</p>
 @param		 inData NSData representing a 1-Byte-per-pixel bitmap buffer
 @param		 width The width of the bitmap
 @result	 NSData containing the bytes of the bitmap, where each bit is representing a pixel.
 */
+(NSData *)from8to1BitPerPixel:(NSData *)inData andWidth:(NSUInteger)width;




/*!
 @method     
 @abstract   This class method reverses the rows of a bitmap
 @discussion <p align="justify">The signature rendering in the canvas provided by the ICSignatureView class returns a bitmap whose  
 data provider's first byte is the bottom left pixel of the bitmap. Reversing the data bytes of the bitmap will provide a buffer where 
 the first byte corresponds to the top left pixel of the bitmap.</p>
 @param		 inData NSData containing the bitmap's bytes
 @param		 width The width in pixels of the bitmap
 @result	 NSData containing the data of the reversed bitmap. 
 */
+(NSData *)reverseBitmapWithData:(NSData *)inData andWidth:(NSUInteger)width;



+(UIImage *)reverseImage:(UIImage *)image;      //Flip the image upside down


+(UIImage *)invertImageColors:(UIImage *)image;      //Invert the colors of a black and white image


-(void)clear;   //Clear the signature drawing area



+(NSData *)image2Bitmap:(UIImage *)image;       //Create a bitmap file out of the UIImage object - The bitmap configuration is monochrome (black & white) when each pixel is encoded using 1 bit

@end



#pragma mark Bitmap File Header


/*!
 @struct 
 @abstract   Magic characters at the beginning of the bitmap file
 @discussion Should be set to "BM"
 @field      magic A two-byte array containing the magic characters
 */
typedef struct {
	unsigned char magic[2];
} bmpfile_magic;




/*!
 @struct 
 @abstract   The bitmap file header
 @discussion Contains general information about the bitmap file
 @field      filesz The size of the bitmap file
 @field		creator1 A field containing information about the creator of the bitmap file
 @field		creator2 A second field containing information about the bitmap file's creator
 @field		bmp_offset The offset in bytes to the actual bitmap data starting from the beginning of the file
 */
typedef struct {
	uint32_t filesz;
	uint16_t creator1;
	uint16_t creator2;
	uint32_t bmp_offset;
} bmpfile_header;



/*!
 @struct 
 @abstract   Bitmap related information
 @discussion This header describes the bitmap and the way it is encoded
 @field      header_sz The size of the bitmap information header (40 bytes)
 @field		width The bitmap width in pixels
 @field		height The bitmap height in pixels
 @field		nplanes The number of color planes being used. Must be set to 1.
 @field		bitspp The number of bits per pixel
 @field		compress_type The compression method being used
 @field		bmp_bytesz The image size
 @field		hres The horizontal resolution of the image
 @field		vres The vertical resolution of the image
 @field		ncolors The number of colors in the color palette
 @field		nimpcolors The number of important colors used, or 0 when every color is important.
 */
typedef struct {
	uint32_t header_sz;
	int32_t width;
	int32_t height;
	uint16_t nplanes;
	uint16_t bitspp;
	uint32_t compress_type;
	uint32_t bmp_bytesz;
	int32_t hres;
	int32_t vres;
	uint32_t ncolors;
	uint32_t nimpcolors;
} bmpfile_information;

#pragma mark -

