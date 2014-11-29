//
//  TransactionInfoContentView.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/17/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "BaseTableContentView.h"

@interface TransactionInfoContentView : BaseTableContentView

@property (nonatomic, strong) PosMessage *posMessage;

+ (CGFloat)heightForPosMessage:(PosMessage*)aPosMessage parentWidth:(CGFloat)parentWidth;

@end
