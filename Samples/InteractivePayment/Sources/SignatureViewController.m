//
//  SignatureViewController.m
//  iSMPDemo
//
//  Created by Hichem Boussetta on 15/12/11.
//  Copyright (c) 2011 Theoris. All rights reserved.
//

#import "SignatureViewController.h"


typedef enum {
    PORTRAIT = 0,
    LANDSCAPE
}SigningOrientation;


@interface  SignatureViewController ()

@property (nonatomic, retain) ICSignatureView   * signatureCanvas;
@property (nonatomic, assign) NSInteger           signatureOrientation;

@end


@implementation SignatureViewController

@synthesize signatureCanvas;
@synthesize parent;
@synthesize signatureCanvasWidth;
@synthesize signatureCanvasHeight;
@synthesize signatureOrientation;



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
    
    //Determine signature orientation
    /*
    self.signatureOrientation = PORTRAIT;
    int temp = 0;
    if (signatureCanvasWidth > signatureCanvasHeight) {
        temp                        = signatureCanvasWidth;
        self.signatureCanvasWidth   = signatureCanvasHeight;
        self.signatureCanvasHeight  = temp;
        self.signatureOrientation   = LANDSCAPE;
        NSLog(@"%s Switching to portrait mode", __FUNCTION__);
        
        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"Signature Orientation" message:@"Please right-flip the device in landscape mode and draw the signature" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
    */
    
    //Resize the signature canvas
    /*
    [self.signatureView setFrame:CGRectMake((self.view.frame.size.width - self.signatureCanvasWidth) / 2 , 
                                            200.0f + (self.view.frame.size.height - 200.0f - self.signatureCanvasHeight) / 2, 
                                            self.signatureCanvasWidth,
                                            self.signatureCanvasHeight)];
    */
    
    //Load the Signature View into its parent view
    //self.signatureCanvas = [[[ICSignatureView alloc] initWithFrame:CGRectMake(0, 44.0f, self.signatureCanvasWidth, self.signatureCanvasHeight)] autorelease];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //static CGFloat const kNavigationBarPortraitHeight = 44.0f;
    //static CGFloat const kNavigationBarLandscapeHeight = 44.0f;
    
    /*
    self.signatureCanvas = [[[ICSignatureView alloc] initWithFrame:CGRectMake((screenRect.size.height - self.signatureCanvasWidth) / 2 ,
                                                                              kNavigationBarLandscapeHeight + (screenRect.size.width - kNavigationBarLandscapeHeight - self.signatureCanvasHeight) / 2,
                                                                              self.signatureCanvasWidth,
                                                                              self.signatureCanvasHeight)] autorelease];
    */
    
    self.signatureCanvas = [[[ICSignatureView alloc] initWithFrame:CGRectMake((screenRect.size.height - self.signatureCanvasWidth) / 2 ,
                                                                              self.labelDisclaimer.frame.origin.y + self.labelDisclaimer.frame.size.height + (screenRect.size.width - self.labelBottomView.frame.size.height - self.labelDisclaimer.frame.origin.y - self.labelDisclaimer.frame.size.height - self.signatureCanvasHeight) / 2,
                                                                              self.signatureCanvasWidth,
                                                                              self.signatureCanvasHeight)] autorelease];
    
    //Set a white background
    self.signatureCanvas.blackBackground = NO;
    
    //Display the amount
    self.labelAmount.text = [NSString stringWithFormat:@"Amount:               %@", ((self.amount == nil) ? @"" : self.amount)];
    
    //[self.signatureView addSubview:self.signatureCanvas];
    [self.view addSubview:self.signatureCanvas];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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


#pragma mark -


#pragma mark UI Actions

-(IBAction)done:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    //Get the signature
    UIImage * signature = [signatureCanvas getSignatureData];
    
    //Check the orientation and rotate the signature accordingly
    /*
    if  (self.signatureOrientation == LANDSCAPE) {
        signature = [signature imageRotatedByDegrees:90.0f];
    }
    */
    
    NSLog(@"%s Signature Dimensions: [Width: %f, Height: %f]", __FUNCTION__, signature.size.width, signature.size.height);
    
    //NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/signature.png"];
    //[UIImagePNGRepresentation(signature) writeToFile:filePath atomically:YES];
    
    VerifySignatureViewController * verifySignatureController = [[[VerifySignatureViewController alloc] init] autorelease];
    verifySignatureController.signature = signature;
    verifySignatureController.parent = self;
    [self presentViewController:verifySignatureController animated:YES completion:nil];
}

-(IBAction)cancel:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    [self provideSignatureToParentViewController:nil];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -


-(void)provideSignatureToParentViewController:(UIImage *)signature {
    NSLog(@"%s", __FUNCTION__);
    [(FirstViewController *)self.parent forwardCustomerSignatureToPaymentObject:signature];
}


#pragma mark Signature Validation


-(void)onSignatureValidated:(UIImage *)signature {
    NSLog(@"%s", __FUNCTION__);
    
    //Provide the signature to parent controller and dismiss
    [self provideSignatureToParentViewController:signature];
}

-(void)onSignatureRecapture {
    NSLog(@"%s", __FUNCTION__);
    
    //Clear the signature canvas
    [self.signatureCanvas clear];
    
    [self.view setNeedsDisplay];
}

#pragma mark -

@end
