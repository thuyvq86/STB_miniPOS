//
//  ICSignatureView.m
//  EasyPayEMVCradle
//
//  Created by Hichem Boussetta on 01/10/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "ICSignatureView.h"

#import <QuartzCore/QuartzCore.h>

@implementation ICSignatureView

@synthesize blackBackground = _blackBackground;


-(id) initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_width				= frame.size.width;
		_height				= frame.size.height;
		_bitmapContext		= NULL;
		_bitsPerComponent	= 8;
		_bitsPerPixel		= 8;
		_bytesPerRow		= _width * _bitsPerComponent / 8;
		_bitmapBufferSize	= _height * _bytesPerRow;
		_bitmapBuffer		= (char *)malloc(_bitmapBufferSize * sizeof(char));
		_colorSpace			= CGColorSpaceCreateDeviceGray();
		_linePath			= CGPathCreateMutable();
	}
	return self;
}


-(void)setBlackBackground:(BOOL)blackBackground {
    
    _blackBackground = blackBackground;
    
    if (self.blackBackground) {
        self.backgroundColor = [UIColor blackColor];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        memset(_bitmapBuffer, 0, _bitmapBufferSize);
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        memset(_bitmapBuffer, 0xFF, _bitmapBufferSize);
    }
    self.layer.borderWidth = 2.0f;
}


-(void)dealloc {
	if (_bitmapBuffer) {
		free(_bitmapBuffer);
	}
	CGPathRelease(_linePath);
	CGColorSpaceRelease(_colorSpace);
	[super dealloc];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	static NSInteger index = 0;
	CGPoint point = [[touches anyObject] locationInView:self];	
	
	//Check if the point is inside the canvas. This avoids segmentation errors.
	index = (NSInteger)(point.x + (_height - point.y) * _bytesPerRow);
	if ((index < 0)||(index >= _bitmapBufferSize)) {
		//NSLog(@"%sPoint located outside the canvas", __FUNCTION__);
		return;
	}
	
	CGPathMoveToPoint(_linePath, NULL, point.x, point.y);
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	static NSInteger index = 0;
	static CGPoint point = {0, 0};
	point = [[touches anyObject] locationInView:self];
	
    //NSLog(@"%s Touch Location [%f, %f]", __FUNCTION__, point.x, point.y);
    
	//Check if the point is inside the canvas. This avoids segmentation errors.
	index = (NSInteger)(point.x + (_height - point.y) * _bytesPerRow);
	if ((index < 0)||(index >= _bitmapBufferSize)) {
		return;
	}
	
	CGPathAddLineToPoint(_linePath, NULL, point.x, point.y);
	[self setNeedsDisplay];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	static NSInteger index = 0;
	static CGPoint point = {0, 0};
	point = [[touches anyObject] locationInView:self];
	
	//Check if the point is inside the canvas. This avoids segmentation errors.
	index = (NSInteger)(point.x + (_height - point.y) * _bytesPerRow);
	if ((index < 0)||(index >= _bitmapBufferSize)) {
		return;
	}
	
	CGPathAddLineToPoint(_linePath, NULL, point.x, point.y);
	[self setNeedsDisplay];
}

//Called after calling setNeedsDisplay
-(void)drawRect:(CGRect)rect {
	
	//Draw the image to UIView from the bitmap content
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, 3.0);
    if (self.blackBackground) {
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    } else {
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
    }
	CGContextStrokePath(context);
	CGContextAddPath(context, _linePath);
	CGContextDrawPath(context, kCGPathStroke);
}

static void releaseBytes(void *info, const void *data, size_t size) {
	free((void*)data);
}

-(UIImage *)getSignatureData {
    NSLog(@"%s", __FUNCTION__);
	//Create a bitmap context to draw the signature
	_bitmapContext = CGBitmapContextCreate(_bitmapBuffer, _width, _height, _bitsPerComponent, _bytesPerRow, _colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
	CGContextSetLineCap(_bitmapContext, kCGLineCapRound);
	CGContextSetLineWidth(_bitmapContext, 3.0);
    if (self.blackBackground) {
        CGContextSetRGBStrokeColor(_bitmapContext, 1.0, 1.0, 1.0, 1.0);
    } else {
        CGContextSetRGBStrokeColor(_bitmapContext, 0, 0, 0, 1.0);
    }
	CGContextAddPath(_bitmapContext, _linePath);
	CGContextStrokePath(_bitmapContext);
	CGContextRelease(_bitmapContext);
	
	//Reverse bitmap rows - Transform from Screen -> Bitmap coordinates
	NSData * reversedData = [ICSignatureView reverseBitmapWithData:[NSData dataWithBytes:_bitmapBuffer length:_bitmapBufferSize] andWidth:_width];
	char * reversedBytes = (char *)malloc(_bitmapBufferSize * sizeof(char));
	memcpy(reversedBytes, [reversedData bytes], _bitmapBufferSize);
    
    if (!self.blackBackground) {
        //Reverse colors because LibiSMP will reverse them too (it expects white on black signature)
         int i = 0;
         for (i = 0; i < _bitmapBufferSize; i++) {
             reversedBytes[i] = ((reversedBytes[i] == 0) ? 0xFF : 0x00);
         }
    }
	
	//Build a UIImage from the bitmap data
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, reversedBytes, _bitmapBufferSize, releaseBytes);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGImageRef cgimage = CGImageCreate(_width, _height, 8, 8, _width, colorSpace, kCGBitmapByteOrderDefault, dataProvider, NULL, NO, kCGRenderingIntentDefault);
	UIImage * image = [UIImage imageWithCGImage:cgimage];
	CGDataProviderRelease(dataProvider);
	CGImageRelease(cgimage);
	CGColorSpaceRelease(colorSpace);
	return image;
}


-(UIImage *)getSignatureDataAtBoundingBox {
    NSLog(@"%s", __FUNCTION__);
	//Create a bitmap context to draw the signature
	_bitmapContext = CGBitmapContextCreate(_bitmapBuffer, _width, _height, _bitsPerComponent, _bytesPerRow, _colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
	CGContextSetLineCap(_bitmapContext, kCGLineCapRound);
	CGContextSetLineWidth(_bitmapContext, 3.0);
    if (self.blackBackground) {
        CGContextSetRGBStrokeColor(_bitmapContext, 1.0, 1.0, 1.0, 1.0);
    } else {
        CGContextSetRGBStrokeColor(_bitmapContext, 0, 0, 0, 1.0);
    }
	CGContextAddPath(_bitmapContext, _linePath);
	CGContextStrokePath(_bitmapContext);
	CGContextRelease(_bitmapContext);
	
	//Get the bounding box containing the signature's line path
	CGRect boundingBox = CGPathGetBoundingBox(_linePath);
	
	NSUInteger i = 0;
	NSUInteger x, y , width, height, size;
	x		= (NSUInteger)boundingBox.origin.x;
	y		= _height - (NSUInteger)(boundingBox.origin.y + boundingBox.size.height);
	width	= (NSUInteger)boundingBox.size.width;
	height	= (NSUInteger)boundingBox.size.height;
	size = width * height;
	char buffer[size];
	char * p_buf = buffer;
	char * p_bitmapBuffer = &_bitmapBuffer[x + y * _width];
	for (i = 0; i < height; i++) {
		memcpy(p_buf, p_bitmapBuffer, width);
		p_buf			+= width;
		p_bitmapBuffer	+= _width;
	}
	
	//Reverse bitmap rows
	NSData * reversedData = [ICSignatureView reverseBitmapWithData:[NSData dataWithBytes:buffer length:size] andWidth:width];
	char * reversedBytes = (char *)malloc(size * sizeof(char));
	memcpy(reversedBytes, [reversedData bytes], size);
    
    if (!self.blackBackground) {
        //Reverse colors
        for (i = 0; i < size; i++) {
//            reversedBytes[i] = ((reversedBytes[i] == 0) ? 0xFF : 0x00);
            reversedBytes[i] = ((reversedBytes[i] == 0) ? 0x00 : 0xFF);
        }
    }
	
	//Build a UIImage from the bitmap data
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, reversedBytes, size, releaseBytes);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGImageRef cgimage = CGImageCreate(width, height, 8, 8, width, colorSpace, kCGBitmapByteOrderDefault, dataProvider, NULL, NO, kCGRenderingIntentDefault);
	UIImage * image = [UIImage imageWithCGImage:cgimage];
	CGDataProviderRelease(dataProvider);
	CGImageRelease(cgimage);
	CGColorSpaceRelease(colorSpace);
	return image;
}


+(UIImage *)reverseImage:(UIImage *)image {
    NSLog(@"%s", __FUNCTION__);
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, image.size.width, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM (context, 0, - image.size.height);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object  
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}


+(UIImage *)invertImageColors:(UIImage *)image; {
    NSLog(@"%s", __FUNCTION__);

    if (image == nil) {
        NSLog(@"%s Invalid Image", __FUNCTION__);
        return nil;
    }
    
    //Get a reference to the original image
    CGImageRef  imageRef = image.CGImage;
    
    //Create the appropritate color map array to invert the colors
    CGFloat colorMap[]      = {1, 0};
    
    //Apply the color map to a new image
	CGImageRef cgimage = CGImageCreate(CGImageGetWidth(imageRef),
                                       CGImageGetHeight(imageRef),
                                       CGImageGetBitsPerComponent(imageRef),
                                       CGImageGetBitsPerPixel(imageRef),
                                       CGImageGetBytesPerRow(imageRef),
                                       CGImageGetColorSpace(imageRef),
                                       CGImageGetBitmapInfo(imageRef),
                                       CGImageGetDataProvider(imageRef),
                                       colorMap,
                                       CGImageGetShouldInterpolate(imageRef),
                                       CGImageGetRenderingIntent(imageRef));
    
    //Return the UIImage object
    return [UIImage imageWithCGImage:cgimage];
}


+(NSData *)reverseBitmapWithData:(NSData *)inData andWidth:(NSUInteger)width {
	NSUInteger i = 0;
	char reversed[[inData length]];
	char * bitmapBuffer = (char *)[inData bytes];
	NSUInteger rowSize = width;
	NSUInteger height = [inData length] / width;
	for (i = 0; i < height; i++) {
		memcpy(&reversed[i * rowSize], &bitmapBuffer[(height - 1 - i) * rowSize], rowSize);
	}
	
	return [NSData dataWithBytes:reversed length:[inData length]];
}


+(NSData *)from8to1BitPerPixel:(NSData *)inData andWidth:(NSUInteger)width {
	NSUInteger height = [inData length] / width;
	NSUInteger size = ((width + 7) / 8) * height;
	NSUInteger effectiveWidth = (size * 8) / height;
	char * inDataBuffer = (char *)[inData bytes];
	char * outBuffer = (char *)malloc(size * sizeof(char));
	memset(outBuffer, 0, size);
	NSUInteger i = 0, j = 0, in_index = 0, out_index = 0;
	if (width % 8 == 0) {
		for (i = 0; i < [inData length]; i++) {
			outBuffer[i / 8] = outBuffer[i / 8] | (inDataBuffer[i] & 0x80) >> (i % 8);		// 0x80 --> 10000000 in binary
		}
	}
	else {
		for (i = 0; i < height; i++) {
			for (j = 0; j < width; j++) {
				in_index = j + i * width;
				out_index = (j + i * effectiveWidth) / 8;
				outBuffer[out_index] = outBuffer[out_index] | (inDataBuffer[in_index] & 0x80) >> ((j + i * effectiveWidth) % 8);
			}
		}
	}
    
	return [NSData dataWithBytesNoCopy:outBuffer length:size];
}


-(void)clear {
    NSLog(@"%s", __FUNCTION__);
	CGPathRelease(_linePath);
	_linePath = NULL;
	_linePath = CGPathCreateMutable();
    
    if (self.blackBackground) {
        memset(_bitmapBuffer, 0, _bitmapBufferSize);
    } else {
        memset(_bitmapBuffer, 0xFF, _bitmapBufferSize);
    }
    
	[self setNeedsDisplay];
}




+(NSData *)image2Bitmap:(UIImage *)image {
    NSLog(@"%s", __FUNCTION__);
	NSData * imageData = (NSData *)CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
	if (imageData == nil)
		return nil;
	char * imageBytes = (char *)[imageData bytes];
	bmpfile_magic magic;
	bmpfile_header header;
	bmpfile_information information;
	
	//Encode the data (Convert the 8-bit-pixel encoding to an 1-bit-pixel encoding)
	NSUInteger height = CGImageGetHeight(image.CGImage);
	NSUInteger width = CGImageGetWidth(image.CGImage);
	NSUInteger size = ((width + 7) / 8) * height;
	NSUInteger effectiveWidth = (size * 8) / height;
	char buffer[size];
	memset(buffer, 0, size);
	NSUInteger i = 0, j = 0, in_index = 0, out_index = 0;
	if (width % 8 == 0) {
		for (i = 0; i < [imageData length]; i++) {
			//buffer[i / 8] = buffer[i / 8] | (~sigBytes[i] & 0x80) >> (i % 8);		// 0x80 --> 10000000 in binary, the tilde (~) is used to invert the black to white
            buffer[i / 8] = buffer[i / 8] | (imageBytes[i] & 0x80) >> (i % 8);
		}
	}
	else {
		for (i = 0; i < height; i++) {
			for (j = 0; j < width; j++) {
				in_index = j + i * width;
				out_index = (j + i * effectiveWidth) / 8;
				//buffer[out_index] = buffer[out_index] | (~sigBytes[in_index] & 0x80) >> ((j + i * effectiveWidth) % 8);
                buffer[out_index] = buffer[out_index] | (imageBytes[in_index] & 0x80) >> ((j + i * effectiveWidth) % 8);
			}
		}
	}
	
	
	char sigBuffer[sizeof(bmpfile_magic) + sizeof(bmpfile_header) + sizeof(bmpfile_information) + size];
	
	memcpy(magic.magic, "BM", sizeof(magic.magic));
	
	header.filesz				= sizeof(bmpfile_magic) + sizeof(bmpfile_header) + sizeof(bmpfile_information) + (int)size;
	header.bmp_offset			= sizeof(bmpfile_magic) + sizeof(bmpfile_header) + sizeof(bmpfile_information);
	
	information.header_sz		= sizeof(bmpfile_information);
	information.width			= (int)width;
	information.height			= (int)height;
	information.nplanes			= 1;										//Number of color planes. Must be set to 1
	information.bitspp			= 1;
	information.compress_type	= 0;										//0 --> No compression
	information.bmp_bytesz		= (int)size;
	information.hres			= (int)width;
	information.vres			= (int)height;
	information.ncolors			= 2;										//The palette used contains two colors: black & white
	information.nimpcolors		= 0;										//Number of important colors. 0 means that all colors are important
	
	memcpy(sigBuffer, &magic, sizeof(bmpfile_magic));
	memcpy(&sigBuffer[sizeof(bmpfile_magic)], &header, sizeof(bmpfile_header));
	memcpy(&sigBuffer[sizeof(bmpfile_magic) + sizeof(bmpfile_header)], &information, sizeof(bmpfile_information));
	memcpy(&sigBuffer[sizeof(bmpfile_magic) + sizeof(bmpfile_header) + sizeof(bmpfile_information)], buffer, size);
	NSData * signature = [NSData dataWithBytes:sigBuffer length:header.filesz];
	[imageData release];
	return signature;
}

@end
