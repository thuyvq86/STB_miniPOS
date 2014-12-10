//
//  STBSettingsViewController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 12/10/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBSettingsViewController.h"
//Views
#import "SettingsInfoCellTableViewCell.h"
//Controllers
#import "AppInfoController.h"

@interface STBSettingsViewController ()<AppInfoDelegate>

@end

@implementation STBSettingsViewController

@synthesize pairedDevice = _pairedDevice;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)setupUI{
    _navItem.leftBarButtonItem = [self barButtonItemWithTitle:@"Back" style:UIBarButtonItemStylePlain action:@selector(buttonBackTouch:)];
    
    if([_navigationBar respondsToSelector:@selector(setBarTintColor:)])
        [_navigationBar setBarTintColor:PRIMARY_BACKGROUND_COLOR];
    else
        [_navigationBar setTintColor:PRIMARY_BACKGROUND_COLOR];
    [_navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                             NSFontAttributeName:[UIFont systemFontOfSize:21.0f]
                                             }];
    
    [self setupPlainTableView:_tableView showScrollIndicator:NO hasBorder:NO hasSeparator:NO];
}

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title style:(NSInteger)style action:(SEL)action{
    UIBarButtonItem *button = nil;
    
    button = [[UIBarButtonItem alloc] initWithTitle:title style:style target:self action:action];
    [button setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    return button;
}

#pragma mark - User actions

- (void)buttonBackTouch:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    cell = [self tableView:tableView profileInfoCellAtIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView profileInfoCellAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SettingsInfoCellTableViewCell";
    SettingsInfoCellTableViewCell *cell = (SettingsInfoCellTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[SettingsInfoCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (indexPath.row == 0){
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSString *text = @"No Paired device.";
        if (self.pairedDevice)
            text = [NSString stringWithFormat:@"Paired device: %@-%@", self.pairedDevice.name, self.pairedDevice.serialNumber];
        
        cell.textLabel.text = text;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"About";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        if (self.pairedDevice)
            [self showPairedDeviceInfoAlert];
    }
    else if (indexPath.row == 1){
        [self showAppInfoView];
    }
}

#pragma mark - Device Info

- (void)showPairedDeviceInfoAlert{

    NSString *title = [NSString stringWithFormat:@"%@-%@", self.pairedDevice.name, self.pairedDevice.serialNumber];
    NSString *msg = [NSString stringWithFormat:
                     @"Manufacturer: %@\nModel Number: %@\nSerial Id: %@\nFirmware Reveision: %@\nHardware Revision: %@",
                     self.pairedDevice.manufacturer,
                     self.pairedDevice.modelNumber,
                     self.pairedDevice.serialNumber,
                     self.pairedDevice.firmwareRevision,
                     self.pairedDevice.hardwareRevision
                     ];
    
    NSString *msg2 = [NSString stringWithFormat:
                     @"Name: %@\nModel Number: %@\nSerial Id: %@\nFirmware Reveision: %@\nHardware Revision: %@",
                     [ICISMPDevice name],
                     [ICISMPDevice modelNumber],
                     [ICISMPDevice serialNumber],
                     [ICISMPDevice firmwareRevision],
                     [ICISMPDevice hardwareRevision]
                     ];
    DLog(@"%@", msg2);
    
    [UIAlertView alertViewWithTitle:title message:msg cancelButtonTitle:@"OK"];
}

#pragma mark - About

- (void)showAppInfoView{
    AppInfoController *appInfoController = [[AppInfoController alloc] initWithNibName:@"AppInfoController" bundle:nil];
    appInfoController.delegate = self;
    
    [self parentView:self presentViewController:appInfoController animated:YES completion:nil];
}

- (void)didFinishAppInfoController:(id)appInfoController{
    [self parentView:self dismissViewController:appInfoController animated:YES completion:nil];
}

@end
