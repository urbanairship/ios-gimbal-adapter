

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
    private let gimbalKey = "com.urbanairship.gimbal.key"
    private let adapterStartedKey = "com.urbanairship.gimbal.started"

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
        let key = UserDefaults.standard.string(forKey: gimbalKey)
        let started = UserDefaults.standard.bool(forKey: adapterStartedKey)

        if (key != nil && started) {
            start(key!)
        }
    }

    /**
     * Starts the adapter.
     * @param apiKey The Gimbal API key.
     */
    open func start(_ apiKey: String) {
        guard (!isStarted || apiKey.isEmpty) else {
            return
        }

        Gimbal.setAPIKey(apiKey, options: nil)

        isStarted = true
        placeManager.delegate = gimbalDelegate
        GMBLPlaceManager.startMonitoring()

        UserDefaults.standard.set(apiKey, forKey: gimbalKey)
        UserDefaults.standard.set(true, forKey: adapterStartedKey)

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

        UserDefaults.standard.set(false, forKey: adapterStartedKey)

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
