/* Copyright 2017 Urban Airship and Contributors */

import AirshipKit

open class GimbalAdapter {

    /**
     * Singleton access.
     */
    open static let shared = GimbalAdapter()

    /**
     * Returns true if the adapter is started, otherwise false.
     */
    open var isStarted: Bool {
        get {
            return Gimbal.isStarted()
        }
    }

    /**
     * Receives forwarded callbacks from the GMBLPlaceManagerDelegate
     */
    open var gimbalAdapterDelegate: GimbalAdapterProtocol?

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

        if  let delegate = GimbalAdapter.shared.gimbalAdapterDelegate {
            delegate.placeManager(manager, didBegin: visit)
        }
    }

    func placeManager(_ manager: GMBLPlaceManager!, didBegin visit: GMBLVisit!, withDelay delayTime: TimeInterval) {
        if let delegate = GimbalAdapter.shared.gimbalAdapterDelegate {
            delegate.placeManager(manager, didBegin: visit, withDelay: delayTime)
        }
    }

    func placeManager(_ manager: GMBLPlaceManager, didEnd visit: GMBLVisit) {
        let regionEvent: UARegionEvent = UARegionEvent(regionID: visit.place.identifier, source: source, boundaryEvent: .exit)!
        UAirship.shared().analytics.add(regionEvent)

        if let delegate = GimbalAdapter.shared.gimbalAdapterDelegate {
            delegate.placeManager(manager, didEnd: visit)
        }
    }

    func placeManager(_ manager: GMBLPlaceManager!, didReceive sighting: GMBLBeaconSighting!, forVisits visits: [Any]!) {
        if let delegate = GimbalAdapter.shared.gimbalAdapterDelegate {
            delegate.placeManager(manager, didReceive: sighting, forVisits: visits)
        }
    }

    func placeManager(_ manager: GMBLPlaceManager!, didDetect location: CLLocation!) {
        if let delegate = GimbalAdapter.shared.gimbalAdapterDelegate {
            delegate.placeManager(manager, didDetect: location)
        }
    }
}

/**
 * Receives forwarded callbacks from the GMBLPlaceManagerDelegate
 */
@objc public protocol GimbalAdapterProtocol {

    /*!
     Tells the delegate that the user entered the specified place
     @param manager The place manager object reporting the event
     @param visit An object containing place and date information about a new visit.
     */
    @objc func placeManager(_ manager: GMBLPlaceManager, didBegin visit: GMBLVisit);

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
    @objc func placeManager(_ manager: GMBLPlaceManager!, didBegin visit: GMBLVisit!, withDelay delayTime: TimeInterval);

    /*!
     Tells the delegate that a beacon in a place with a current visit was sighted.
     The delegate will get called back opportunistically - generally, no more often than every
     minute. This callback only applies to beacons, not to geofences.
     @param manager The place manager object reporting the event
     @param sighting Information about the beacon sighting
     @param visits An array of active GMBLVisit objects for places containing this beacon
     */
    @objc func placeManager(_ manager: GMBLPlaceManager, didEnd visit: GMBLVisit);

    /*!
     Tells the delegate that the user exited the specified place
     @param manager The place manager object reporting the event
     @param visit An object containing place and date information about a visit that ended.
     */
    @objc func placeManager(_ manager: GMBLPlaceManager!, didReceive sighting: GMBLBeaconSighting!, forVisits visits: [Any]!);

    /*!
     Tells the delegate that the user is currently at a specific location
     @param manager The place manager object reporting the event
     @param location An object containing latitude, longitude and horizontal accuracy.
     */
    @objc func placeManager(_ manager: GMBLPlaceManager!, didDetect location: CLLocation!);
}
