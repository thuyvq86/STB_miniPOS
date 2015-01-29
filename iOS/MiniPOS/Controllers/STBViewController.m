//
//  STBViewController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBViewController.h"
#import "STBCenterViewController.h"

@interface STBViewController ()<CBCentralManagerDelegate>

//bluetooth
@property (nonatomic, retain) CBCentralManager *bluetoothManager;
@property (nonatomic) BOOL bluetoothEnabled;

//main view
@property (strong, nonatomic) STBCenterViewController *centerViewController;

@end

@implementation STBViewController

#pragma mark - Bluetooth

- (void)detectBluetooth
{
    if(!self.bluetoothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([central state] == CBCentralManagerStatePoweredOn) {
        self.bluetoothEnabled = YES;
    }
    else {
        self.bluetoothEnabled = NO;
    }
}

#pragma mark - Bluetooth check

- (BOOL)isBluetoothPoweredOn{
    CBCentralManagerState state = [_bluetoothManager state];
//    if (state == CBCentralManagerStatePoweredOn)
//        return YES;
    
    NSString *message = nil;
    switch(state)
    {
        case CBCentralManagerStateResetting:
            message = @"The connection with the system service was momentarily lost, update imminent.";
            break;
        case CBCentralManagerStateUnsupported:
            message = @"The platform doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            message = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            message = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            message = @"Bluetooth is currently powered on and available to use.";
            break;
        default:
            //            message = @"State unknown, update imminent.";
            break;
    }
    
    DLog(@"Bluetooth state: %@", message);
    
//    if (message)
//        [UIAlertView alertViewWithTitle:@"Bluetooth state" message:message cancelButtonTitle:@"OK"];
    
    if (state == CBCentralManagerStatePoweredOn)
        return YES;
    
    return NO;
}

- (void)checkBluetoothAndNetWork{
    BOOL isBluetoothPoweredOn = [self isBluetoothPoweredOn];
    BOOL reachable = [AppUtils hasConnectivity];
    
    NSString *message = nil;
    if (!isBluetoothPoweredOn && !reachable) {
        message = @"Please enable Bluetooth and Wrireless to continue.";
    }
    else if (!isBluetoothPoweredOn){
        message = @"Please enable Bluetooth to continue.";
    }
    else if (!reachable){
        message = @"Please enable Wrireless to continue.";
    }
    else{
        //check app update
        [self checkAppUpdate];
    }
    
    if (message)
        [UIAlertView alertViewWithTitle:@"System Message" message:message cancelButtonTitle:@"OK"];
}

- (void)checkAppUpdate{
    [_lblLoadingMessage setText:@"Checking application version..."];
    STBAPIClient *apiClient = [STBAPIClient sharedClient];
    
    [apiClient getAppVersionWithCompletionBlock:^(id responseObject, NSError *error) {
        if (error) {
            DLog(@"%@", error);
        }
        else{
            DLog(@"responseObject: %@", responseObject);
            
            [_lblLoadingMessage setText:@"Done!"];
            [self addCenterView];
        }
    }];
}

- (void)appActive:(NSNotification *)notification{
    [self checkBluetoothAndNetWork];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //check blutooth
    [self detectBluetooth];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self updateFrameOfView];
    
    [_activityIndicatorView startAnimating];
    [_lblLoadingMessage setText:@"Checking Bluetooth and Wrireless..."];
    [self performSelector:@selector(checkBluetoothAndNetWork) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCenterView{
    if (_centerViewController && [_centerViewController.view superview])
        return;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    UIStoryboard *dashboardStoryBoard = [UIStoryboard storyboardWithName:@"MessagingStoryboard" bundle:nil];
    self.centerViewController = [dashboardStoryBoard instantiateViewControllerWithIdentifier:@"CenterViewController"];
    _centerViewController.view.frame = frame;
    
    STBNavigationController *navController = [[STBNavigationController alloc] initWithRootViewController:_centerViewController];
    navController.navigationBarHidden = YES;
    
    [self addChildViewController:navController];
    [self.view addSubview:navController.view];
}

@end
