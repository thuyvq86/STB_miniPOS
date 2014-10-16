//
//  STBCenterViewController.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBBaseViewController.h"
#import <iSMP/revision.h>

@interface STBCenterViewController : STBBaseViewController{
    
    __weak IBOutlet UIImageView *_topbarImageView;
    __weak IBOutlet UIImageView *_logoImageView;
    
    __weak IBOutlet UILabel *_lblTitle;
    
    __weak IBOutlet UITableView *_tableView;
}

@end
