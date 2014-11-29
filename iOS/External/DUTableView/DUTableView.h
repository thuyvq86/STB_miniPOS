//
//  DUTableView.h
//  AutoScout24
//
//  Created by Nguyen Thi Nam on 1/23/13.
//  Copyright (c) 2013 AutoScout24. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DUTableView : UITableView
- (void)reloadDataWithCompletion:( void (^) (void) )completionBlock;
@end
