/* Copyright 2016 Urban Airship and Contributors */

import AirshipKit
import Gimbal

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
    private let deviceAttributesManager: GMBLDeviceAttributesManager

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
        deviceAttributesManager = GMBLDeviceAttributesManager()

        // Hide the BLE power status alert to prevent duplicate alerts
        if (UserDefaults.standard.value(forKey: hideBlueToothAlertViewKey) == nil) {
            UserDefaults.standard.set(true, forKey: hideBlueToothAlertViewKey)
        }
    }

    /**
     * Restores the adapter. Should be called in didFinishLaunchingWithOptions.
     */
    open func restore() {
        isStarted = Gimbal.isStarted()
        placeManager.delegate = gimbalDelegate
        setDeviceAttributes()
    }

    /**
     * Starts the adapter.
     * @param apiKey The Gimbal API key.
     */
    open func start(_ apiKey: String?) {
        Gimbal.setAPIKey(apiKey, options: nil)
        Gimbal.start()
        isStarted = true
        placeManager.delegate = gimbalDelegate
        setDeviceAttributes()
        print("Started Gimbal Adapter. Gimbal application instance identifier: \(Gimbal.applicationInstanceIdentifier())")
    }

    /**
     * Stops the adapter.
     */
    open func stop() {
        Gimbal.stop()
        isStarted = false
        placeManager.delegate = nil
        print("Stopped Gimbal Adapter");
    }
    
    private func setDeviceAttributes() {
        var deviceAttributes = Dictionary<AnyHashable, Any>()
        if (deviceAttributesManager.getDeviceAttributes() != nil && deviceAttributesManager.getDeviceAttributes().count > 0) {
            for (key,val) in deviceAttributesManager.getDeviceAttributes() {
                deviceAttributes[key] = val
            }
        }
        if (UAirship.namedUser().identifier != nil) {
            deviceAttributes["ua.nameduser.id"] = UAirship.namedUser().identifier
        }
        if (UAirship.push().channelID != nil) {
            deviceAttributes["ua.channel.id"] = UAirship.push().channelID
        }
        if (deviceAttributes.count > 0) {
            deviceAttributesManager.setDeviceAttributes(deviceAttributes)
        }
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
