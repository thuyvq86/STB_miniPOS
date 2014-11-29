//
//  BasicTest.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <netdb.h>
#include <arpa/inet.h>
#import <netinet/in.h>
#import <ifaddrs.h>

@protocol TestProperties

+(NSString *)title;
+(NSString *)subtitle;
+(NSString *)instructions;
+(NSString *)category;
+(NSString *)prefixLetter;
+(NSString *)testNumber;

@end


@interface BasicTest : UIViewController <ICISMPDeviceDelegate, UITextFieldDelegate, TestProperties> {
	
	UILabel				* iSpmConnectionState;
	UILabel				* instructions;
	UIScrollView		* scrollView;
	UITextView			* textView;
	
	NSDate				* startDate;
	NSDate				* resignActiveDate;
	
	NSUInteger			  _vCursor;
	
	NSUInteger			  entryNumber;
	NSUInteger			  trashTextLength;
	
	NSOutputStream		* logStream;
	BOOL				  _logToFile;
}

@property (nonatomic, retain) IBOutlet UILabel * iSpmConnectionState;
@property (nonatomic, retain) IBOutlet UILabel * instructions;
@property (nonatomic, retain) IBOutlet UIScrollView * scrollView;
@property (nonatomic, retain) IBOutlet UITextView * textView;
@property (nonatomic, retain) NSOutputStream * logStream;



#pragma mark User Interface

-(void)displayDeviceState:(BOOL)ready;

-(UIButton *)addButtonWithTitle:(NSString *)title andAction:(SEL)action;
-(void)addButtonsWithTitle:(NSString *)title andTitle2:(NSString*)title2 toAction:(SEL)action;
-(UITextField *)addTextFieldWithTitle:(NSString *)title;
-(UISwitch *)addSwitchWithTitle:(NSString *)title;
-(UISegmentedControl *)addSegmentedControlWithTitle:(NSString *)title;
-(UILabel *)addLabelWithTitle:(NSString *)title;
-(UIWebView *)addWebView;

-(void)enableUserInteraction;

#pragma mark -



#pragma mark Debugging

-(void)beginTimeMeasure;

-(NSTimeInterval)endTimeMeasure;

-(void)logMessage:(NSString *)message;

-(void)clearAndLogMessage:(NSString *)message;

-(IBAction)clearLog;

-(void)applicationBecameInactive:(NSNotification *)notification;
-(void)applicationDidEnterBackground:(NSNotification *)notification;

-(void)onAccessoryDidConnect:(NSNotification *)notification;

-(void)enableLogToFile:(BOOL)enabled;

#pragma mark -


#pragma mark Helper Methods

-(NSString *)getIPAddress;

#pragma mark -


@end
