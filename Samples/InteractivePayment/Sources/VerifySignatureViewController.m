//
//  VerifySignatureViewController.m
//  InteractivePayment
//
//  Created by Hichem BOUSSETTA on 23/10/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "VerifySignatureViewController.h"

@interface VerifySignatureViewController ()

@end

@implementation VerifySignatureViewController

@synthesize parent;
@synthesize imageView;
@synthesize signature;


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
    // Do any additional setup after loading the view from its nib.
    
    //Load the signature
    self.imageView.image = self.signature;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Deprecated in iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}





//Replacement in iOS 6 of shouldAutorotateToInterfaceOrientation
-(BOOL)shouldAutorotate {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    //Show status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [super viewWillDisappear:animated];
}


#pragma mark -


#pragma mark UI Actions

-(IBAction)done {
    NSLog(@"%s", __FUNCTION__);
    
    [(SignatureViewController *)self.parent onSignatureValidated:self.signature];
}

-(IBAction)resign {
    NSLog(@"%s", __FUNCTION__);
    
    [(SignatureViewController *)self.parent onSignatureRecapture];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

@end
