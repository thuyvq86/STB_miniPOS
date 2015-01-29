//
//  CompanionSelectionViewController.m
//  CompanionTest
//
//  Created by steph on 10/03/2014.
//  Copyright (c) 2014 Ingenico. All rights reserved.
//

#import "CompanionSelectionViewController.h"
#import <iSMP/ICISMPDevice.h>

@interface CompanionSelectionViewController ()

@end

@implementation CompanionSelectionViewController

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
    self.title = @"Select Companion";
    
}

- (void) handleBack:(id)sender
{
    // pop to root view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedCompanionToSave = [[ICISMPDevice getConnectedTerminals] objectAtIndex:indexPath.row];
    [ICISMPDevice setWantedDevice: selectedCompanionToSave];
    NSLog(@"Companion selected is %@", selectedCompanionToSave);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:selectedCompanionToSave forKey:@"IngenicoCompanionInUse"];
    [tableView reloadData];
}



#pragma mark -

#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int companionNumber = 0;
    companionNumber = [[ICISMPDevice getConnectedTerminals] count];
    return companionNumber;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [[ICISMPDevice getConnectedTerminals]  objectAtIndex:indexPath.row];
    if([[ICISMPDevice getWantedDevice] isEqualToString:cell.textLabel.text])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

#pragma mark -

@end
