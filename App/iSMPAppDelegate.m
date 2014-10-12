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
    
    [self detectBluetooth];
    
    BOOL reachable = [AppUtils hasConnectivity];
    if (!reachable){
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"Device is not connected to the internet." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
		[alert show];
        
        return NO;
    }
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    //[window addSubview:navigationController.view];
    window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
	
	//NSString *logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"console.log"];
	//freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
	
	NSString *logFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"iSMPLog.txt"];
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

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    DLog();
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
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
    /*
    NSString *stateString = nil;
    switch([central state])
    {
        case CBCentralManagerStateResetting:
            stateString = @"The connection with the system service was momentarily lost, update imminent.";
            break;
        case CBCentralManagerStateUnsupported:
            stateString = @"The platform doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            stateString = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            stateString = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            stateString = @"Bluetooth is currently powered on and available to use.";
            break;
        default:
            stateString = @"State unknown, update imminent.";
            break;
    }
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Bluetooth state"
                                                     message:stateString
                                                    delegate:nil
                                           cancelButtonTitle:@"Okay"
                                           otherButtonTitles:nil, nil] autorelease];
    [alert show];
    DLog(@"%@", stateString);
    */
    
    if ([central state] == CBCentralManagerStatePoweredOn) {
        self.bluetoothEnabled = YES;
    }
    else {
        self.bluetoothEnabled = NO;
    }
}

@end
