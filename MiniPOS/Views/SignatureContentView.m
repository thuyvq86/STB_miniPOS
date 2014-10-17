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
    
    UIFont *titleFont   = [[self class] detailHeaderFont];
//    UIFont *contentFont = [[self class] detailContentFont];
    
    CGFloat width    = CGRectGetWidth(rect) - 2*kLeftPadding;
//    CGFloat height   = CGRectGetHeight(rect);
    NSInteger offset = kLinePadding;
    
    //text color
    [[currentTheme mainColor] set];
    
    //Title
    NSString *title = _posMessage.cardName;
    [title drawInRect:CGRectMake(kLeftPadding, offset, width, kTitleHeight) withFont:titleFont lineBreakMode:NSLineBreakByTruncatingTail];
    offset += kTitleHeight + kLinePadding/2.0;
    
    if (!_posMessage.signature) {
        [@"Signature: -----------" drawInRect:CGRectMake(kLeftPadding, offset, width, kTitleHeight) withFont:titleFont lineBreakMode:NSLineBreakByTruncatingTail];
    }
    else{
        _signatureImageView.frame = CGRectSetPosY(_signatureImageView.frame, offset);
    }
}

#define kSignatureSize 50.0f

+ (CGFloat)heightForPosMessage:(PosMessage*)aPosMessage parentWidth:(CGFloat)parentWidth{
    //CGFloat width = parentWidth - 2*kLeftPadding;
    CGFloat height = kLinePadding;
    
    height += kTitleHeight + kLinePadding/2.0; //card name
    height += kSignatureSize;
    height += kLinePadding;
    
    return height;
}

- (void)setPosMessage:(PosMessage *)posMessage{
    _posMessage = posMessage;
    
    [self renderView];
    [self setNeedsDisplay];
}

- (void)renderView{
    CGRect frame = CGRectMake(kLeftPadding, 0, kSignatureSize, kSignatureSize);
    if (!_signatureImageView) {
        self.signatureImageView = [[UIImageView alloc] initWithFrame:frame];
        [_signatureImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_signatureImageView];
    }
    _signatureImageView.image = _posMessage.signature;
    //_signatureImageView.backgroundColor = [UIColor redColor];
}

@end
