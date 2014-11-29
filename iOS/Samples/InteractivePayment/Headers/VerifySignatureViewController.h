//
//  VerifySignatureViewController.h
//  InteractivePayment
//
//  Created by Hichem BOUSSETTA on 23/10/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifySignatureViewController : UIViewController

@property (nonatomic, retain) UIViewController              * parent;
@property (nonatomic, retain) UIImage                       * signature;
@property (nonatomic, retain) IBOutlet UIImageView          * imageView;

-(IBAction)done;
-(IBAction)resign;

@end
