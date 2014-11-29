//
//  AppInfoController.h
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AppInfoDelegate <NSObject>
@optional
- (void)didFinishAppInfoController:(id)appInfoController;

@end

@interface AppInfoController : STBBaseViewController{
    __weak IBOutlet UINavigationBar *_navBar;
    __weak IBOutlet UIBarButtonItem *_barButtonItemDone;
    
}

@property (nonatomic, retain) IBOutlet UILabel          * appVersion;
@property (nonatomic, retain) IBOutlet UILabel          * libiSMPVersion;

@property (nonatomic, unsafe_unretained) id<AppInfoDelegate> delegate;

- (IBAction)done:(id)sender;

@end
