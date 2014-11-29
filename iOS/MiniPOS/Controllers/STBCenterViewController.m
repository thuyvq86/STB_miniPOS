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
#import "AppInfoController.h"
//Views
#import "DeviceProfileInfoCell.h"
//Models
#import "ICMPProfile+Operations.h"

@interface STBCenterViewController ()<ICISMPDeviceDelegate, AppInfoDelegate>

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

- (void)failure:(NSError *)error{
    NSString *msg = [NSString stringWithFormat:@"Error %i", [error code]];
    [UIAlertView alertViewWithTitle:@"" message:msg cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:^(NSInteger buttonIndex, NSString *buttonTitle) {
    } onCancel:^{
        //do nothing
    }];
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
    AppInfoController *appInfoController = [[AppInfoController alloc] initWithNibName:@"AppInfoController" bundle:nil];
    appInfoController.delegate = self;
    
//    [self presentViewController:appInfoController animated:YES completion:nil];
    [self parentView:self presentViewController:appInfoController animated:YES completion:nil];
}

- (void)didFinishAppInfoController:(id)appInfoController{
    [self parentView:self dismissViewController:appInfoController animated:YES completion:nil];
}

@end
