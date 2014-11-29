//
//  STBCenterViewController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBCenterViewController.h"
#import "STBMessagingViewController.h"
//Models
#import "ICMPProfile+Operations.h"

@interface STBCenterViewController ()<ICISMPDeviceDelegate>

@property (nonatomic, assign) iSMPControlManager *iSMPControl;
@property (nonatomic, strong) NSMutableArray *connectedAccessories;
@property (nonatomic, strong) NSOutputStream *batteryLogStream;

@property (nonatomic) NSInteger requestSendCount;

@end

@implementation STBCenterViewController

@synthesize requestSendCount = _requestSendCount;

#define kTimerRefreshPeriod 30

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setupUI];
    
    //set Texts
    _lblTitle.text = @"[STB] - Mini POS";
    _logoImageView.image = [UIImage imageNamed:@"icon_128x128"];
    
    //Get the iSMPControlManager
    self.iSMPControl = [iSMPControlManager sharedISMPControlManager];
    [self.iSMPControl addDelegate:self];
    
    DLog(@"iSMP Library Version: %@", [ICISMPVersion substringFromIndex:6]);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self updateFrameOfView];
    [self isBluetoothPoweredOn];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (UIAppDelegate.bluetoothEnabled)
        [self loadContent];
    else
        [self performSelector:@selector(loadContent) withObject:nil afterDelay:.1];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload{
    //Stop Battery Monitoring
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)failure:(NSError *)error{
    NSString *msg = [NSString stringWithFormat:@"Error %i", [error code]];
    [UIAlertView alertViewWithTitle:@"" message:msg cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:^(NSInteger buttonIndex, NSString *buttonTitle) {
    } onCancel:^{
        //do next process
        
    }];
}

#pragma mark - UI & Theming

- (void)setupUI{
    UIColor *barColor   = [UIColor colorWithRed:161.0/255.0 green:164.0/255.0 blue:166.0/255.0 alpha:1.0];
    UIColor *titleColor = [UIColor colorWithRed:55.0/255.0 green:70.0/255.0 blue:77.0/255.0 alpha:1.0];
    _lblTitle.textColor              = titleColor;
    _topbarImageView.backgroundColor = barColor;
    
    [self setupPlainTableView:_tableView showScrollIndicator:NO hasBorder:NO hasSeparator:YES];
}

#pragma mark - Load content

- (void)loadContent{
    ICMPProfile *profile = nil;
    NSArray *pairedDevices = nil;
    if ([ICISMPDevice isAvailable])
        pairedDevices = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    
    self.connectedAccessories = [NSMutableArray array];
    for (EAAccessory *acc in pairedDevices){
        profile = [[ICMPProfile alloc] initWithAccessory:acc];
        [_connectedAccessories addObject:profile];
    }
    
#if TARGET_IPHONE_SIMULATOR
    profile = [[ICMPProfile alloc] initWithAccessory:nil];
    profile.serialId = @"20138884";
    [_connectedAccessories addObject:profile];
#endif
    
    //load profile aumatically
//    [self getProfile:profile];
    
    [_tableView reloadData];
}

#pragma mark - Get Profile from STB server

- (void)getProfile:(ICMPProfile *)profile{
    _requestSendCount++;
    
    [profile getProfileWithCompletionBlock:^(id responseObject, NSError *error) {
        if (responseObject) {
            DLog(@"success:\n%@", responseObject);
            //continue with the next request
            _requestSendCount = 0;
            [_tableView reloadData];
            
            //go to messaging view
            [self showMessagingView:profile];
        }
        else{
            DLog(@"failure:\n%@", error);
            //send request again if less than third times
            if (_requestSendCount < 3)
                [self getProfile:profile];
            else
                [self failure:error];
        }
    }];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
    
    if (_connectedAccessories && [_connectedAccessories count] > 0){
        ICMPProfile *profile = [_connectedAccessories objectAtIndex:indexPath.row];
        NSString *text = [self connectedAccessoryString:profile.accessory];
#if TARGET_IPHONE_SIMULATOR
        text = [NSString stringWithFormat:@"iCMP - %@", profile.serialId];
#endif
        cell.textLabel.text = text;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        cell.textLabel.text = @"No detected accessory!!";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_connectedAccessories && [_connectedAccessories count] > 0){
        ICMPProfile *profile = [_connectedAccessories objectAtIndex:indexPath.row];
        NSString *msg = [self connectedAccessoryString:profile.accessory];
#if TARGET_IPHONE_SIMULATOR
        msg = [NSString stringWithFormat:@"iCMP - %@", profile.serialId];
#endif
        float padding = 10.0f;
        float w = CGRectGetWidth(tableView.frame) - 2 * padding;
        float h = [msg heightForWidth:w andFont:[UIFont systemFontOfSize:12.0f]];
        
        return h + 2*padding;
    }
    
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (_connectedAccessories && [_connectedAccessories count] > 0)
        [self didSelectRow:indexPath.row];
}

- (void)didSelectRow:(int)row{
    ICMPProfile *profile = [_connectedAccessories objectAtIndex:row];
    if (!profile.merchantId)
        [self getProfile:profile];
    else
        [self showMessagingView:profile];
}

- (void)showMessagingView:(ICMPProfile *)profile{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MessagingStoryboard" bundle:nil];
    STBMessagingViewController *messagingViewController = [storyBoard instantiateViewControllerWithIdentifier:@"MessagingViewController"];
    messagingViewController.profile = profile;
    
    [self.navigationController pushViewController:messagingViewController animated:YES];
}

#pragma mark - Bluetooth check

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
//            message = @"State unknown, update imminent.";
            break;
    }
    
    if (message)
        [UIAlertView alertViewWithTitle:@"Bluetooth state" message:message cancelButtonTitle:@"Okay"];
    
    return NO;
}

#pragma mark - iSpm Info

- (IBAction)iSpmInformation:(id)sender{
    
	if ([ICISMPDevice isAvailable] == NO) {
        [UIAlertView alertViewWithTitle:@"" message:@"No detected accessory !!" cancelButtonTitle:@"Close"];
		return;
	}
    
	EAAccessory *connectedAccessory = nil;
    NSArray *connectedAccessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
	for (EAAccessory *obj in connectedAccessories) {
		connectedAccessory = obj;
		break;
	}
    
	NSString *msg = [self connectedAccessoryString:connectedAccessory];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Companion Information" message:msg delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
	[alert show];
}

- (NSString *)connectedAccessoryString:(EAAccessory *)connectedAccessory{
    if (!connectedAccessory)
        return nil;
    
    NSArray *protocolStrings = [connectedAccessory protocolStrings];
    NSString *msg = [NSString stringWithFormat:
                     @"connected: %d\nconnectionID: %d\nname: %@\nmanufacturer: %@\nmodelNumber: %@\nserialId: %@\nfirmwareReveision: %@\nhardwareRevision: %@\nprotocolStrings: %@",
                     
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

#pragma mark - ICDeviceDelegate

- (void)accessoryDidConnect:(ICISMPDevice *)sender {
    if (!self.connectedAccessories || [self.connectedAccessories count] == 0)
        [self loadContent];
}

- (void)accessoryDidDisconnect:(ICISMPDevice *)sender {
    [self loadContent];
}

#pragma mark - Monitor Battery

- (void)monitorBatteryHelper {
//	@autoreleasepool {
        float iPhoneBatteryLevel = [[UIDevice currentDevice] batteryLevel] * 100;
        NSInteger acLine = -1;
        if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
            acLine = 0;
        } else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnknown) {
            acLine = -1;
        } else {
            acLine = 1;
        }
        ICAdministration *control = [ICAdministration sharedChannel];
        NSInteger iSpmBatteryLevel = control.batteryLevel;
        
        NSString * time = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
        NSString * str = [NSString stringWithFormat:@"%@;%f;%d;%d\r\n", time, iPhoneBatteryLevel, iSpmBatteryLevel, acLine];
        [self.batteryLogStream write:(uint8_t *)[str UTF8String] maxLength:[str length]];
//    }
}

- (void)monitorBattery {
    //	[self performSelectorInBackground:@selector(monitorBatteryHelper) withObject:nil];
}

@end
