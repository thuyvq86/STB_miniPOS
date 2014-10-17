//
//  ConfigurationTest_007.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICSignatureView.h"

@protocol SignatureViewDelegate <NSObject>
@required
- (void)signatureWithImage:(UIImage *)signature;

@end

@interface STBSignatureViewController : STBBaseViewController {
    __weak IBOutlet UIButton *_btnCancel;
    __weak IBOutlet UIButton *_btnSubmit;
    __weak IBOutlet UIScrollView *_scrollView;
}
@property (nonatomic, unsafe_unretained) id<SignatureViewDelegate> delegate;

@end
