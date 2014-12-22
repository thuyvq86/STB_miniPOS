//
//  STBSettingsViewController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 12/10/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBSettingsViewController.h"
//Views
#import "SettingsInfoCell.h"
//Controllers
#import "AppInfoController.h"
#import "STBPairedDeviceListViewController.h"
//Models
#import "PairedDevice.h"

@interface STBSettingsViewController ()

@property (nonatomic) NSInteger countPaireDevices;

@end

@implementation STBSettingsViewController

@synthesize delegate;
@synthesize pairedDevice = _pairedDevice;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    self.countPaireDevices = [PairedDevice getCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)setupUI{
    self.navigationItem.leftBarButtonItem = [self barButtonItemWithTitle:@"Done" style:UIBarButtonItemStyleDone action:@selector(buttonBackTouch:)];
    
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)])
        [self.navigationController.navigationBar setBarTintColor:PRIMARY_BACKGROUND_COLOR];
    else
        [self.navigationController.navigationBar setTintColor:PRIMARY_BACKGROUND_COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                             NSFontAttributeName:[UIFont systemFontOfSize:21.0f]
                                             }];
    
    [self setupPlainTableView:_tableView showScrollIndicator:NO hasBorder:NO hasSeparator:NO];
}

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title style:(NSInteger)style action:(SEL)action{
    UIBarButtonItem *button = nil;
    
    button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(buttonBackTouch:)];
    [button setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    return button;
}

#pragma mark - User actions

- (void)buttonBackTouch:(id)sender{
    if (delegate && [delegate respondsToSelector:@selector(settingsViewControllerDidFinish:)]){
        [delegate settingsViewControllerDidFinish:self];
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
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
    SettingsInfoCell *cell = (SettingsInfoCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[SettingsInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == 0){
        if (_countPaireDevices > 0){
            cell.textLabel.text = @"Paired devices";
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"No Paired devices.";
        }
    }
    else{
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0){
        if (_countPaireDevices > 0)
            [self showPairedDevicesView];
    }
    else if (indexPath.row == 1){
        [self showAppInfoView];
    }
}

#pragma mark - About

- (void)showAppInfoView{
    AppInfoController *appInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"appInfoController"];
    
    [self.navigationController pushViewController:appInfoController animated:YES];
}

- (void)showPairedDevicesView{
    STBPairedDeviceListViewController *appInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"pairedDeviceListViewController"];
    
    [self.navigationController pushViewController:appInfoController animated:YES];
}

@end
