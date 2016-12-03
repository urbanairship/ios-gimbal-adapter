/* Copyright 2016 Urban Airship and Contributors */

import AirshipKit

open class GimbalAdapter {

    /**
     * Singleton access.
     */
    open static let shared = GimbalAdapter()

    /**
     * Returns true if the adapter is started, otherwise false.
     */
    open private(set) var isStarted: Bool

    // Keys
    private let hideBlueToothAlertViewKey = "gmbl_hide_bt_power_alert_view"

    private let placeManager: GMBLPlaceManager
    private let gimbalDelegate: GimbalDelegate

    /**
     * Enables alert when Bluetooth is powered off. Defaults to NO.
     */
    open var bluetoothPoweredOffAlertEnabled : Bool {
        get {
            return !UserDefaults.standard.bool(forKey: hideBlueToothAlertViewKey)
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: hideBlueToothAlertViewKey)
        }
    }

    private init() {
        isStarted = false
        placeManager = GMBLPlaceManager()
        gimbalDelegate = GimbalDelegate()

        // Hide the BLE power status alert to prevent duplicate alerts
        if (UserDefaults.standard.value(forKey: hideBlueToothAlertViewKey) == nil) {
            UserDefaults.standard.set(true, forKey: hideBlueToothAlertViewKey)
        }
    }

    /**
     * Restores the adapter. Should be called in didFinishLaunchingWithOptions.
     */
    open func restore() {
        if (GMBLPlaceManager.isMonitoring()) {
            start(nil);
        }
    }

    /**
     * Starts the adapter.
     * @param apiKey The Gimbal API key.
     */
    open func start(_ apiKey: String?) {
        if (isStarted) {
            return;
        }

        if (apiKey != nil && apiKey!.isEmpty == false) {
            Gimbal.setAPIKey(apiKey, options: nil)
        } else if (!GMBLPlaceManager.isMonitoring()) {
            print("GMBLPlaceManager is not previously started and API key is not provided. Unable to start Gimbal Adapter.");
            return;
        }

        isStarted = true
        placeManager.delegate = gimbalDelegate
        GMBLPlaceManager.startMonitoring()

        print("Started Gimbal Adapter. Gimbal application instance identifier: \(Gimbal.applicationInstanceIdentifier())")
    }


    /**
     * Stops the adapter.
     */
    open func stop() {
        guard (isStarted) else {
            return
        }

        isStarted = false
        GMBLPlaceManager.stopMonitoring()
        placeManager.delegate = nil

        print("Stopped Gimbal Adapter");
    }
}

private class GimbalDelegate : NSObject, GMBLPlaceManagerDelegate {
    private let source: String = "Gimbal"

    func placeManager(_ manager: GMBLPlaceManager, didBegin visit: GMBLVisit) {
        let regionEvent: UARegionEvent = UARegionEvent(regionID: visit.place.identifier, source: source, boundaryEvent: .enter)!
        UAirship.shared().analytics.add(regionEvent)
    }

    func placeManager(_ manager: GMBLPlaceManager, didEnd visit: GMBLVisit) {
        let regionEvent: UARegionEvent = UARegionEvent(regionID: visit.place.identifier, source: source, boundaryEvent: .exit)!
        UAirship.shared().analytics.add(regionEvent)
    }
}