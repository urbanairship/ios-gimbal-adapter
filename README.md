# Urban Airship iOS Gimbal Adapter

The Urban Airship Gimbal Adapter is a drop-in class that allows users to integrate Gimbal place events with 
Urban Airship.

## Resources
- [Gimbal Developer Guide](https://gimbal.com/doc/iosdocs/v2/devguide.html)
- [Gimbal Manager Portal](https://manager.gimbal.com)
- [Urban Airship Getting Started guide](http://docs.urbanairship.com/build/ios.html)

## Requirements

Before installing the Gimbal Adapter, make sure the following dependencies are installed for you application:
 - Urban Airship SDK 8.0.0 or newer
 - Gimbal SDK 2.0.0 or newer

## Swift

#### Installation

1) Copy `GimbalAdapter.swift` into your project

2) In your application delegate, call restore during didFinishLaunchingWithOptions:

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

#### Stoping the adapter

Adapter can be stopped at anytime by calling:
```
GimbalAdapter.shared.stop()
```

#### Enabling Bluetooth Warning

In the event that Bluetooth is disabled during place monitoring, the Gimbal Adapter can prompt users with an alert view
to enable Bluetooth. This functionality is disabled by default, but can be enabled by setting GimbalAdapter's
bluetoothPoweredOffAlertEnabled property to true:

```
GimbalAdapter.shared.bluetoothPoweredOffAlertEnabled = true
```

## Objective-C

#### Installation

1) Copy `UAGimbalAdapter.h` and `UAGimbalAdapter.m` into your project


#### Starting the adapter

To start the adapter call:
```
[[UAGimbalAdapter shared] startWithGimbalAPiKey:@"## PLACE YOUR API KEY HERE ##"];
```

The adapter will automatically resume itself on next application launch. You only need to call
start once.

#### Stoping the adapter

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
