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
	[_scrollView addSubview:_signatureView];
	[_scrollView setScrollEnabled:NO];
    
    [self doSignatureCapture];
}

- (void)doSignatureCapture{
	[_signatureView clear];
	[_signatureView setUserInteractionEnabled:YES];
	[_signatureView setExclusiveTouch:NO];
}

#pragma mark - Handle User's actions

- (IBAction)buttonDoneTouch:(id)sender {
    UIImage *signature = [_signatureView getSignatureDataAtBoundingBox];
    [delegate signatureWithImage:signature];
}

- (IBAction)buttonCancelTouch:(id)sender {
    DLog(@"Signature Capture Aborted");
    [delegate signatureWithImage:nil];
}

@end
