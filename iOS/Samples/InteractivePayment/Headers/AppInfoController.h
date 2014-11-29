//
//  AppInfoController.h
//  CardTest
//
//  Created by Hichem Boussetta on 16/11/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iSMP/revision.h>

@interface AppInfoController : UIViewController


@property (nonatomic, retain) IBOutlet UILabel          * appVersion;
@property (nonatomic, retain) IBOutlet UILabel          * libiSMPVersion;


-(IBAction)done:(id)sender;


extern void c3version(char* version, int maxlen);


@end
