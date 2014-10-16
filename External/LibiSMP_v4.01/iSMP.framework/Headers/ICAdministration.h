//
//  ICAdministration.h
//  PCL Library
//
//  Created by Hichem Boussetta on 19/07/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ICISMPDevice.h"

typedef struct {
	NSInteger		serialNumber;                       /**< The device's truncated serial number (8 last digits) */
	NSInteger		reference;                          /**< The device's part number */
	char			protocol[20];                       /**< The payment protocol used by the device */
} ICDeviceInformation;

enum eICDeviceKeys {
	ICNum0			= '0',                              /**< Numeric Key 0 */
	ICNum1			= '1',                              /**< Numeric Key 1 */
	ICNum2			= '2',                              /**< Numeric Key 2 */
	ICNum3			= '3',                              /**< Numeric Key 3 */
	ICNum4			= '4',                              /**< Numeric Key 4 */
	ICNum5			= '5',                              /**< Numeric Key 5 */
	ICNum6			= '6',                              /**< Numeric Key 6 */
	ICNum7			= '7',                              /**< Numeric Key 7 */
	ICNum8			= '8',                              /**< Numeric Key 8 */
	ICNum9			= '9',                              /**< Numeric Key 9 */
	ICKeyDot		= '.',                              /**< Dot Key */
	ICKeyPaperFeed	= 0x07,                             /**< Paper Feed Key */
	ICKeyGreen		= 0x16,                             /**< Green Key */
	ICKeyRed		= 0x17,                             /**< Red Key */
	ICKeyYellow		= 0x18,                             /**< Yellow Key */
	ICKeyF1			= 0x19,                             /**< F1 Key */
	ICKeyF2			= 0x20,                             /**< F2 Key */
	ICKeyF3			= 0x21,                             /**< F3 Key */
	ICKeyF4			= 0x22,                             /**< F4 Key */
	ICKeyUp			= 0x23,                             /**< UP Key */
	ICKeyDown		= 0x24,                             /**< Down Key */
	ICKeyOK			= 0x25,                             /**< OK Key */
	ICKeyC			= 0x26,                             /**< C Key */
	ICKeyF			= 0x28,                             /**< F Key */
};

enum eICDeviceSoftwareComponentType {
	ICDeviceApplication = 0,                            /**< Application */
	ICDeviceLibrary,                                    /**< Library */
	ICDeviceDriver,                                     /**< Driver */
	ICDeviceParameter                                   /**< Parameter File */
};

typedef enum {
    SPP_Apple                                           /**< SPP Apple */
} iSMPPeripheral;

@interface ICSoftwareComponent : NSObject

@property (nonatomic, readonly) NSString * name;

@property (nonatomic, readonly) NSString * version;

@property (nonatomic, readonly) NSString * crc;

@property (nonatomic, readonly) NSUInteger type;

@end

@protocol ICAdministrationDelegate;

@interface ICAdministration : ICISMPDevice {
	
	NSMutableArray				* _printerJobs;                             /**< List of in progress printer jobs */

	BOOL						  _isWaitingForSignature;                   /**< Boolean value indicating whether ICAdministration is waiting for a signature to be returned by the application*/
	
	NSDictionary				* _fontTable;                               /**< Table of fonts used for printing */
	
	BOOL						_shouldUpdatePowerManagementSettings;       /**< Boolean value indicating whether the power management settings should be updated */

    NSUInteger                  _doTransactionTimeout;                      /**< Timeout value used for @ref doTransaction */
}

+(id) sharedChannel;

@property (nonatomic, assign) id<ICISMPDeviceDelegate,ICAdministrationDelegate> delegate;

-(iSMPResult)open;

-(void)close;

#pragma mark Power Management

@property (nonatomic, readonly) NSInteger backlightTimeout;

@property (nonatomic, readonly) NSInteger suspendTimeout;

@property (nonatomic, readonly) NSInteger batteryLevel;

-(BOOL)setBacklightTimeout:(NSUInteger)backlightTimeout andSuspendTimeout:(NSUInteger)suspendTimeout;

#pragma mark -
#pragma mark Companion Management

-(BOOL)setDate;

-(NSDate *)getDate;

-(BOOL)isIdle;

-(int)getPeripheralStatus:(iSMPPeripheral)device;

-(ICDeviceInformation)getInformation;

-(NSString*)getFullSerialNumber;

-(void)reset:(NSUInteger)resetInfo;

-(BOOL)simulateKey:(NSUInteger)key;

-(NSArray *)getSoftwareComponents;

-(BOOL)startRemoteDownload;

-(iSMPResult)updateEncryptionKeyWithServerIP:(NSString *)ip andPort:(NSUInteger)port;

-(iSMPResult)updateEncryptionKeyWithServerByHostName:(NSString *)hostname andPort:(NSUInteger)port;

-(iSMPResult)validateEncryptionKey;

-(iSMPResult)eraseEncryptionKey;

-(BOOL)setServerConnectionState:(BOOL)connectionState;

#pragma mark -

@end

#pragma mark ICAdministrationDelegate

@protocol ICAdministrationDelegate
@optional

-(void)shouldScheduleWakeUpNotification:(id)wakeUpNotification;

-(void)confLogEntry:(NSString*)message withSeverity:(int)severity;

-(void)confSerialData:(NSData*)data incoming:(BOOL)isIncoming;

@end

#pragma mark -
