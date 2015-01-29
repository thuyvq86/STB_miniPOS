//
//  CustomImagePickerController.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 03/08/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomImagePickerController : UIImagePickerController<ICISMPDeviceDelegate, ICBarCodeReaderDelegate> {
    
}

@property (nonatomic, retain) ICBarCodeReader * barcode;

@end
