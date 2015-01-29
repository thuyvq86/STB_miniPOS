//
//  ICBitmapReceipt.m
//  InteractivePayment
//
//  Created by Hichem Boussetta on 01/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ICBitmapReceipt.h"

#define DEFAULT_RECEIPT_WIDTH       384
#define DEFAULT_RECEIPT_HEIGHT      1024 * 64
#define DEFAULT_LINE_JUMP           10


static ICBitmapReceipt * g_sharedBitmapReceipt = nil;



//Convert from UIFont to CTFontRef since there is no toll-free bridging between the two structures
static CTFontRef CTFontCreateFromUIFont(UIFont *font)
{
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    return ctFont;
}



#pragma mark NSMutableAttributedString Category Extra

@interface NSMutableAttributedString (Extras)

//Create a MutableAttributedString from a NSString
//+(NSMutableAttributedString *)mutableAttributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color alignment:(CTTextAlignment)alignment underline:(BOOL)underline;
+(NSMutableAttributedString *)mutableAttributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color alignment:(CTTextAlignment)alignment underline:(BOOL)underline bold:(BOOL)bold;

//Compute the size of a NSMutableAttributeString drawing knowing its width or height
-(CGFloat)boundingWidthForHeight:(CGFloat)inHeight;
-(CGFloat)boundingHeightForWidth:(CGFloat)inWidth;

@end


@implementation NSMutableAttributedString (Extras)


//+(NSMutableAttributedString *)mutableAttributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color alignment:(CTTextAlignment)alignment underline:(BOOL)underline {
+(NSMutableAttributedString *)mutableAttributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color alignment:(CTTextAlignment)alignment underline:(BOOL)underline bold:(BOOL)bold {
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    if (string != nil)
        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef)string);
    
    //Set Color
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTForegroundColorAttributeName, color.CGColor);
    
    //Set Underlining
    int32_t underlineStyleConstant = ((underline) ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone);
    CFNumberRef underlineStyle = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &underlineStyleConstant);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTUnderlineStyleAttributeName, underlineStyle);
    CFRelease(underlineStyle);
    
    //Set Font & Bold style
    CTFontRef theFont = CTFontCreateFromUIFont(font);
    if (bold) {
        CTFontRef boldFont = CTFontCreateCopyWithSymbolicTraits(theFont, 0.0, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, boldFont);
        CFRelease(boldFont);
    } else {
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, theFont);
    }
    CFRelease(theFont);
    
    CTParagraphStyleSetting settings[] = {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTParagraphStyleAttributeName, paragraphStyle);    
    CFRelease(paragraphStyle);
    
    
    NSMutableAttributedString *ret = (NSMutableAttributedString *)attrString;
    
    return [ret autorelease];
}


-(CGFloat)boundingWidthForHeight:(CGFloat)inHeight {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) self); 
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(CGFLOAT_MAX, inHeight), NULL);
    CFRelease(framesetter);
    return suggestedSize.width;   
}

-(CGFloat)boundingHeightForWidth:(CGFloat)inWidth {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) self); 
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(inWidth, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
    return suggestedSize.height;
}

@end


#pragma mark -



@interface ICBitmapReceipt ()

@property (nonatomic, assign) float                         width;
@property (nonatomic, assign) float                         height;
@property (nonatomic, assign) NSUInteger                    bitsPerColor;
@property (nonatomic, assign) NSUInteger                    colors;
@property (nonatomic, assign) float                         vPosition;
@property (nonatomic, assign) CGContextRef                  graphicContext;
@property (nonatomic, assign) CGColorSpaceRef               colorSpace;
@property (nonatomic, assign) CGBitmapInfo                  bitmapInfo;
@property (nonatomic, assign) char *                        pixelBuffer;
@property (nonatomic, assign) NSUInteger                    pixelBufferSize;
@property (nonatomic, retain) NSMutableAttributedString *   lastAttributedString;       //Used to achieve fine grained control over how text is drawn
@property (nonatomic, assign) CGRect                        lastAttributedStringRect;   //The rectangle occupied by the attributed string that is being drawn
@property (nonatomic, retain) NSMutableData             *   pdfData;

//if the bitmap reaches 3/4 its maximum height, this method clears the first half and moves what has been written to the second at the beginning
-(void)checkCircularBuffer;

-(void)eraseRectangle:(CGRect)rectangle;

-(void)invalidateAttributedString;

-(CTTextAlignment)cocoa2CoreFoundationTextAlignment:(UITextAlignment)alignment;

@end




@implementation ICBitmapReceipt

@synthesize textAlignment;
@synthesize textFont;
@synthesize textSize;
@synthesize characterSpacing;
@synthesize textXScaling;
@synthesize textYScaling;
@synthesize width;
@synthesize height;
@synthesize vPosition;
@synthesize bitsPerColor;
@synthesize colors;
@synthesize graphicContext;
@synthesize colorSpace;
@synthesize pixelBuffer;
@synthesize pixelBufferSize;
@synthesize bitmapInfo;
@synthesize lastAttributedString;
@synthesize lastAttributedStringRect;
@synthesize textUnderlining;
@synthesize textInBold;



+(ICBitmapReceipt *)sharedBitmapReceipt {
    if (g_sharedBitmapReceipt == nil) {
        g_sharedBitmapReceipt = [[ICBitmapReceipt alloc] init];
    }
    return g_sharedBitmapReceipt;
}


-(id)init {
    if ((self = [super init])) {
        
        //Initialize the receipt's drawing parameters
        self.width              = DEFAULT_RECEIPT_WIDTH;
        self.height             = DEFAULT_RECEIPT_HEIGHT;
        self.vPosition          = 0;
        self.bitsPerColor       = 8;
        self.colors             = 1;
        self.colorSpace         = CGColorSpaceCreateDeviceGray();
        self.bitmapInfo         = kCGImageAlphaNone;
        self.pixelBufferSize    = self.width * self.height * self.bitsPerColor * self.colors * sizeof(char) / 8;
        self.pixelBuffer        = (char *)malloc(self.pixelBufferSize);
        memset(self.pixelBuffer, 0xFF, self.pixelBufferSize);
        
        //Initialize the graphics context
        self.graphicContext     = CGBitmapContextCreate(self.pixelBuffer, self.width, self.height, self.bitsPerColor, self.width * self.colors * self.bitsPerColor / 8, colorSpace, self.bitmapInfo);
        
        //Text default options
        self.textFont           = @"Verdana";
        self.textAlignment      = UITextAlignmentLeft;
        self.textSize           = DEFAULT_RECEIPT_TEXT_SIZE;
        
        self.textXScaling       = 1;
        self.textYScaling       = 1;
        
        self.lastAttributedString = nil;
        
        CGContextSetCharacterSpacing(graphicContext, self.characterSpacing);
        CGContextSetRGBFillColor(graphicContext, 0, 0, 0, 100);
        CGContextSetRGBStrokeColor(graphicContext, 0, 0, 0, 100);
        
    }
    return self;
}

-(oneway void)release {
    
}

-(void)dealloc {
    //CGContextRelease(self.graphicContext);
    //CGColorSpaceRelease(self.colorSpace);
    //free(self.pixelBuffer);
    [super dealloc];
}


-(void)checkCircularBuffer {
    int bytesPerRow = self.width * self.colors * self.bitsPerColor / 8;
    if (self.vPosition > (3 * self.height / 4)) {
        NSLog(@"%s Clearing the first half of the receipt and shifting the second to the beginning", __FUNCTION__);
        self.vPosition -= self.height / 2;
        char temp[(int)self.vPosition * bytesPerRow];
        memcpy(temp, &self.pixelBuffer[self.pixelBufferSize / 2], self.vPosition * bytesPerRow);
        memset(self.pixelBuffer, 0xFF, self.pixelBufferSize);
        memcpy(self.pixelBuffer, temp, (int)self.vPosition * bytesPerRow);
    }
}

-(void)eraseRectangle:(CGRect)rectangle {
    NSLog(@"%s [X: %f, Y: %f, Width: %f, Height: %f]", __FUNCTION__, rectangle.origin.x, rectangle.origin.y, rectangle.size.width, rectangle.size.height);
    
    UIGraphicsPushContext(self.graphicContext);
    CGContextSetRGBFillColor(self.graphicContext, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(self.graphicContext, rectangle);
    UIGraphicsPopContext();
}

-(void)invalidateAttributedString {
    NSLog(@"%s", __FUNCTION__);
    
    self.lastAttributedString = nil;
}

-(CTTextAlignment)cocoa2CoreFoundationTextAlignment:(UITextAlignment)alignment {
    NSLog(@"%s", __FUNCTION__);
    
    CTTextAlignment result;
    
    switch (alignment) {
        case UITextAlignmentCenter:
            result = kCTTextAlignmentCenter;
            break;
        
        case UITextAlignmentRight:
            result = kCTTextAlignmentRight;
            break;
            
        default:
            result = (CTTextAlignment)alignment;
            break;
    }
    return result;
}


-(void)drawText:(NSString *)text {
    NSLog(@"%s [Text: %@][Font: %@][xScale: %ld, yScale: %d]", __FUNCTION__, text, self.textFont, (long)self.textXScaling, self.textYScaling);
    
    [self invalidateAttributedString];
    
    if (self.graphicContext == NULL) {
        NSLog(@"%s Invalid Graphics Context", __FUNCTION__);
		return;
	}
    
	CGRect textRect = {{0, (self.vPosition - self.height) / self.textYScaling}, {self.width / self.textXScaling, self.height - self.vPosition}};
	UIFont * font = [UIFont fontWithName:self.textFont size:((self.textSize > 0) ? self.textSize : 16)];
	CGSize actualTextRectSize;
    
	//The graphics context where the text is drawn should be set as the actual rendering context and should be unset just after
	//in order for drawInRect method to work properly
	UIGraphicsPushContext(self.graphicContext);
	
	//Reverse the coordinates so that the text is drawn correctly
    CGContextScaleCTM(self.graphicContext, self.textXScaling, -self.textYScaling);
	
	actualTextRectSize = [text drawInRect:textRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:self.textAlignment];
    actualTextRectSize.height *= self.textYScaling;
    
	CGContextScaleCTM(self.graphicContext, 1.0 / self.textXScaling, -1.0/self.textYScaling);
	UIGraphicsPopContext();
    
    self.vPosition += actualTextRectSize.height;
    
    [self checkCircularBuffer];
}


#pragma mark Advanced Text Drawing


//This function draws an attributed string into a bitmap graphics context
//Note that text drawn using CTFramesetterCreateFrame is not reversed. This means that there is no need to scanle the graphics context by a negative factor in the Y direction as in drawText
-(void)drawTextAdvanced:(NSString *)text {
    NSLog(@"%s [Text: %@][Font: %@][xScale: %ld, yScale: %d][Bold: %@]", __FUNCTION__, text, self.textFont, (long)self.textXScaling, self.textYScaling, ((self.textInBold == YES) ? @"YES" : @"NO"));
    
    if (self.graphicContext == NULL) {
        NSLog(@"%s Invalid Graphics Context", __FUNCTION__);
		return;
	}
    
    //Get the text size
    self.textSize = ((self.textSize > 0) ? self.textSize : 16);
    
    int tmpTextSize = self.textSize;
    
    //Simulate the text scaling by increasing the text size
    if (self.textXScaling * self.textYScaling > 1) {
        tmpTextSize *= MAX(self.textXScaling, self.textYScaling);
    }
    
    UIFont * font = [UIFont fontWithName:self.textFont size:tmpTextSize];
    
    //Initialize an attributed string
    NSMutableAttributedString * attributedString = [NSMutableAttributedString mutableAttributedStringWithString:text font:font color:[UIColor blackColor] alignment:[self cocoa2CoreFoundationTextAlignment:self.textAlignment] underline:self.textUnderlining bold:self.textInBold];
    
    //Check if there is already a valid attributed string - This means that the current one will be appended to it
    if (self.lastAttributedString != nil) {
        [self.lastAttributedString appendAttributedString:attributedString];
        
        //Decrease the vertical position
        self.vPosition -= self.lastAttributedStringRect.size.height;
        
        //Clear the rectangle occupied by the previous attributed string
        [self eraseRectangle:self.lastAttributedStringRect];
    } else {
        self.lastAttributedString = [[[NSMutableAttributedString alloc] initWithAttributedString:attributedString] autorelease];
    }
    
    //NSLog(@"%s Attributes String:\n%@", __FUNCTION__, self.lastAttributedString);
    
    //Compute the size of the rectangle occupied by the attributed string
    CGSize actualTextRectSize;
    actualTextRectSize.width    = self.width;
    actualTextRectSize.height   = [self.lastAttributedString boundingHeightForWidth:actualTextRectSize.width];
    
    
    
    //Set the rectangle within which the attributed string will be drawn
    CGRect textRect = {{0, - self.vPosition}, {self.width, self.height}};
    
	//The graphics context where the text is drawn should be set as     the actual rendering context and should be unset just after
	//in order for drawInRect method to work properly
	UIGraphicsPushContext(self.graphicContext);
	
    //Draw the attributed string into the graphics context
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.lastAttributedString);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    NSDictionary* attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:(NSString*)kCTLineBreakByWordWrapping, nil];
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, (CFDictionaryRef)attributesDict);
    
    CTFrameDraw(textFrame, self.graphicContext);
    
    CFRelease(textFrame);
    CGPathRelease(path);
    CFRelease(framesetter);
    
	UIGraphicsPopContext();
    
    self.vPosition += actualTextRectSize.height;
    
    //Save the text frame actual size
    self.lastAttributedStringRect = CGRectMake(textRect.origin.x, self.height - self.vPosition, actualTextRectSize.width, actualTextRectSize.height);
    
    [self checkCircularBuffer];
}


#pragma mark -

-(void)drawBitmapWithImage:(UIImage *)image {
    NSLog(@"%s", __FUNCTION__);
    
    [self invalidateAttributedString];
    
    if (self.graphicContext == NULL) {
        NSLog(@"%s Invalid Graphics Context", __FUNCTION__);
		return;
	}
    
	if (image == nil) {
		NSLog(@"%s Invalid Image", __FUNCTION__);
		return;
	}
    
	//Compute the scaling factor
	CGFloat scaleFactor = 1;
	NSUInteger imageWidth = image.size.width;
	NSUInteger imageHeight = image.size.height;
	if (imageWidth > self.width) {
		scaleFactor = ((CGFloat)self.width) / (CGFloat)imageWidth;
	}
	CGRect canvas = {{0, self.height - self.vPosition - imageHeight}, {imageWidth, imageHeight}};
	CGContextScaleCTM(self.graphicContext, scaleFactor, scaleFactor);
    CGContextDrawImage(self.graphicContext, canvas, image.CGImage);
	CGContextScaleCTM(self.graphicContext, 1 / scaleFactor, 1 / scaleFactor);
    self.vPosition += imageHeight;
    
    [self checkCircularBuffer];
}

-(UIImage *)drawRawMonochromeBitmapWithData:(NSData*)data andRowCount:(NSUInteger)count {
    NSLog(@"%s", __FUNCTION__);
    
    [self invalidateAttributedString];
    
    //Convert Pixel Encoding to 8 bits per pixel
	NSUInteger size = [data length] * 8;
	char * receiptBuffer = (char *)malloc(size);
	char * microlineBuffer = (char *)[data bytes];
	NSUInteger i = 0;
	NSUInteger _width = size / count;
	for (i = 0; i < size; i++) {
		receiptBuffer[i] = (((microlineBuffer[i / 8] & (0x80 >> (i % 8))) == 0x00) ? 0xFF : 0x00);
	}
	
	//Build a UIImage from the bitmap data
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, receiptBuffer, size, NULL);
	CGImageRef cgimage = CGImageCreate(_width, count, 8, 8, _width, self.colorSpace, kCGBitmapByteOrderDefault, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    
    NSData * imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:cgimage], 1.0);
    UIImage * retimage = [[[UIImage imageWithData:[NSData  dataWithData:imageData]] retain] autorelease];
    
    [self drawBitmapWithImage:retimage];
    
	CGImageRelease(cgimage);         
	CGDataProviderRelease(dataProvider);
    free(receiptBuffer);
    return retimage;
}


-(void)clearBitmap {
    NSLog(@"%s", __FUNCTION__);
    memset(self.pixelBuffer, 0xFF, self.pixelBufferSize);
    self.vPosition = 0;
    [self invalidateAttributedString];
}

-(void)skipLine {
    NSLog(@"%s", __FUNCTION__);
    self.vPosition += DEFAULT_LINE_JUMP;
    
    [self invalidateAttributedString];
}

static void releaseBytes(void *info, const void *data, size_t size) {
	free((void*)data);
}

-(UIImage *)getImage {
    NSLog(@"%s", __FUNCTION__);
    UIImage * result = nil;
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, self.pixelBuffer, self.width * self.colors * self.bitsPerColor * self.vPosition / 8, NULL);
    CGImageRef imageRef = CGImageCreate(self.width, self.vPosition, self.bitsPerColor, self.bitsPerColor * self.colors, self.width * self.bitsPerColor * self.colors / 8, self.colorSpace, self.bitmapInfo, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    result = [UIImage imageWithCGImage:imageRef];
    CGDataProviderRelease(dataProvider);
    CGImageRelease(imageRef);
    
    return result;
}

-(UIImage *)getWholeImage {
    NSLog(@"%s", __FUNCTION__);
    UIImage * result = nil;
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, self.pixelBuffer, self.width * self.colors * self.bitsPerColor * self.height / 8, NULL);
    CGImageRef imageRef = CGImageCreate(self.width, self.height, self.bitsPerColor, self.bitsPerColor * self.colors, self.width * self.bitsPerColor * self.colors / 8, self.colorSpace, self.bitmapInfo, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    result = [UIImage imageWithCGImage:imageRef];
    CGDataProviderRelease(dataProvider);
    CGImageRelease(imageRef);
    
    return result;
}


#pragma mark PDF Conversion

-(NSData *)image2PDF:(UIImage *)image {
    NSLog(@"%s", __FUNCTION__);
    
    //PDF Context
    NSMutableData * pdf = [NSMutableData data];
    CGContextRef pdfContext = NULL;
    CFMutableDictionaryRef pdfProperties = NULL;
    CGRect pdfCanvas = {{0, 0}, {image.size.width, image.size.height}};
    
    //PDF Properties
    pdfProperties = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionarySetValue(pdfProperties, kCGPDFContextTitle, (CFStringRef)@"Printed Document");
	CFDictionarySetValue(pdfProperties, kCGPDFContextCreator, (CFStringRef)@"InteractivePayment");
    
    //PDF Content
    CGDataConsumerRef pdfDataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdf);
	pdfContext = CGPDFContextCreate(pdfDataConsumer, &pdfCanvas, pdfProperties);
	CFRelease(pdfProperties);
    CGContextBeginPage(pdfContext, &pdfCanvas);
    CGContextDrawImage(pdfContext, pdfCanvas, image.CGImage);
    CGContextEndPage(pdfContext);
    CGDataConsumerRelease(pdfDataConsumer);
    
    return pdf;
}

#pragma mark -

@end
