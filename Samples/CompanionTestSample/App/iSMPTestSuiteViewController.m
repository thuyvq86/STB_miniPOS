//
//  iSMPTestSuiteViewController.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 17/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "iSMPTestSuiteViewController.h"
#import "TestTableViewController.h"
#import "../GeneratedFiles/version.h"
#import "ConfigurationViewController.h"

#define kTimerRefreshPeriod 30

extern const double iSMPTestSuiteVersionNumber;

@implementation iSMPTestSuiteViewController
@synthesize testGroups, labelApiVersion, labelApplicationBuildTime, labelAppVersion;
@synthesize batteryLogStream;


-(void)monitorBatteryHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	float iPhoneBatteryLevel = [[UIDevice currentDevice] batteryLevel] * 100;
	NSInteger acLine = -1;
	if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
		acLine = 0;
	} else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnknown) {
		acLine = -1;
	} else {
		acLine = 1;
	}
	ICAdministration * control = [[ICAdministration sharedChannel] retain];
	NSInteger iSpmBatteryLevel = control.batteryLevel;
	[control release];
	NSString * time = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
	NSString * str = [NSString stringWithFormat:@"%@;%f;%d;%d\r\n", time, iPhoneBatteryLevel, iSpmBatteryLevel, acLine];
	[self.batteryLogStream write:(uint8_t *)[str UTF8String] maxLength:[str length]];
	[pool release];
}

- (void)monitorBattery {
	//[self performSelectorInBackground:@selector(monitorBatteryHelper) withObject:nil];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Companion Test Sample";
	labelApiVersion.text = [NSString stringWithFormat:@"iSMP Library Version: %@", [ICISMPVersion substringFromIndex:6]];
	labelAppVersion.text = [NSString stringWithFormat:@"Application Version: %@", currentVersion];
	self.testGroups  = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestGroups" ofType:@"plist"]];
	
	//Start Battery Monitoring
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
	
	//Start iPhone & iSMP Battery Logging
	[NSTimer scheduledTimerWithTimeInterval:kTimerRefreshPeriod target:self selector:@selector(monitorBattery) userInfo:nil repeats:YES];
	
	//Initialize the battery Log stream
	NSString * logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"battery.log"];
	[[NSFileManager defaultManager] removeItemAtPath:logPath error:NULL];
	self.batteryLogStream = [NSOutputStream outputStreamToFileAtPath:logPath append:YES];
	[self.batteryLogStream open];
	NSString * header = @"Time;iPOD Battery Level;iSMP Battery Level;ACLineStatus\r\n";
	[self.batteryLogStream write:(uint8_t *)[header UTF8String] maxLength:[header length]];
	[self monitorBattery];
	
    [super viewDidLoad];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	[self.batteryLogStream close];
	self.batteryLogStream = nil;
}


- (void)dealloc {
	[testGroups release];
	
	//Stop Battery Monitoring
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
	
    [super dealloc];
}


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [testGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	cell.textLabel.text = [[testGroups allKeys] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark -



#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIViewController * viewController = [[[TestTableViewController alloc] init] autorelease];
	((TestTableViewController *)viewController).testGroup = [[testGroups allValues] objectAtIndex:indexPath.row];
	[((TestTableViewController *)viewController) setTitle:[[testGroups allKeys] objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -


-(IBAction)iSpmInformation {
	if ([ICISMPDevice isAvailable] == NO) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"No detected accessory !!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
		[alert show];
		return;
	}
	EAAccessory * connectedAccessory = nil;
	NSMutableArray * protocolStrings = [[NSMutableArray alloc] init];
	for (EAAccessory *obj in [[EAAccessoryManager sharedAccessoryManager] connectedAccessories]) {
		[protocolStrings addObjectsFromArray:[obj protocolStrings]];
		connectedAccessory = obj;
		break;
	}
	NSMutableString * strProtocolNames = [[[NSMutableString alloc] init] autorelease];
	for (NSString *proto in protocolStrings) {
		[strProtocolNames appendFormat:@"%@\n", proto];
	}
	[protocolStrings release];
	NSString * msg = [NSString stringWithFormat:
					  @"connected: %d\nconnectionID: %d\nname: %@\nmanufacturer: %@\nmodelNumber: %@\nserialNumber: %@\nfirmwareReveision: %@\nhardwareRevision: %@\nprotocolStrings: %@",
					  
					  connectedAccessory.connected,
					  connectedAccessory.connectionID,
					  connectedAccessory.name,
					  connectedAccessory.manufacturer,
					  connectedAccessory.modelNumber,
					  connectedAccessory.serialNumber,
					  connectedAccessory.firmwareRevision,
					  connectedAccessory.hardwareRevision,
					  strProtocolNames
					  ];
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Companion Information" message:msg delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
	[alert show];
}


@end
