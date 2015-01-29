//
//  BCRTest_012.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 01/08/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicBarcodeReaderTest.h"


@interface BCRTest_011 : BasicBarcodeReaderTest<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIButton        * buttonCapture;
    UIWebView       * webView;
}

@end
