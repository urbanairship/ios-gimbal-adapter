# Airship iOS Gimbal Adapter

The Airship Gimbal Adapter is a drop-in class that allows users to integrate Gimbal place events with Airship.

## Resources
- [Gimbal Developer Guide](https://gimbal.com/doc/iosdocs/v2/devguide.html)
- [Gimbal Manager Portal](https://manager.gimbal.com)
- [Airship Getting Started guide](http://docs.airship.com/build/ios.html)

## Installation

The Airship Gimbal Adapter is available through CocoaPods. To install it, simply add the following line to your Podfile:

`pod "Airshp-iOS-Gimbal-Adapter"`

## Swift

#### Restoring the adapter

In your application delegate call `restore` during `didFinishLaunchingWithOptions`:

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

   GimbalAdapter.shared.restore()

   ...
}
```

Restore will automatically resume the adapter on application launch.


#### Starting the adapter

To start the adapter call:

```
GimbalAdapter.shared.start("## PLACE YOUR API KEY HERE ##")
```

#### Stopping the adapter

The adapter can be stopped at anytime by calling:

```
GimbalAdapter.shared.stop()
```

#### Enabling Bluetooth Warning

In the event that Bluetooth is disabled during place monitoring, the Gimbal Adapter can prompt users with an alert view
to enable Bluetooth. This functionality is disabled by default, but can be enabled by setting GimbalAdapter's
`bluetoothPoweredOffAlertEnabled` property to true:

```
GimbalAdapter.shared.bluetoothPoweredOffAlertEnabled = true
```

## Objective-C

#### Starting the adapter

To start the adapter call:
```
[[UAGimbalAdapter shared] startWithGimbalAPIKey:@"## PLACE YOUR API KEY HERE ##"];
```

The adapter will automatically resume itself on next application launch. You only need to call
start once.

#### Stopping the adapter

Adapter can be stopped at anytime by calling:
```
[[UAGimbalAdapter shared] stop];
```

#### Enabling Bluetooth Warning

In the event that Bluetooth is disabled during place monitoring, the Gimbal Adapter can prompt users with an alert view
to enable Bluetooth.  This functionality is disabled by default, but can be enabled by setting GimbalAdapter's
bluetoothPoweredOffAlertEnabled property to YES:

```
[UAGimbalAdapter shared].bluetoothPoweredOffAlertEnabled = YES;
```
