//
//  MessagingViewController.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/14/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagingViewController : iSMPBaseViewController{
    //Views
    IBOutlet UILabel *_lbliSpmConnectionState;
    IBOutlet UITableView *_tableView;
    
    //
    ICAdministration *_configurationChannel;
}

@property (nonatomic, retain) ICAdministration *configurationChannel;

@end
