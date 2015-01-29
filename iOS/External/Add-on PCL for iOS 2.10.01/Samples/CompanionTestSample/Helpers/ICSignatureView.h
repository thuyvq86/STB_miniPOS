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



-(void)clear;

@end
