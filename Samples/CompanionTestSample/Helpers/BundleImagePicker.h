//
//  BundleImagePicker.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 07/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BundleImagePickerDelegate

-(void)bundleImagePickerDidSelectBitmapWithName:(NSString *)bitmapName;

@end


@interface BundleImagePicker : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UIImageView          * imageView;
@property (nonatomic, retain) NSArray                       * bitmapNames;
@property (nonatomic, assign) id<BundleImagePickerDelegate>   delegate;

-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;

@end
