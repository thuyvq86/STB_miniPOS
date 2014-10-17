//
//  ICSignatureView.m
//  EasyPayEMVCradle
//
//  Created by Hichem Boussetta on 01/10/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "ICSignatureView.h"



@implementation ICSignatureView



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
        
        memset(_bitmapBuffer, 0, _bitmapBufferSize);
        self.backgroundColor = [UIColor blackColor];
	}
	return self;
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
		//[POSLogger logDebugMessage:@"%sPoint located outside the canvas", __FUNCTION__];
		return;
	}
	
	CGPathMoveToPoint(_linePath, NULL, point.x, point.y);
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
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


-(void)drawRect:(CGRect)rect {
	
	//Draw the image to UIView from the bitmap content
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, 3.0);
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextStrokePath(context);
	CGContextAddPath(context, _linePath);
	CGContextDrawPath(context, kCGPathStroke);
}

static void releaseBytes(void *info, const void *data, size_t size) {
	free((void*)data);
}

-(UIImage *)getSignatureData {
	//Create a bitmap context to draw the signature
	_bitmapContext = CGBitmapContextCreate(_bitmapBuffer, _width, _height, _bitsPerComponent, _bytesPerRow, _colorSpace, kCGImageAlphaNone);
	CGContextSetLineCap(_bitmapContext, kCGLineCapRound);
	CGContextSetLineWidth(_bitmapContext, 3.0);
	CGContextSetRGBStrokeColor(_bitmapContext, 1.0, 1.0, 1.0, 1.0);
	CGContextAddPath(_bitmapContext, _linePath);
	CGContextStrokePath(_bitmapContext);
	CGContextRelease(_bitmapContext);
	
	//Reverse bitmap rows
	NSData * reversedData = [ICSignatureView reverseBitmapWithData:[NSData dataWithBytes:_bitmapBuffer length:_bitmapBufferSize] andWidth:_width];
	char * reversedBytes = (char *)malloc(_bitmapBufferSize * sizeof(char));
	memcpy(reversedBytes, [reversedData bytes], _bitmapBufferSize);
	
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
	//Create a bitmap context to draw the signature
	_bitmapContext = CGBitmapContextCreate(_bitmapBuffer, _width, _height, _bitsPerComponent, _bytesPerRow, _colorSpace, kCGImageAlphaNone);
	CGContextSetLineCap(_bitmapContext, kCGLineCapRound);
	CGContextSetLineWidth(_bitmapContext, 3.0);
	CGContextSetRGBStrokeColor(_bitmapContext, 1.0, 1.0, 1.0, 1.0);
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
	CGPathRelease(_linePath);
	_linePath = NULL;
	_linePath = CGPathCreateMutable();
	memset(_bitmapBuffer, 0, _bitmapBufferSize);
	[self setNeedsDisplay];
}

@end
