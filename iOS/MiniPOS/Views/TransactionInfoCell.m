//
//  TransactionInfoCell.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/17/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "TransactionInfoCell.h"
#import "TransactionInfoContentView.h"

@interface TransactionInfoCell()

@property (nonatomic, strong) TransactionInfoContentView *transactionInfoContentView;

@end

@implementation TransactionInfoCell

@synthesize posMessage = _posMessage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect frame = CGRectMake(0, CGRectGetMinY(self.contentView.frame), CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        self.transactionInfoContentView = [[TransactionInfoContentView alloc] initWithFrame:frame];
        [self.contentView addSubview:_transactionInfoContentView];
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
    return [TransactionInfoContentView heightForPosMessage:aPosMessage parentWidth:width];
}

- (void)setPosMessage:(PosMessage *)posMessage{
    _posMessage = posMessage;
    
    [_transactionInfoContentView setPosMessage:_posMessage];
}

@end
