/* Copyright 2016 Urban Airship and Contributors */

#import "UAGimbalAdapter.h"

@import <Gimbal/Gimbal.h>
@import AirshipKit;

@interface UAGimbalAdapter() <GMBLPlaceManagerDelegate>
@property (nonatomic, assign, getter=isStarted) BOOL started;
@property (nonatomic, strong) GMBLPlaceManager *placeManager;
@end

NSString *const GimbalSource = @"Gimbal";

// NSUserDefault Keys
NSString *const GimbalAlertViewKey = @"gmbl_hide_bt_power_alert_view";

@implementation UAGimbalAdapter

static id _sharedObject = nil;


+ (void)load {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:[UAGimbalAdapter class]
               selector:@selector(handleAppDidFinishLaunching)
                   name:UIApplicationDidFinishLaunchingNotification object:nil];
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

+ (void)handleAppDidFinishLaunching {
    [[NSNotificationCenter defaultCenter] removeObserver:[UAGimbalAdapter class]
                                                    name:UIApplicationDidFinishLaunchingNotification
                                                  object:nil];

    if ([GMBLPlaceManager isMonitoring]) {
        [[UAGimbalAdapter shared] startWithGimbalAPIKey:nil];
    }
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

    if (gimbalAPIKey.length) {
        [Gimbal setAPIKey:gimbalAPIKey options:nil];
    } else if (![GMBLPlaceManager isMonitoring]) {
        NSLog(@"GMBLPlaceManager is not previously started and API key is not provided. Unable to start Gimbal Adapter.");
        return;
    }

    self.placeManager.delegate = self;
    [GMBLPlaceManager startMonitoring];
    self.started = YES;
    UA_LDEBUG(@"Started Gimbal Adapter. Gimbal application instance identifier: %@", [Gimbal applicationInstanceIdentifier]);
}

- (void)stop {
    if (!self.isStarted) {
        return;
    }

    [GMBLPlaceManager stopMonitoring];
    self.placeManager.delegate = nil;
    self.started = NO;

    UA_LDEBUG(@"Stopped Gimbal Adapter.");
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
