//
//  SignatureContentView.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/17/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "SignatureContentView.h"

@interface SignatureContentView()

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
    UIFont *contentFont = [[self class] detailContentFont];
    
    CGFloat width    = CGRectGetWidth(rect) - 2*kLeftPadding;
    CGFloat height   = CGRectGetHeight(rect);
    NSInteger offset = INTERFACE_IS_IPAD ? (kLinePadding + kLinePadding/2) : kTopPadding;
    
    //text color
    [[currentTheme mainColor] set];
    
    //Title
    NSString *title = _posMessage.cardName;
    [title drawInRect:CGRectMake(kLeftPadding, offset, width, kTitleHeight) withFont:titleFont lineBreakMode:NSLineBreakByTruncatingTail];
    offset += kTitleHeight;
}

+ (CGFloat)heightForPosMessage:(PosMessage*)aPosMessage parentWidth:(CGFloat)parentWidth{
    CGFloat width = parentWidth - 2*kLeftPadding;
    
    return kTableCellHeight;
}

- (void)setPosMessage:(PosMessage *)posMessage{
    _posMessage = posMessage;
    
    [self setNeedsDisplay];
}

@end
