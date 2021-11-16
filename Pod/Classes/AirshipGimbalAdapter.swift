/* Copyright Airship and Contributors */

import AirshipKit

import Gimbal

@objc open class AirshipGimbalAdapter : NSObject {

    /**
     * Singleton access.
     */
    @objc public static let shared = AirshipGimbalAdapter()

    #if !targetEnvironment(simulator)

    /**
     * Receives forwarded callbacks from the PlaceManagerDelegate
     */
    @objc open var delegate: PlaceManagerDelegate?

    private let placeManager: PlaceManager
    private let gimbalDelegate: AirshipGimbalDelegate
    private let deviceAttributesManager: DeviceAttributesManager
    
    #endif
    
    /**
     * Returns true if the adapter is started, otherwise false.
     */
    @objc open var isStarted: Bool {
        get {
            #if !targetEnvironment(simulator)
            return Gimbal.isStarted()
            #else
            return false
            #endif
        }
    }

    // Keys
    private let hideBlueToothAlertViewKey = "gmbl_hide_bt_power_alert_view"
  

    /**
     * Enables alert when Bluetooth is powered off. Defaults to NO.
     */
    @objc open var bluetoothPoweredOffAlertEnabled : Bool {
        get {
            return !UserDefaults.standard.bool(forKey: hideBlueToothAlertViewKey)
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: hideBlueToothAlertViewKey)
        }
    }
    
    #if !targetEnvironment(simulator)
    private override init() {
        placeManager = PlaceManager()
        gimbalDelegate = AirshipGimbalDelegate()
        deviceAttributesManager = DeviceAttributesManager()
        placeManager.delegate = gimbalDelegate

        super.init();

        // Hide the BLE power status alert to prevent duplicate alerts
        if (UserDefaults.standard.value(forKey: hideBlueToothAlertViewKey) == nil) {
            UserDefaults.standard.set(true, forKey: hideBlueToothAlertViewKey)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AirshipGimbalAdapter.updateDeviceAttributes),
                                               name: Channel.channelCreatedEvent,
                                               object: nil)
    }
    #endif

    /**
     * Restores the adapter. Should be called in didFinishLaunchingWithOptions.
     */
    @objc open func restore() {
        updateDeviceAttributes()
    }

    /**
     * Starts the adapter.
     * @param apiKey The Gimbal API key.
     */
    @objc open func start(_ apiKey: String?) {
        #if !targetEnvironment(simulator)
        guard let key = apiKey else {
            print("Unable to start Gimbal Adapter, missing key")
            return
        }

        Gimbal.setAPIKey(key, options: nil)
        Gimbal.start()
        updateDeviceAttributes()
        print("Started Gimbal Adapter. Gimbal application instance identifier: \(Gimbal.applicationInstanceIdentifier() ?? "⚠️ Empty Gimbal application instance identifier")")
        #endif
    }

    /**
     * Stops the adapter.
     */
    @objc open func stop() {
        #if !targetEnvironment(simulator)
        Gimbal.stop()
        print("Stopped Gimbal Adapter");
        #endif
    }

    @objc private func updateDeviceAttributes() {
        #if !targetEnvironment(simulator)
        var deviceAttributes = Dictionary<AnyHashable, Any>()

        if (deviceAttributesManager.getDeviceAttributes().count > 0) {
            for (key,val) in deviceAttributesManager.getDeviceAttributes() {
                deviceAttributes[key] = val
            }
        }
        
        deviceAttributes["ua.nameduser.id"] = Airship.contact.namedUserID
        deviceAttributes["ua.channel.id"] = Airship.channel.identifier

        if (deviceAttributes.count > 0) {
            deviceAttributesManager.setDeviceAttributes(deviceAttributes)
        }

        let identifiers = Airship.analytics.currentAssociatedDeviceIdentifiers()
        identifiers.set(identifier: Gimbal.applicationInstanceIdentifier(), key: "com.urbanairship.gimbal.aii")
        Airship.analytics.associateDeviceIdentifiers(identifiers)
        #endif
    }
}

#if !targetEnvironment(simulator)
private class AirshipGimbalDelegate : NSObject, PlaceManagerDelegate {
    private let source: String = "Gimbal"

    func placeManager(_ manager: PlaceManager, didBegin visit: Visit) {
        if let regionEvent = RegionEvent(regionID: visit.place.identifier,
                                      source: source,
                                         boundaryEvent: .enter) {
            Airship.analytics.addEvent(regionEvent)
        }
        
        AirshipGimbalAdapter.shared.delegate?.placeManager?(manager, didBegin: visit)
    }

    func placeManager(_ manager: PlaceManager, didBegin visit: Visit, withDelay delayTime: TimeInterval) {
        if let regionEvent = RegionEvent(regionID: visit.place.identifier, source: source, boundaryEvent: .enter) {
            Airship.analytics.addEvent(regionEvent)
        }
        AirshipGimbalAdapter.shared.delegate?.placeManager?(manager, didBegin: visit, withDelay: delayTime)
    }

    func placeManager(_ manager: PlaceManager, didEnd visit: Visit) {
        if let regionEvent = RegionEvent(regionID: visit.place.identifier, source: source, boundaryEvent: .exit) {
            Airship.analytics.addEvent(regionEvent)
        }
        AirshipGimbalAdapter.shared.delegate?.placeManager?(manager, didEnd: visit)
    }

    func placeManager(_ manager: PlaceManager, didReceive sighting: BeaconSighting, forVisits visits: [Any]) {
        AirshipGimbalAdapter.shared.delegate?.placeManager?(manager, didReceive: sighting, forVisits: visits)
    }

    func placeManager(_ manager: PlaceManager, didDetect location: CLLocation) {
        AirshipGimbalAdapter.shared.delegate?.placeManager?(manager, didDetect: location)
    }
}
#endif
