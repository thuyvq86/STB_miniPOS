//
//  ICBitmapReceipt.h
//  InteractivePayment
//
//  Created by Hichem Boussetta on 01/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>



@interface ICBitmapReceipt : NSObject


@property (nonatomic, copy)     NSString *      textFont;
@property (nonatomic, assign)   NSUInteger      textSize;
@property (nonatomic, assign)   NSUInteger      textAlignment;
@property (nonatomic, assign)   NSUInteger      characterSpacing;
@property (nonatomic, assign)   NSInteger       textXScaling;
@property (nonatomic, assign)   NSInteger       textYScaling;
@property (nonatomic, assign)   BOOL            textUnderlining;
@property (nonatomic, assign)   BOOL            textInBold;


+(ICBitmapReceipt *)sharedBitmapReceipt;

-(void)drawText:(NSString *)text;
-(void)drawTextAdvanced:(NSString *)text;
-(void)drawBitmapWithImage:(UIImage *)image;
-(UIImage *)drawRawMonochromeBitmapWithData:(NSData*)data andRowCount:(NSUInteger)count;
-(void)clearBitmap;
-(void)skipLine;
-(UIImage *)getImage;
-(UIImage *)getWholeImage;
-(NSData *)image2PDF:(UIImage *)image;

@end
