/* Copyright 2016 Urban Airship and Contributors */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * GimbalAdapter interfaces Gimbal SDK functionality with Urban Airship services.
 */
@interface UAGimbalAdapter : NSObject

/**
 * Returns true if the adapter is started, otherwise false.
 */
@property (nonatomic, assign, readonly, getter=isStarted) BOOL started;

/**
 * Enables alert when Bluetooth is powered off. Defaults to NO.
 */
@property (nonatomic, assign, getter=isBluetoothPoweredOffAlertEnabled) BOOL bluetoothPoweredOffAlertEnabled;

/**
 * Returns the shared `GimbalAdapter` instance.
 *
 * @return The shared `GimbalAdapter` instance.
 */
+ (instancetype)shared;

/**
 * Starts the adapter.
 * @param gimbalAPIKey The Gimbal API key.
 */
- (void)startWithGimbalAPIKey:(NSString *)gimbalAPIKey;

/**
 * Stops the adapter.
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
