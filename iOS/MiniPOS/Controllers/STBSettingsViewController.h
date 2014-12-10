//
//  STBSettingsViewController.h
//  MiniPOS
//
//  Created by Nam Nguyen on 12/10/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBBaseViewController.h"

@interface STBSettingsViewController : STBBaseViewController{
    
    __weak IBOutlet UINavigationBar *_navigationBar;
    __weak IBOutlet UINavigationItem *_navItem;
    __weak IBOutlet UITableView *_tableView;
}
@property (nonatomic, strong) EAAccessory *pairedDevice;

@end
