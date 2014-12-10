//
//  TransactionInfoContentView.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/17/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "TransactionInfoContentView.h"

@interface TransactionInfoContentView()

@property (nonatomic, strong) NSArray *billInfoArray;

@end

@implementation TransactionInfoContentView

@synthesize posMessage = _posMessage;

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
    if ([self.layer respondsToSelector:@selector(setDrawsAsynchronously:)])
        [self.layer setDrawsAsynchronously:YES];
    
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    UIFont *boldFont   = [theme mediumBoldFontForHeader]; //bold
    UIFont *normalFont = [theme mediumFontForContent]; //normal
    UIImage *lineImage = [theme separatorLine];
    
    CGFloat width    = CGRectGetWidth(rect) - 2*kLeftPadding;
    NSInteger offset = kTopPadding;
    
    NSString *transactionType = [_posMessage.transactionType uppercaseString];
    NSArray *properties = _posMessage.displayableProperties;
    
    //text color
    [[UIColor whiteColor] set];
    
    //Transaction Type
    [transactionType drawInRect:CGRectMake(kLeftPadding, offset, width, kTitleHeight) withFont:boldFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
    offset += kTitleHeight + kLinePadding;
    
    //draw separator line
    [lineImage drawInRect:CGRectMake(kLeftPadding, offset, width, lineImage.size.height)];
    offset += lineImage.size.height + kLinePadding;
    
    //Draw info
    if (properties && [properties count] > 0){
        UIFont *textFont = nil;
        for (NSArray *obj in properties) {
            TextType type = [obj[0] intValue];
            textFont = (type == TextTypeBold) ? boldFont : normalFont;
            
            //texts
            [obj[1] drawInRect:CGRectMake(kLeftPadding, offset, width, kTitleHeight) withFont:textFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
            [obj[2] drawInRect:CGRectMake(kLeftPadding, offset, width, kTitleHeight) withFont:textFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentRight];
            
            //increase offset
            offset += kTitleHeight;
        }
        
        offset += kLinePadding;
    }
}

+ (CGFloat)heightForPosMessage:(PosMessage*)aPosMessage parentWidth:(CGFloat)parentWidth{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    
    NSInteger height = 0;
    
    UIImage *lineImage = [theme separatorLine];
    NSArray *properties = aPosMessage.displayableProperties;
    
    height += kTopPadding;
    height += kTitleHeight + kLinePadding;
    height += lineImage.size.height + kLinePadding; //separator line
    
    if (properties && [properties count] > 0) {
        height += kTitleHeight * [properties count];
        height += kLinePadding;
    }
    
    return height;
}

- (void)setPosMessage:(PosMessage *)posMessage{
    if (_posMessage != posMessage) {
        _posMessage = posMessage;
        
        [self setNeedsDisplay];
    }
}

@end
