//
//  SignatureCell.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/17/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "SignatureCell.h"
#import "SignatureContentView.h"

@interface SignatureCell()

@property (nonatomic, strong) SignatureContentView *signatureContentView;

@end

@implementation SignatureCell

@synthesize posMessage = _posMessage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle  = UITableViewCellSelectionStyleNone;
        
        CGRect frame = CGRectMake(0, CGRectGetMinY(self.contentView.frame), CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        self.signatureContentView = [[SignatureContentView alloc] initWithFrame:frame];
        [self.contentView addSubview:_signatureContentView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForPosMessage:(PosMessage*)aPosMessage parentWidth:(CGFloat)parentWidth{
    CGFloat width = parentWidth;
    return [SignatureContentView heightForPosMessage:aPosMessage parentWidth:width];
}

- (void)setPosMessage:(PosMessage *)posMessage{
    _posMessage = posMessage;
    
    [_signatureContentView setPosMessage:_posMessage];
}

@end
