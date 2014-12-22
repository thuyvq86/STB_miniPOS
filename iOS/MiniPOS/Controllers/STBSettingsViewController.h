//
//  STBSettingsViewController.h
//  MiniPOS
//
//  Created by Nam Nguyen on 12/10/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBBaseViewController.h"

@class STBSettingsViewController;

@protocol SettingsViewDelegate <NSObject>
@optional
- (void)settingsViewControllerDidFinish:(STBSettingsViewController *)settingsViewController;

@end

@interface STBSettingsViewController : STBBaseViewController{
    __weak IBOutlet UITableView *_tableView;
}
@property (nonatomic, unsafe_unretained) id<SettingsViewDelegate> delegate;
@property (nonatomic, strong) EAAccessory *pairedDevice;

@end
