/* Copyright 2017 Urban Airship and Contributors */

import AirshipKit

open class GimbalAdapter {

    /**
     * Singleton access.
     */
    open static let shared = GimbalAdapter()


    /**
     * Receives forwarded callbacks from the GMBLPlaceManagerDelegate
     */
    open var delegate: GMBLPlaceManagerDelegate?

    /**
     * Returns true if the adapter is started, otherwise false.
     */
    open var isStarted: Bool {
        get {
            return Gimbal.isStarted()
        }
    }

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
        placeManager = GMBLPlaceManager()
        gimbalDelegate = GimbalDelegate()
        deviceAttributesManager = GMBLDeviceAttributesManager()
        placeManager.delegate = gimbalDelegate

        // Hide the BLE power status alert to prevent duplicate alerts
        if (UserDefaults.standard.value(forKey: hideBlueToothAlertViewKey) == nil) {
            UserDefaults.standard.set(true, forKey: hideBlueToothAlertViewKey)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GimbalAdapter.updateDeviceAttributes),
                                               name: NSNotification.Name(UAChannelCreatedEvent),
                                               object: nil)
    }

    /**
     * Restores the adapter. Should be called in didFinishLaunchingWithOptions.
     */
    open func restore() {
        updateDeviceAttributes()
    }

    /**
     * Starts the adapter.
     * @param apiKey The Gimbal API key.
     */
    open func start(_ apiKey: String?) {
        Gimbal.setAPIKey(apiKey, options: nil)
        Gimbal.start()
        updateDeviceAttributes()
        print("Started Gimbal Adapter. Gimbal application instance identifier: \(Gimbal.applicationInstanceIdentifier())")
    }

    /**
     * Stops the adapter.
     */
    open func stop() {
        Gimbal.stop()
        print("Stopped Gimbal Adapter");
    }

    @objc private func updateDeviceAttributes() {
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

        let identifiers = UAirship.shared().analytics.currentAssociatedDeviceIdentifiers()
        identifiers.setIdentifier(Gimbal.applicationInstanceIdentifier(), forKey: "com.urbanairship.gimbal.aii")
        UAirship.shared().analytics.associateDeviceIdentifiers(identifiers);
    }
}

private class GimbalDelegate : NSObject, GMBLPlaceManagerDelegate {
    private let source: String = "Gimbal"

    func placeManager(_ manager: GMBLPlaceManager, didBegin visit: GMBLVisit) {
        let regionEvent: UARegionEvent = UARegionEvent(regionID: visit.place.identifier, source: source, boundaryEvent: .enter)!
        UAirship.shared().analytics.add(regionEvent)
        GimbalAdapter.shared.delegate?.placeManager?(manager, didBegin: visit)
    }

    func placeManager(_ manager: GMBLPlaceManager!, didBegin visit: GMBLVisit!, withDelay delayTime: TimeInterval) {
        GimbalAdapter.shared.delegate?.placeManager?(manager, didBegin: visit, withDelay: delayTime)
    }

    func placeManager(_ manager: GMBLPlaceManager, didEnd visit: GMBLVisit) {
        let regionEvent: UARegionEvent = UARegionEvent(regionID: visit.place.identifier, source: source, boundaryEvent: .exit)!
        UAirship.shared().analytics.add(regionEvent)
        GimbalAdapter.shared.delegate?.placeManager?(manager, didEnd: visit)
    }

    func placeManager(_ manager: GMBLPlaceManager!, didReceive sighting: GMBLBeaconSighting!, forVisits visits: [Any]!) {
        GimbalAdapter.shared.delegate?.placeManager?(manager, didReceive: sighting, forVisits: visits)
    }

    func placeManager(_ manager: GMBLPlaceManager!, didDetect location: CLLocation!) {
        GimbalAdapter.shared.delegate?.placeManager?(manager, didDetect: location)
    }
}
