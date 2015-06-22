//
//  STBMessagingViewController.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBBaseViewController.h"
#import "ICMPProfile.h"

@interface STBMessagingViewController : STBBaseViewController<ICISMPDeviceDelegate, StandAlonePaymentDelegate, ISMPControlManagerDelegate>{
    
    __weak IBOutlet UINavigationBar *_navigationBar;
    __weak IBOutlet UINavigationItem *_navItem;
    
    __weak IBOutlet UILabel *_lbliSpmConnectionState;
    
    __weak IBOutlet TPKeyboardAvoidingTableView *_tableView;
}
@property (nonatomic, assign) iSMPControlManager *iSMPControl;
@property (nonatomic, assign) StandalonePaymentManager*paymentManager;
@property (nonatomic, strong) ICMPProfile *profile;

@end
