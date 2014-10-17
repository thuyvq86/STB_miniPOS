//
//  SignatureContentView.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/17/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "SignatureContentView.h"

@interface SignatureContentView()

@property (nonatomic, strong) UIImageView *signatureImageView;

@end

@implementation SignatureContentView

#define kSignatureSize CGSizeMake(50.0f, 50.0f)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    id<ApplicationThemeDelegate> currentTheme = [ApplicationThemeManager sharedTheme];
    
    if ([self.layer respondsToSelector:@selector(setDrawsAsynchronously:)])
        [self.layer setDrawsAsynchronously:YES];
    
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    UIFont *textFont = [theme fontForHeader]; //normal
    
    CGFloat width    = CGRectGetWidth(rect) - 2*kLeftPadding;
//    CGFloat height   = CGRectGetHeight(rect);
    NSInteger offset = kTopPadding;
    
    //text color
    [[currentTheme mainColor] set];
    
    [@"SIGN X ------------------" drawInRect:CGRectMake(kLeftPadding, offset, width, kTitleHeight) withFont:textFont lineBreakMode:NSLineBreakByTruncatingTail];
    offset += kTitleHeight;
    
    if (_posMessage.signature) {
        offset += kLinePadding/2.0;
        
        _signatureImageView.frame = CGRectSetPosY(_signatureImageView.frame, offset);
        offset += CGRectGetHeight(_signatureImageView.frame) + kLinePadding;
    }
    else
        offset += kLinePadding;
    
    //Card name
    NSString *cardName = _posMessage.cardName;
    [cardName drawInRect:CGRectMake(kLeftPadding, offset, width, kTitleHeight) withFont:textFont lineBreakMode:NSLineBreakByTruncatingTail];
    offset += kTitleHeight + kLinePadding/2.0;
}

+ (CGFloat)heightForPosMessage:(PosMessage*)aPosMessage parentWidth:(CGFloat)parentWidth{
    CGFloat height = 0;
    
    height += kTopPadding;

    //title
    height += kTitleHeight;
    
    //signature
    if (aPosMessage.signature){
        height += kLinePadding/2.0;
        CGSize signatureSize = [self sizeOfSignature:aPosMessage.signature];
        height += signatureSize.height + kLinePadding;
    }
    else
        height += kLinePadding;
    
    //card name
    height += kTitleHeight + kLinePadding;
    
    return height;
}

- (void)setPosMessage:(PosMessage *)posMessage{
    _posMessage = posMessage;
    
    [self renderViews];
    [self setNeedsDisplay];
}

- (void)renderViews{
    UIImage *image       = _posMessage.signature;
    CGSize signatureSize = [[self class] sizeOfSignature:image];
    CGRect frame         = CGRectMake(kLeftPadding, 0, signatureSize.width, signatureSize.height);
    
    if (!_signatureImageView) {
        self.signatureImageView = [[UIImageView alloc] initWithFrame:frame];
        [_signatureImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_signatureImageView];
    }
    _signatureImageView.frame = frame;
    _signatureImageView.image = image;
}

#pragma mark - Helpers

+ (CGSize)sizeOfSignature:(UIImage *)image{
    if (!image) return CGSizeZero;
        
    CGSize imageSize = image.size;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize signatureSize = kSignatureSize; //default
    
    CGFloat actualWidth  = imageSize.width / screenScale;
    CGFloat actualHeight = imageSize.height/ screenScale;
    
    CGSize actualSize = CGSizeMake(actualWidth, actualHeight);
    if (actualSize.width > 0 && actualSize.height > 0){
        CGFloat scale = kSignatureSize.width / actualWidth;
        signatureSize = CGSizeMake(ceilf(actualWidth * scale), ceilf(actualHeight * scale));
    }
    
    return signatureSize;
}


@end
