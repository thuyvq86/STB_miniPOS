//
//  STBAppDelegate.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define UIAppDelegate ((STBAppDelegate *)[[UIApplication sharedApplication] delegate])

@interface STBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) STBBaseViewController *centerViewController;
//bluetooth
@property (nonatomic, retain) CBCentralManager *bluetoothManager;
@property (nonatomic) BOOL bluetoothEnabled;

@end
