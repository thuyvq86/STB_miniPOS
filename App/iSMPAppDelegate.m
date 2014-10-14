//
//  iSMPTestSuiteAppDelegate.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 17/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "iSMPAppDelegate.h"
#import "AppUtils.h"

@interface iSMPAppDelegate()<CBCentralManagerDelegate>

@end

@implementation iSMPAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize bluetoothEnabled = _bluetoothEnabled;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Set app-wide shared cache
    [self configureCacheLimits];

    //check blutooth
    [self detectBluetooth];
    
    BOOL reachable = [AppUtils hasConnectivity];
    if (!reachable){
        [UIAlertView alertViewWithTitle:@"" message:@"Device is not connected to the internet." cancelButtonTitle:@"Close"];
        
        return NO;
    }
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    //[window addSubview:navigationController.view];
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    [self.window setFrame:[[UIScreen mainScreen] bounds]];
	
	//NSString *logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"console.log"];
	//freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
	
	NSString *logFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"iSMPLog.txt"];
    NSLog(@"logFilePath:\n%@", logFilePath);
	if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
		[[NSFileManager defaultManager] removeItemAtPath:logFilePath error:NULL];
	}
    
    //Enable Crash Reporting
    //[CrashReporterManager sharedCrashReporterManager];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
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
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
#if defined(AUTO) || defined(MOTO)
    //Integrate FB SDK to promote apps on FB
    [FBSession.activeSession handleDidBecomeActive];
    [FBAppEvents activateApp];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification object:nil];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    //purge the shared cache to free up memory.
    [self freeUpMemory];
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}

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
        self.bluetoothManager = [[[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()] autorelease];
    }
//    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
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

@end
