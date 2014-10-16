//
//  CLLocationManager+Block.m
//  iOS Blocks
//
//  Created by Ignacio Romero Zurbuchen on 3/8/13.
//  Copyright (c) 2011 DZN Labs.
//  Licence: MIT-Licence
//

#import "CLLocationManager+Block.h"

static ListBlock _locationBlock;
static FailureBlock _failureBlock;
static StatusBlock _statusBlock;

static BOOL const kDefaultLocationAuthorizationType = LocationUsageAuthorizationAlways;

static CLLocationManager *_sharedManager = nil;

@implementation CLLocationManager (Block)

+ (CLLocationManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[CLLocationManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)updateLocationWithDistanceFilter:(CLLocationDistance)filter
                      andDesiredAccuracy:(CLLocationAccuracy)accuracy
            andLocationAuthorizationType:(LocationUsageAuthorization)locationUsageAuthorization
            didChangeAuthorizationStatus:(StatusBlock)changedStatus
                      didUpdateLocations:(ListBlock)located
                        didFailWithError:(FailureBlock)failed
{
    _statusBlock   = [changedStatus copy];
    _locationBlock = [located copy];
    _failureBlock  = [failed copy];
    
    [[CLLocationManager sharedManager] setDelegate:weakObject(self)];
    [[CLLocationManager sharedManager] setDistanceFilter:filter];
    [[CLLocationManager sharedManager] setDesiredAccuracy:accuracy];
    switch (locationUsageAuthorization) { //iOS 8+.
        case LocationUsageAuthorizationWhenInUse:
            [self _requestWhenInUseAuthorization];
            break;
        default:
            [self _requestAlwaysAuthorization];
            break;
    }
    [[CLLocationManager sharedManager] startUpdatingLocation];
}

- (void)updateLocationWithDistanceFilter:(CLLocationDistance)filter
                      andDesiredAccuracy:(CLLocationAccuracy)accuracy
            andLocationAuthorizationType:(LocationUsageAuthorization)locationUsageAuthorization
                      didUpdateLocations:(ListBlock)located
                        didFailWithError:(FailureBlock)failed
{
    [[CLLocationManager sharedManager] updateLocationWithDistanceFilter:filter
                                                     andDesiredAccuracy:accuracy
                                           andLocationAuthorizationType:locationUsageAuthorization
                                           didChangeAuthorizationStatus:NULL
                                                     didUpdateLocations:located
                                                       didFailWithError:failed];
}

- (void)locationManagerDidUpdateLocations:(ListBlock)located
                         didFailWithError:(FailureBlock)failed
{
    [[CLLocationManager sharedManager] updateLocationWithDistanceFilter:1.0
                                                     andDesiredAccuracy:kCLLocationAccuracyBest
                                          andLocationAuthorizationType:kDefaultLocationAuthorizationType
                                           didChangeAuthorizationStatus:NULL
                                                     didUpdateLocations:located
                                                       didFailWithError:failed];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [[CLLocationManager sharedManager] stopUpdatingLocation];
    
    if (_locationBlock) {
        _locationBlock(locations);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[CLLocationManager sharedManager] stopUpdatingLocation];
    
    if (_failureBlock) {
        _failureBlock(error);
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (_statusBlock) {
        _statusBlock(status);
    }
}

#pragma mark - Private Helpers

- (void)_requestAlwaysAuthorization{
    // ** Don't forget to add NSLocationAlwaysUsageDescription in YourApp-Info.plist and give it a string
    
    // Check for iOS 8+. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([[CLLocationManager sharedManager] respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        // check to make sure that NSLocationAlwaysUsageDescription is in the bundle
//        if (![self _isUsageDescriptionPresentForAlwaysUsage])
//            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"You must set key NSLocationAlwaysUsageDescription in the YourApp-Info.plist." userInfo:nil];
        
        // Sending a message to avoid compile time error
        [[UIApplication sharedApplication] sendAction:@selector(requestAlwaysAuthorization)
                                                   to:[CLLocationManager sharedManager]
                                                 from:self
                                             forEvent:nil];
    }
}


- (void)_requestWhenInUseAuthorization{
    // ** Don't forget to add NSLocationWhenInUseUsageDescription in YourApp-Info.plist and give it a string
    
    // Check for iOS 8+. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([[CLLocationManager sharedManager] respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//        // check to make sure that NSLocationWhenInUseUsageDescription is in the bundle
//        if (![self _isUsageDescriptionPresentForWhenInUseUsage])
//            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"You must set key NSLocationWhenInUseUsageDescription in the YourApp-Info.plist." userInfo:nil];
        
        // Sending a message to avoid compile time error
        [[UIApplication sharedApplication] sendAction:@selector(requestWhenInUseAuthorization)
                                                   to:[CLLocationManager sharedManager]
                                                 from:self
                                             forEvent:nil];
    }
}

- (BOOL)_isUsageDescriptionPresentForAlwaysUsage {
    return (((NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]).length > 0);
}

- (BOOL)_isUsageDescriptionPresentForWhenInUseUsage {
    return (((NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]).length > 0);
}

@end
