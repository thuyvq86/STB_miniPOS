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
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if (_firstLoad) {
        [self loadContent];
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
    //[_tableView setBackgroundColor:[UIColor redColor]];
}

#pragma mark - ICDeviceDelegate

- (void)accessoryDidConnect:(ICISMPDevice *)sender {
    if (!self.connectedAccessories || [self.connectedAccessories count] == 0)
        [self loadContent];
}

- (void)accessoryDidDisconnect:(ICISMPDevice *)sender {
    [self loadContent];
}

#pragma mark - Load content

- (void)loadContent{
    self.connectedAccessories = [NSMutableArray array];
    NSArray *pairedDevices = nil;
    
    //Get data from database
    [ICMPProfile deleteDuplicatedData];
    pairedDevices = [ICMPProfile getAll];
    
    [_connectedAccessories addObjectsFromArray:pairedDevices];
    
    // Nicolas {
    /*
    if (![ICISMPDevice isAvailable]) {
        NSLog(@"PairedDevices > %lu", (unsigned long)pairedDevices.count);
        NSString *message = @"Devices not availabe or Idle. Please open/active the devices";
        [UIAlertView alertViewWithTitle:@"System Message" message:message cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:^(NSInteger buttonIndex, NSString *buttonTitle) {
        } onCancel:^{
            
        }];
    }
    else
     */
    // Nicolas }
    
    if ([ICISMPDevice isAvailable]) {
        ICMPProfile *availableInfo = [ICMPProfile getBySerialNumber:[ICISMPDevice serialNumber]];
        if (!availableInfo) {
            availableInfo = [[ICMPProfile alloc] initWithICISMPDevice];
            availableInfo.lastModifiedDate = [NSDate date];
            [availableInfo insertOrUpdate];
            
            //add new device into first
            [_connectedAccessories insertObject:availableInfo atIndex:0];
        }
        
        else if ((pairedDevices.count == 0) && availableInfo)
        {
            availableInfo = [[ICMPProfile alloc] initWithICISMPDevice];
            availableInfo.lastModifiedDate = [NSDate date];
            //add new device into first
            [_connectedAccessories insertObject:availableInfo atIndex:0];
            [availableInfo insertOrUpdate];
        }
        
    }

    
    [_tableView reloadData];
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
    if (_connectedAccessories && [_connectedAccessories count] > 0) {
        if (![ICISMPDevice isAvailable]) {
            NSString *message = @"Devices not availabe or Idle. Please open/active the devices";
            [UIAlertView alertViewWithTitle:@"System Message" message:message cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:^(NSInteger buttonIndex, NSString *buttonTitle) {
            } onCancel:^{
                
            }];
        } else {
        [self didSelectRow:indexPath.row];
        }
    }
}

- (void)didSelectRow:(NSInteger)row{
    ICMPProfile *profile = [_connectedAccessories objectAtIndex:row];
    [self getProfile:profile];
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
        
        [SVProgressHUD dismiss];
        [UIAlertView alertViewWithTitle:@"System Message" message:@"Please enable Wireless to continue." cancelButtonTitle:@"OK"];
    }];
}

- (void)showAlertWithPairedDeviceInfo:(ICMPProfile *)pairedDevice{
    
    NSString *title = [pairedDevice displayableName];
    NSString *desc = [pairedDevice descriptionOfProfile];
    NSString *buttonTittle = @"Do transaction";
    if (![pairedDevice.serialId isEqualToString:[ICISMPDevice serialNumber]])
        buttonTittle = @"OK";
    
    [UIAlertView alertViewWithTitle:title message:desc cancelButtonTitle:buttonTittle otherButtonTitles:nil onDismiss:^(NSInteger buttonIndex, NSString *buttonTitle) {
    } onCancel:^{
        //go to messaging view
        if ([pairedDevice.serialId isEqualToString:[ICISMPDevice serialNumber]])
            [self showMessagingView:pairedDevice];
    }];
}

#pragma mark - User actions

- (IBAction)buttonSettingsTouch:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil];
    
    UINavigationController *settingsNavigationController = [storyBoard instantiateViewControllerWithIdentifier:@"settingsNavigationController"];
    STBSettingsViewController *settingsViewController = settingsNavigationController.viewControllers[0];
    settingsViewController.delegate = self;
    
    //[self presentViewController:settingsNavigationController animated:YES completion:nil];
    [self parentView:self presentViewController:settingsNavigationController animated:YES completion:nil];
}

// Sent to the delegate when the screen is dismissed.
- (void)settingsViewControllerDidFinish:(STBSettingsViewController *)settingsViewController{
    [self parentView:self dismissViewController:settingsViewController.navigationController animated:YES completion:nil];
    
    [self loadContent];
}

@end
