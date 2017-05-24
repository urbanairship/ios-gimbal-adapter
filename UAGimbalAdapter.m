/* Copyright 2016 Urban Airship and Contributors */

#import "UAGimbalAdapter.h"

#import <Gimbal/Gimbal.h>
@import AirshipKit;

@interface UAGimbalAdapter() <GMBLPlaceManagerDelegate>
@property (nonatomic, strong) GMBLPlaceManager *placeManager;
@property (nonatomic) GMBLDeviceAttributesManager * deviceAttributesManager;
@property (nonatomic, assign, getter=isStarted) BOOL started;
@end

NSString *const GimbalSource = @"Gimbal";

// NSUserDefault Keys
NSString *const GimbalAlertViewKey = @"gmbl_hide_bt_power_alert_view";

@implementation UAGimbalAdapter

static id _sharedObject = nil;

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:[UAGimbalAdapter class]
                                             selector:@selector(handleAppDidFinishLaunching)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
}

+ (void)handleAppDidFinishLaunching {
    [[NSNotificationCenter defaultCenter] removeObserver:[UAGimbalAdapter class]
                                                    name:UIApplicationDidFinishLaunchingNotification
                                                  object:nil];
    [[UAGimbalAdapter shared] restore];
}

+ (instancetype)shared {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.placeManager = [[GMBLPlaceManager alloc] init];
        self.deviceAttributesManager = [GMBLDeviceAttributesManager new];

        // Hide the power alert by default
        if (![[NSUserDefaults standardUserDefaults] valueForKey:GimbalAlertViewKey]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GimbalAlertViewKey];
        }
    }

    return self;
}

- (void)dealloc {
    self.placeManager.delegate = nil;
}

- (void)restore {
    self.started = [Gimbal isStarted];
    self.placeManager.delegate = self;
    [self setDeviceAttributes];
}

- (BOOL)isBluetoothPoweredOffAlertEnabled {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:GimbalAlertViewKey];
}

- (void)setBluetoothPoweredOffAlertEnabled:(BOOL)bluetoothPoweredOffAlertEnabled {
    [[NSUserDefaults standardUserDefaults] setBool:!bluetoothPoweredOffAlertEnabled
                                            forKey:GimbalAlertViewKey];
}

- (void)startWithGimbalAPIKey:(NSString *)gimbalAPIKey {
    [Gimbal setAPIKey:gimbalAPIKey options:nil];
    [Gimbal start];
    self.started = YES;
    self.placeManager.delegate = self;
    [self setDeviceAttributes];
    UA_LDEBUG(@"Started Gimbal Adapter. Gimbal application instance identifier: %@", [Gimbal applicationInstanceIdentifier]);
}

- (void)setDeviceAttributes {
    NSMutableDictionary *deviceAttributes = [NSMutableDictionary new];
    if ([[self.deviceAttributesManager getDeviceAttributes] count] > 0) {
        [deviceAttributes addEntriesFromDictionary:[self.deviceAttributesManager getDeviceAttributes]];
    }
    if ([UAirship namedUser].identifier) {
        [deviceAttributes setObject:[UAirship namedUser].identifier forKey:@"ua.nameduser.id"];
    }
    if ([UAirship push].channelID) {
        [deviceAttributes setObject:[UAirship push].channelID forKey:@"ua.channel.id"];
    }
    if (deviceAttributes.count > 0) {
        [self.deviceAttributesManager setDeviceAttributes:deviceAttributes];
        UA_LDEBUG(@"Set Gimbal Device Attributes: %@", [deviceAttributes description]);
    }
}

- (void)stop {
    [Gimbal stop];
    self.started = NO;
    self.placeManager.delegate = nil;
    UA_LDEBUG(@"Stopped Gimbal Adapter.");
}

#pragma mark Gimbal place callbacks

- (void)placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit {
    UA_LDEBUG(@"Entered a Gimbal Place: %@ on the following date: %@", visit.place.name, visit.arrivalDate);
    UARegionEvent *regionEvent = [UARegionEvent regionEventWithRegionID:visit.place.identifier
                                                                 source:GimbalSource
                                                          boundaryEvent:UABoundaryEventEnter];

    [[UAirship shared].analytics addEvent:regionEvent];
}

- (void)placeManager:(GMBLPlaceManager *)manager didEndVisit:(GMBLVisit *)visit {
    UA_LDEBUG(@"Exited a Gimbal Place: %@ Entrance date:%@ Exit Date:%@", visit.place.name, visit.arrivalDate, visit.departureDate);
    UARegionEvent *regionEvent = [UARegionEvent regionEventWithRegionID:visit.place.identifier
                                                                 source:GimbalSource
                                                          boundaryEvent:UABoundaryEventExit];
    [[UAirship shared].analytics addEvent:regionEvent];
}


@end
