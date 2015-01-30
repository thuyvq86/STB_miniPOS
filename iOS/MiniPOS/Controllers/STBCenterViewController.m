//
//  STBCenterViewController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBCenterViewController.h"
//Controllers
#import "STBMessagingViewController.h"
#import "STBSettingsViewController.h"
//Views
#import "DeviceProfileInfoCell.h"
//Models
#import "ICMPProfile+Operations.h"
#import "ICMPProfile.h"

@interface STBCenterViewController ()<ICISMPDeviceDelegate, SettingsViewDelegate>

@property (nonatomic, assign) iSMPControlManager *iSMPControl;
@property (nonatomic, strong) NSMutableArray *connectedAccessories;
@property (nonatomic, strong) NSOutputStream *batteryLogStream;

@property (nonatomic) BOOL firstLoad;
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
    
    _firstLoad = YES;
    
    //Get the iSMPControlManager
    self.iSMPControl = [iSMPControlManager sharedISMPControlManager];
    [self.iSMPControl addDelegate:self];
    
    DLog(@"iSMP Library Version: %@", [ICISMPVersion substringFromIndex:6]);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self updateFrameOfView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self updateFrameOfView];
    
    if (UIAppDelegate.bluetoothEnabled)
        [self loadContent];
    else{
        if (_firstLoad)
            [self performSelector:@selector(isBluetoothPoweredOn) withObject:nil afterDelay:.1];
        
        [self performSelector:@selector(loadContent) withObject:nil afterDelay:.1];
    }
    _firstLoad = NO;
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

#pragma mark - UI & Theming

- (void)setupUI{
    _topbarImageView.backgroundColor = [UIColor clearColor];
    [self setupPlainTableView:_tableView showScrollIndicator:NO hasBorder:NO hasSeparator:NO];
}

#pragma mark - Load content

- (void)loadContent{
    self.connectedAccessories = [NSMutableArray array];

    NSArray *pairedDevices = [ICMPProfile getAll];
    [_connectedAccessories addObjectsFromArray:pairedDevices];
    
    if ([ICISMPDevice isAvailable]) {
        ICMPProfile *availableInfo = [ICMPProfile getBySerialNumber:[ICISMPDevice serialNumber]];
        if (!availableInfo) {
            availableInfo = [[ICMPProfile alloc] initWithICISMPDevice];
            availableInfo.lastModifiedDate = [NSDate date];
            [availableInfo insertOrUpdate];
            
            //add new device into first
            [_connectedAccessories insertObject:availableInfo atIndex:0];
        }
    }
    
    [_tableView reloadData];
    
    /*
    ICMPProfile *profile = nil;
    NSArray *pairedDevices = nil;
    if ([ICISMPDevice isAvailable])
        pairedDevices = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    
    self.connectedAccessories = [NSMutableArray array];
    for (EAAccessory *acc in pairedDevices){
        profile = [[ICMPProfile alloc] init];
        profile.serialId = acc.serialNumber;
        
        [_connectedAccessories addObject:profile];
    }
    
#if TARGET_IPHONE_SIMULATOR
    profile = [[ICMPProfile alloc] init];
    profile.serialId = @"20138884";
    [_connectedAccessories addObject:profile];
    
    [UIAppDelegate insertOrUpdateTestDevice:@"iCMP" serialNumber:profile.serialId];
#endif
    
    //save paired device
    if ([ICISMPDevice isAvailable])
        [UIAppDelegate insertOrUpdatePairedDevice];
    
    [_tableView reloadData];
    */
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_connectedAccessories && [_connectedAccessories count] > 0)
        return [_connectedAccessories count];
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (_connectedAccessories && [_connectedAccessories count] > 0)
        cell = [self tableView:tableView profileInfoCellAtIndexPath:indexPath];
    else
        cell = [self tableView:tableView messageCellAtIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView profileInfoCellAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DeviceProfileInfoCell";
    DeviceProfileInfoCell *cell = (DeviceProfileInfoCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[DeviceProfileInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    ICMPProfile *profile = [_connectedAccessories objectAtIndex:indexPath.row];
    [cell setProfile:profile];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView messageCellAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"MessageCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = @"No detected accessory!!";
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = CGRectGetWidth(tableView.frame);
    if (_connectedAccessories && [_connectedAccessories count] > 0){
        ICMPProfile *profile = [_connectedAccessories objectAtIndex:indexPath.row];
        return [DeviceProfileInfoCell heightForProfile:profile parentWidth:width];
    }
    
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (_connectedAccessories && [_connectedAccessories count] > 0)
        [self didSelectRow:indexPath.row];
}

- (void)didSelectRow:(NSInteger)row{
    ICMPProfile *profile = [_connectedAccessories objectAtIndex:row];
    [self getProfile:profile];
    
//    if (!profile.merchantId)
//        [self getProfile:profile];
//    else
//        [self showMessagingView:profile];
}

- (void)showMessagingView:(ICMPProfile *)profile{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MessagingStoryboard" bundle:nil];
    STBMessagingViewController *messagingViewController = [storyBoard instantiateViewControllerWithIdentifier:@"MessagingViewController"];
    messagingViewController.profile = profile;
    
    [self.navigationController pushViewController:messagingViewController animated:YES];
}

#pragma mark - Get Profile from STB server

- (void)getProfile:(ICMPProfile *)profile{
    _requestSendCount++;
    
    [SVProgressHUD showWithStatus:@"Getting profile..." maskType:SVProgressHUDMaskTypeBlack];
    
    [profile getProfileWithCompletionBlock:^(id JSON, NSError *error) {
        if (JSON) {
            DLog(@"success:\n%@", JSON);
            //continue with the next request
            _requestSendCount = 0;
            
            [self loadContent];
            [_tableView reloadData];
            
            //dismiss hud
            [SVProgressHUD dismiss];
            
            //show info
            [self showAlertWithPairedDeviceInfo:profile];
        }
        else{
            DLog(@"failure:\n%@", error);
            //send request again if less than third times
            if (_requestSendCount < 3)
                [self getProfile:profile];
            else{
                [SVProgressHUD dismiss];
                [UIAlertView alertViewWithTitle:@"System Message" message:@"Invalid profile!" cancelButtonTitle:@"OK"];
            }
        }
    } noInternet:^{
        _requestSendCount = 3;
        [SVProgressHUD showErrorWithStatus:@"Please enable Wrireless to continue."];
    }];
}

- (void)showAlertWithPairedDeviceInfo:(ICMPProfile *)pairedDevice{
    
    NSString *title = [pairedDevice displayableName];
    NSString *desc = [pairedDevice descriptionOfProfile];
    
    [UIAlertView alertViewWithTitle:title message:desc cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:^(NSInteger buttonIndex, NSString *buttonTitle) {
    } onCancel:^{
        //go to messaging view
        [self showMessagingView:pairedDevice];
    }];
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

#pragma mark - ICDeviceDelegate

- (void)accessoryDidConnect:(ICISMPDevice *)sender {
    if (!self.connectedAccessories || [self.connectedAccessories count] == 0)
        [self loadContent];
}

- (void)accessoryDidDisconnect:(ICISMPDevice *)sender {
    [self loadContent];
}

#pragma mark - User actions

- (IBAction)buttonSettingsTouch:(id)sender {
    ICMPProfile *profile = nil;
    if (_connectedAccessories && [_connectedAccessories count] > 0)
        profile = [_connectedAccessories objectAtIndex:0];
    
//    [self showSettingsView:profile.accessory];
    [self showSettingsView:nil];
}

- (void)showSettingsView:(EAAccessory *)pairedDevice{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil];
    
    UINavigationController *settingsNavigationController = [storyBoard instantiateViewControllerWithIdentifier:@"settingsNavigationController"];
    STBSettingsViewController *settingsViewController = settingsNavigationController.viewControllers[0];
    settingsViewController.delegate = self;
//    settingsViewController.pairedDevice = pairedDevice;
    
    //[self presentViewController:settingsNavigationController animated:YES completion:nil];
    [self parentView:self presentViewController:settingsNavigationController animated:YES completion:nil];
}

// Sent to the delegate when the screen is dismissed.
- (void)settingsViewControllerDidFinish:(STBSettingsViewController *)settingsViewController{
    [self parentView:self dismissViewController:settingsViewController.navigationController animated:YES completion:nil];
}

@end
