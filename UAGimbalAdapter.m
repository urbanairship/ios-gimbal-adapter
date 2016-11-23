/* Copyright 2016 Urban Airship and Contributors */

#import "UAGimbalAdapter.h"
#import <Gimbal/Gimbal.h>

@import AirshipKit;


@interface UAGimbalAdapter() <GMBLPlaceManagerDelegate>
@property (nonatomic, assign, getter=isStarted) BOOL started;

@end

NSString *const GimbalSource = @"Gimbal";

// NSUserDefault Keys
NSString *const GimbalAlertViewKey = @"gmbl_hide_bt_power_alert_view";
NSString *const AdapterStartedKey = @"com.urbanairship.gimbal.started";
NSString *const GimbalKey = @"com.urbanairship.gimbal.key";

@implementation UAGimbalAdapter

static id _sharedObject = nil;


+ (void)load {
    [[UAGimbalAdapter shared] restore];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.placeManager = [[GMBLPlaceManager alloc] init];

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


+ (instancetype)shared {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}

- (BOOL)isBluetoothPoweredOffAlertEnabled {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:GimbalAlertViewKey];
}

- (void)setBluetoothPoweredOffAlertEnabled:(BOOL)bluetoothPoweredOffAlertEnabled {
    [[NSUserDefaults standardUserDefaults] setBool:!bluetoothPoweredOffAlertEnabled
                                            forKey:GimbalAlertViewKey];
}

- (void)startWithGimbalAPIKey:(NSString *)gimbalAPIKey {
    if (self.isStarted) {
        return;
    }

    [Gimbal setAPIKey:gimbalAPIKey options:nil];

    self.placeManager.delegate = self;
    [GMBLPlaceManager startMonitoring];
    self.started = YES;

    [[NSUserDefaults standardUserDefaults] setBool:YES
                                            forKey:AdapterStartedKey];

    [[NSUserDefaults standardUserDefaults] setObject:gimbalAPIKey
                                              forKey:GimbalKey];


    UA_LDEBUG(@"Started Gimbal Adapter.");
}

- (void)stop {
    if (!self.isStarted) {
        return;
    }

    [GMBLPlaceManager stopMonitoring];
    self.placeManager.delegate = nil;
    self.started = NO;

    [[NSUserDefaults standardUserDefaults] setBool:NO
                                            forKey:AdapterStartedKey];

    UA_LDEBUG(@"Stopped Gimbal Adapter.");
}

- (void)restore {
    NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:GimbalKey];
    BOOL started = [[NSUserDefaults standardUserDefaults] boolForKey:AdapterStartedKey];

    if (apiKey && started) {
        [[UAGimbalAdapter shared] startWithGimbalAPIKey:apiKey];
    }
}

#pragma mark -
#pragma mark Gimbal places callbacks

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
}


@end
