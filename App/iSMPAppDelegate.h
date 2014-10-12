//
//  iSMPTestSuiteAppDelegate.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 17/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define UIAppDelegate ((iSMPAppDelegate *)[[UIApplication sharedApplication] delegate])

@interface iSMPAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
//bluetooth
@property (nonatomic, retain) CBCentralManager *bluetoothManager;
@property (nonatomic) BOOL bluetoothEnabled;

@end

