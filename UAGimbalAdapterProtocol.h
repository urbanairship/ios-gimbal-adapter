/* Copyright 2017 Urban Airship and Contributors */

#import <Foundation/Foundation.h>
#import <Gimbal/Gimbal.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Receives forwarded callbacks from the GMBLPlaceManagerDelegate
 */
@protocol UAGimbalAdapterProtocol

/*!
 Tells the delegate that the user entered the specified place
 @param manager The place manager object reporting the event
 @param visit An object containing place and date information about a new visit.
 */
- (void)placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit;

/*!
 Tells the delegate that the user entered the specified place
 and remained at the specified place with out exiting for the delay
 time period assigned to the place in manager.gimbal.com. Places
 with no assigned delay will call the delegate immediatly upon entry
 @param manager The place manager object reporting the event
 @param visit An object containing place and date information about a new visit.
 @param delayTime The amount of time between the entry to the place and
 when the delegate gets called back
 */
- (void)placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit withDelay:(NSTimeInterval)delayTime;

/*!
 Tells the delegate that a beacon in a place with a current visit was sighted.
 The delegate will get called back opportunistically - generally, no more often than every
 minute. This callback only applies to beacons, not to geofences.
 @param manager The place manager object reporting the event
 @param sighting Information about the beacon sighting
 @param visits An array of active GMBLVisit objects for places containing this beacon
 */
- (void)placeManager:(GMBLPlaceManager *)manager didReceiveBeaconSighting:(GMBLBeaconSighting *)sighting forVisits:(NSArray *)visits;

/*!
 Tells the delegate that the user exited the specified place
 @param manager The place manager object reporting the event
 @param visit An object containing place and date information about a visit that ended.
 */
- (void)placeManager:(GMBLPlaceManager *)manager didEndVisit:(GMBLVisit *)visit;

/*!
 Tells the delegate that the user is currently at a specific location
 @param manager The place manager object reporting the event
 @param location An object containing latitude, longitude and horizontal accuracy.
 */
- (void)placeManager:(GMBLPlaceManager *)manager didDetectLocation:(CLLocation *)location;

@end

NS_ASSUME_NONNULL_END
