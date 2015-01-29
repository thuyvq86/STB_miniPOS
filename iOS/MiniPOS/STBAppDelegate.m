//
//  STBAppDelegate.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBAppDelegate.h"
#import "STBCenterViewController.h"
#import "AFNetworkActivityLogger.h"
#import "PairedDevice.h"

@interface STBAppDelegate()<CBCentralManagerDelegate>

@end

@implementation STBAppDelegate

@synthesize centerViewController = _centerViewController;
@synthesize apiClient = _apiClient;

#pragma mark - App lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //log request/response
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    
    // Start monitoring the internet connection
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //Setup the ApiClient and the Core Data Stack
    id apiClient = nil;
    apiClient = self.apiClient;
    
    //Set app-wide shared cache
    [self configureCacheLimits];
    
//    //check blutooth
//    [self detectBluetooth];
//    
//    BOOL reachable = [AppUtils hasConnectivity];
//    if (!reachable){
//        [UIAlertView alertViewWithTitle:@"" message:@"Device is not connected to the internet." cancelButtonTitle:@"Close"];
//        
//        return NO;
//    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIView *statusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 20)];
        statusBarBackgroundView.backgroundColor = [UIColor blackColor];
        statusBarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
        
        [self.window addSubview:statusBarBackgroundView];
    }
    
    //Initialize iSMP services
    [GateWayManager sharedGateWayManager];
    [iSMPControlManager sharedISMPControlManager];
    [PrinterManager sharedPrinterManager];
    [SettingsManager sharedSettingsManager];
    
    //Initialize Crash Reporter
    [CrashReporterManager sharedCrashReporterManager];
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (self.apiClient && [ICISMPDevice isAvailable]) {
        //save paired device
        if ([ICISMPDevice isAvailable])
            [self insertOrUpdatePairedDevice];
    }
    
    //Open/Close the communication channel when entering/leaving sleep mode
    [[iSMPControlManager sharedISMPControlManager] start];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification object:nil];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    //purge the shared cache to free up memory.
    [self freeUpMemory];
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

#pragma mark - Setup API client

- (STBAPIClient*)apiClient {
    if(!_apiClient) {
        _apiClient = [STBAPIClient sharedClient];
    }
    
    return _apiClient;
}

#pragma mark - Memory management

/**
 *  Set app-wide shared cache (first number is megabyte value)
 *  Refs: http://twobitlabs.com/2012/01/ios-ipad-iphone-nsurlcache-uiwebview-memory-utilization/
 *
 */
- (void)configureCacheLimits{
    int cacheSizeMemory = 4*1024*1024;  // 4MB
    int cacheSizeDisk   = 32*1024*1024; // 32MB
    NSString *diskPath = nil; //@"nsurlcache"
    
    //Initializes an NSURLCache with the given capacity and path.
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:diskPath];
    [NSURLCache setSharedURLCache:sharedCache];
}

/**
 *  Clears the given cache
 */
- (void)freeUpMemory{
    //removing all NSCachedURLResponse objects that it stores.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Bluetooth

- (void)detectBluetooth
{
    if(!self.bluetoothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    //[self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
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

#pragma mark - Save paired device

- (void)insertOrUpdatePairedDevice{
    PairedDevice *deviceInfo = [PairedDevice getBySerialNumber:[ICISMPDevice serialNumber]];
    if (!deviceInfo){
        deviceInfo = [[PairedDevice alloc] init];
    }
    deviceInfo.serialNumber = [ICISMPDevice serialNumber];
    deviceInfo.name = [ICISMPDevice name];
    deviceInfo.desc = [NSString stringWithFormat:
                       @"Name: %@\nModel Number: %@\nSerial Id: %@\nFirmware Reveision: %@\nHardware Revision: %@",
                       [ICISMPDevice name],
                       [ICISMPDevice modelNumber],
                       [ICISMPDevice serialNumber],
                       [ICISMPDevice firmwareRevision],
                       [ICISMPDevice hardwareRevision]
                       ];
    deviceInfo.lastModifiedDate = [NSDate date];
    
    [deviceInfo insertOrUpdate];
}

- (void)insertOrUpdateTestDevice:(NSString *)name serialNumber:(NSString *)serialNumber{
    PairedDevice *deviceInfo = [PairedDevice getBySerialNumber:serialNumber];
    if (!deviceInfo){
        deviceInfo = [[PairedDevice alloc] init];
    }
    deviceInfo.serialNumber = serialNumber;
    deviceInfo.name = name;
    deviceInfo.desc = [NSString stringWithFormat:
                       @"Name: %@\nModel Number: %@\nSerial Id: %@\nFirmware Reveision: %@\nHardware Revision: %@",
                       name,
                       nil,
                       serialNumber,
                       nil,
                       nil
                       ];
    deviceInfo.lastModifiedDate = [NSDate date];
    
    [deviceInfo insertOrUpdate];
}

@end
