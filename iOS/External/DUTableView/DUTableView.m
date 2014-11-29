//
//  DUTableView.m
//  AutoScout24
//
//  Created by Nguyen Thi Nam on 1/23/13.
//  Copyright (c) 2013 AutoScout24. All rights reserved.
//

#import "DUTableView.h"

@implementation DUTableView

- (void)reloadDataWithCompletion:( void (^) (void) )completionBlock {
    [super reloadData];
    if(completionBlock) {
        completionBlock();
    }
}

@end
