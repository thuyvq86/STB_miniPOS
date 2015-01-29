//
//  AppInfoController.m
//  CardTest
//
//  Created by Hichem Boussetta on 16/11/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import "AppInfoController.h"

//#import "../GeneratedFiles/version.h"


@implementation AppInfoController


@synthesize appVersion;
@synthesize libiSMPVersion;


#pragma mark - View lifecycle

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Get the app version
    self.appVersion.text            = @"11";//(NSString *)currentVersion;
    self.libiSMPVersion.text        = [ICISMPVersion substringFromIndex:6];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


//Deprecated in iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//Replacement in iOS 6 of shouldAutorotateToInterfaceOrientation
-(BOOL)shouldAutorotate {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -

#pragma mark UI Actions

-(IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

@end
