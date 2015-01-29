//
//  ConfigurationViewController.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 25/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ConfigurationViewController.h"

@implementation ConfigurationViewController

@synthesize pclInterfaceType;
@synthesize iOSTcpPclPort;
@synthesize terminalTcpPclPort;
@synthesize terminalIP;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Settings";
    
    //Load user settings
    [self loadUserSettings];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    //Save the settings
    [self saveUserSettings];
    
    [super viewWillDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -


-(void)loadUserSettings {
    NSLog(@"%s", __FUNCTION__);
    
    //Get the shared settings manager
    SettingsManager * settingsManager = [SettingsManager sharedSettingsManager];
    
    self.pclInterfaceType.selectedSegmentIndex          = settingsManager.pclInterfaceType;
    self.iOSTcpPclPort.text                             = [NSString stringWithFormat:@"%ld", (long)settingsManager.iOSTcpPclPort];
    self.terminalTcpPclPort.text                        = [NSString stringWithFormat:@"%ld", (long)settingsManager.terminalPclTcpPort];
    self.terminalIP.text                                = settingsManager.terminalIP;
}

-(void)saveUserSettings {
    NSLog(@"%s", __FUNCTION__);
    
    //Get the shared settings manager
    SettingsManager * settingsManager   = [SettingsManager sharedSettingsManager];
    
    settingsManager.pclInterfaceType    = self.pclInterfaceType.selectedSegmentIndex;
    settingsManager.iOSTcpPclPort       = [self.iOSTcpPclPort.text integerValue];
    settingsManager.terminalPclTcpPort  = [self.terminalTcpPclPort.text integerValue];
    settingsManager.terminalIP          = self.terminalIP.text;
    
    //Save the settings
    [settingsManager saveSettings];
}


#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -

@end
