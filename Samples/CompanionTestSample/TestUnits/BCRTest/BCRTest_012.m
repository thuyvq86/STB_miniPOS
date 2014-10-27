//
//  BCRTest_012.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 01/08/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "BCRTest_012.h"
#import "CameraOverlayViewController.h"
#import "CustomImagePickerController.h"


@implementation BCRTest_012



+(NSString *)title {
	return @"Snapshot";
}

+(NSString *)subtitle {
	return @"Take a snapshot with the scanner";
}

+(NSString *)instructions {
	return @"Ensure the device is ready and press the Capture button to take a snapshot";
}

+(NSString *)category {
	return @"Unit Tests";
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    buttonCapture = [self addButtonWithTitle:@"Start" andAction:@selector(capture)];
    webView = [self addWebView];
    //[self.scrollView setScrollEnabled:NO];
    self.barcodeReader = nil;
    
//    [self.barcodeReader _sendFactoryReset];
//    [self.barcodeReader configureForSnapshot];
}


//-(void)captureHelper {
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    [self.barcodeReader startScan];
//    [NSThread sleepForTimeInterval:2];
//    [self.barcodeReader snapshot];
//    [self.barcodeReader stopScan];
//    [pool release];
//}

-(void)capture {
    CustomImagePickerController * imagePickerController = [[CustomImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerController.delegate = self;
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        //imagePickerController.showsCameraControls = NO;
        CameraOverlayViewController * cameraOverlay = [[CameraOverlayViewController alloc] init];
        imagePickerController.cameraOverlayView = cameraOverlay.view;
        [cameraOverlay release];
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        [self.navigationController presentModalViewController:imagePickerController animated:YES];
    }
    
    [imagePickerController release];
}


#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:YES];
    
    UIImage * image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    [webView loadData:UIImagePNGRepresentation(image) MIMEType:@"image/png" textEncodingName:@"utf-8" baseURL:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark -


#pragma mark ICBarCodeReaderDelegate

-(void)triggerReleased {
	NSLog(@"%s", __FUNCTION__);
}

-(void)triggerPulled {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark -


@end
