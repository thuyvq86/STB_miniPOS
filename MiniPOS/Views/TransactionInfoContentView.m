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
    NSString *title = @"Sacombank";
    [title drawInRect:CGRectMake(kLeftPadding, offset, width, kTitleHeight) withFont:titleFont lineBreakMode:NSLineBreakByTruncatingTail];
    offset += kTitleHeight;
    
    //links
//    float widthOfText = width - (iconPdf.size.width + kLinePadding/2);
//    float heightOfText = 0;
//    int index = -1;
//    for (MediaData *obj in _pdfs) {
//        index++;
//        
//        //icon
//        [iconPdf drawInRect:CGRectMake(kLeftPadding, offset, iconPdf.size.width, iconPdf.size.height)];
//        
//        //text
//        NSString *text = [[self class] textForMedia:obj];
//        heightOfText = [[self class] heightForDetailText:text width:widthOfText font:textFont];
//        
//        UILabel *label = [self linkLabelWithFrame:CGRectMake(kLeftPadding + iconPdf.size.width + kLinePadding/2, offset, widthOfText, heightOfText)];
//        [self addSubview:label];
//        [label setText:text];
//        [label setTag:index];
//        
//        //increase offset
//        offset += MAX(iconPdf.size.height, heightOfText);
//    }
}

+ (CGFloat)heightForPosMessage:(PosMessage*)aPosMessage parentWidth:(CGFloat)parentWidth{
    CGFloat width = parentWidth - 2*kLeftPadding;
    
    return kTableCellHeight;
}

- (void)setPosMessage:(PosMessage *)posMessage{
    if (_posMessage != posMessage) {
        _posMessage = posMessage;
        
        [self setNeedsDisplay];
    }
}

@end
