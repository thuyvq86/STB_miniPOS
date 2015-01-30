//
//  ConfigurationTest_007.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "STBSignatureViewController.h"

@interface STBSignatureViewController(){
    ICSignatureView *_signatureView;
}
@property (nonatomic, strong) ICSignatureView *signatureView;

@end

@implementation STBSignatureViewController

@synthesize delegate;
@synthesize signatureView = _signatureView;
@synthesize posMessage = _posMessage;

+ (NSString *)title {
	return @"Signature Capture";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
    CGRect frame = CGRectSetPos(_scrollView.frame, 0, 0);
	self.signatureView = [[ICSignatureView alloc] initWithFrame:frame];
    [_signatureView setUserInteractionEnabled:YES];
    [_signatureView setBlackBackground:NO];
	[_scrollView addSubview:_signatureView];
	[_scrollView setScrollEnabled:NO];
    
    [self doSignatureCapture];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _txtEmail.text = _posMessage.email;
}

- (void)doSignatureCapture{
	[_signatureView clear];
	[_signatureView setUserInteractionEnabled:YES];
	[_signatureView setExclusiveTouch:NO];
}

#pragma mark - Handle User's actions

- (IBAction)buttonDoneTouch:(id)sender {
    UIImage *signature = [_signatureView getSignatureDataAtBoundingBox];
    UIImage *scaledImage = [self imageWithImage:signature scaledToSize:CGSizeMake(200, 200)];
    
    [delegate signatureWithImage:scaledImage email:_txtEmail.text];
}

- (IBAction)buttonCancelTouch:(id)sender {
    DLog(@"Signature Capture Aborted");
    [delegate signatureWithImage:nil email:_txtEmail.text];
}

#pragma mark - Helpers

- (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a bitmap context.
    UIGraphicsBeginImageContextWithOptions(newSize, YES, image.scale);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end
