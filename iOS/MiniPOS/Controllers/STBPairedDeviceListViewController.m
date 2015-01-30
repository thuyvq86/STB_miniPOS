//
//  STBPairedDeviceListViewController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 12/22/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBPairedDeviceListViewController.h"
#import "PairedDeviceInfoCell.h"
#import "ICMPProfile.h"

@interface STBPairedDeviceListViewController ()

@property (nonatomic, strong) NSArray *pairedDevices;

@end

@implementation STBPairedDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    self.pairedDevices = [ICMPProfile getAll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)setupUI{
    [self setupPlainTableView:_tableView showScrollIndicator:NO hasBorder:NO hasSeparator:NO];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_pairedDevices count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    cell = [self tableView:tableView profileInfoCellAtIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView profileInfoCellAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PairedDeviceInfoCell";
    PairedDeviceInfoCell *cell = (PairedDeviceInfoCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[PairedDeviceInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    ICMPProfile *device = [self.pairedDevices objectAtIndex:indexPath.row];
    [cell setPairedDevice:device];
    
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
    
    ICMPProfile *device = [self.pairedDevices objectAtIndex:indexPath.row];
    [self showAlertWithPairedDeviceInfo:device];
}

#pragma mark - Device Info

- (void)showAlertWithPairedDeviceInfo:(ICMPProfile *)pairedDevice{
    
    NSString *title = [pairedDevice displayableName];
    NSString *desc = [pairedDevice descriptionOfProfile];
    
    [UIAlertView alertViewWithTitle:title message:desc cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Reset"] onDismiss:^(NSInteger buttonIndex, NSString *buttonTitle) {
        if (buttonIndex == 1){
            [self resetProfile:pairedDevice];
        }
    } onCancel:nil];
}

- (void)resetProfile:(ICMPProfile *)pairedDevice {
    DLog();
    
    //delete from database
    
    //update UI
    [_tableView reloadData];
}

@end
