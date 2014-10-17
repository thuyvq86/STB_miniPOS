//
//  STBMessagingViewController.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBBaseViewController.h"

@interface STBMessagingViewController : STBBaseViewController{
    
    __weak IBOutlet UINavigationBar *_navigationBar;
    __weak IBOutlet UINavigationItem *_navItem;
    
    __weak IBOutlet UILabel *_lbliSpmConnectionState;
    
    __weak IBOutlet TPKeyboardAvoidingTableView *_tableView;
}

@end
