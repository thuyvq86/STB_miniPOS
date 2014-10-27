//
//  SignatureViewController.h
//  iSMPDemo
//
//  Created by Hichem Boussetta on 15/12/11.
//  Copyright (c) 2011 Theoris. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SignatureViewController : UIViewController


@property (nonatomic, assign) UIViewController                  * parent;
@property (nonatomic, assign) CGFloat                             signatureCanvasWidth;
@property (nonatomic, assign) CGFloat                             signatureCanvasHeight;
@property (nonatomic, retain) NSString                          * amount;

@property (nonatomic, assign) IBOutlet UILabel                  * labelAmount;
@property (nonatomic, assign) IBOutlet UILabel                  * labelDisclaimer;
@property (nonatomic, assign) IBOutlet UILabel                  * labelBottomView;


-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;

-(void)provideSignatureToParentViewController:(UIImage *)signature;


-(void)onSignatureValidated:(UIImage *)signature;
-(void)onSignatureRecapture;

@end
