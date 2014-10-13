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

@interface iSMPTestSuiteViewController()

@property (nonatomic, retain) NSArray *connectedAccessories;

@end

@implementation iSMPTestSuiteViewController
@synthesize testGroups, labelApiVersion, labelApplicationBuildTime, labelAppVersion;
@synthesize batteryLogStream;
@synthesize connectedAccessories = _connectedAccessories;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"[STB] - Mini POS";
	
    labelApiVersion.text = [NSString stringWithFormat:@"iSMP Library Version: %@", [ICISMPVersion substringFromIndex:6]];
	labelAppVersion.text = [NSString stringWithFormat:@"Application Version: %@", currentVersion];
	self.testGroups  = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestGroups" ofType:@"plist"]];
	
	//Start Battery Monitoring
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
	
	//Start iPhone & iSMP Battery Logging
	[NSTimer scheduledTimerWithTimeInterval:kTimerRefreshPeriod target:self selector:@selector(monitorBattery) userInfo:nil repeats:YES];
	
	//Initialize the battery Log stream
	NSString *logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"battery.log"];
	[[NSFileManager defaultManager] removeItemAtPath:logPath error:NULL];
	self.batteryLogStream = [NSOutputStream outputStreamToFileAtPath:logPath append:YES];
	[self.batteryLogStream open];
	NSString * header = @"Time;iPOD Battery Level;iSMP Battery Level;ACLineStatus\r\n";
	[self.batteryLogStream write:(uint8_t *)[header UTF8String] maxLength:[header length]];
	[self monitorBattery];
	
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (UIAppDelegate.bluetoothEnabled)
        [self loadContent];
    else
        [self performSelector:@selector(loadContent) withObject:nil afterDelay:.1];
}

- (void)loadContent{
    if (![self isBluetoothPoweredOn])
        return;
    
    self.connectedAccessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    [_tableView reloadData];
    
//    [self iSpmInformation];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [_tableView release];
    _tableView = nil;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	[self.batteryLogStream close];
	self.batteryLogStream = nil;
}

- (void)dealloc {
    [_connectedAccessories release];
	[testGroups release];
	
	//Stop Battery Monitoring
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
	
    [_tableView release];
    [super dealloc];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//	return [testGroups count];
    if (_connectedAccessories && [_connectedAccessories count] > 0)
        return [_connectedAccessories count];
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (_connectedAccessories && [_connectedAccessories count] > 0){
        EAAccessory *connectedAccessory = [_connectedAccessories objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [self connectedAccessoryString:connectedAccessory];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        cell.textLabel.text = @"No detected accessory !!";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_connectedAccessories && [_connectedAccessories count] > 0){
        EAAccessory *connectedAccessory = [_connectedAccessories objectAtIndex:indexPath.row];
        NSString *msg = [self connectedAccessoryString:connectedAccessory];
        
        float padding = 10.0f;
        float w = CGRectGetWidth(tableView.frame) - 2 * padding;
        float h = [msg heightForWidth:w andFont:[UIFont systemFontOfSize:12.0f]];
            
        return h + 2*padding;
    }
    
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([ICISMPDevice isAvailable]){
        Class testClass = NSClassFromString(@"BasicTransactionTest");

        UIViewController *detailViewController = [[testClass alloc] init];
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
}

#pragma mark -

- (BOOL)isBluetoothPoweredOn{
    CBCentralManagerState state = [UIAppDelegate.bluetoothManager state];
    if (state == CBCentralManagerStatePoweredOn)
        return YES;
    
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
            message = @"State unknown, update imminent.";
            break;
    }
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Bluetooth state"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"Okay"
                                           otherButtonTitles:nil, nil] autorelease];
    [alert show];
    
    return NO;
}

- (IBAction)iSpmInformation {
    
	if ([ICISMPDevice isAvailable] == NO) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"No detected accessory !!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] autorelease];
		[alert show];
		return;
	}
	EAAccessory * connectedAccessory = nil;
	NSMutableArray * protocolStrings = [[NSMutableArray alloc] init];
    NSArray *connectedAccessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    DLog(@"%@", connectedAccessories);
	for (EAAccessory *obj in connectedAccessories) {
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

- (NSString *)connectedAccessoryString:(EAAccessory *)connectedAccessory{
    NSArray *protocolStrings = [connectedAccessory protocolStrings];
    NSString *msg = [NSString stringWithFormat:
					  @"connected: %d\nconnectionID: %d\nname: %@\nmanufacturer: %@\nmodelNumber: %@\nserialNumber: %@\nfirmwareReveision: %@\nhardwareRevision: %@\nprotocolStrings: %@",
					  
					  connectedAccessory.connected,
					  connectedAccessory.connectionID,
					  connectedAccessory.name,
					  connectedAccessory.manufacturer,
					  connectedAccessory.modelNumber,
					  connectedAccessory.serialNumber,
					  connectedAccessory.firmwareRevision,
					  connectedAccessory.hardwareRevision,
					  [protocolStrings componentsJoinedByString:@"\n"]
					  ];
    
    return msg;
}

#pragma mark - Monitor Battery

- (void)monitorBatteryHelper {
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
//	[self performSelectorInBackground:@selector(monitorBatteryHelper) withObject:nil];
}

@end
