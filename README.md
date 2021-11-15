# Airship iOS Gimbal Adapter

The Airship Gimbal Adapter is a drop-in class that allows users to integrate Gimbal place events with Airship.

## Resources
- [Gimbal Developer Guide](https://gimbal.com/doc/iosdocs/v2/devguide.html)
- [Gimbal Manager Portal](https://manager.gimbal.com)
- [Airship Getting Started guide](http://docs.airship.com/build/ios.html)

## Installation

The Airship Gimbal Adapter is available through CocoaPods. To install it, simply add the following line to your Podfile:

`pod "AirshipGimbalAdapter"`

## Usage

### Importing

#### Swift

```
import AirshipGimbalAdapter
```

#### Obj-C

```
@import AirshipGimbalAdapter
```

### Restoring the adapter

In your application delegate call `restore` during `didFinishLaunchingWithOptions`:

#### Swift

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

   // after Airship.takeOff   
   AirshipGimbalAdapter.shared.restore()

   ...
}
```

#### Obj-C

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

   // after UAirship.takeOff
   [[AirshpGimbalAdapter shared] restore];

   ...
}
```

Restore will automatically resume the adapter on application launch.


### Starting the adapter

#### Swift

```
AirshipGimbalAdapter.shared.start("## PLACE YOUR API KEY HERE ##")
```

#### Obj-C

```
[[AirshpGimbalAdapter shared] start:@"## PLACE YOUR API KEY HERE ##"];
```

### Stopping the adapter

#### Swift

```
AirshipGimbalAdapter.shared.stop()
```

#### Obj-C

```
[[AirshpGimbalAdapter shared] stop];
```

### Enabling Bluetooth Warning

In the event that Bluetooth is disabled during place monitoring, the Gimbal Adapter can prompt users with an alert view
to enable Bluetooth. This functionality is disabled by default, but can be enabled by setting AirshipGimbalAdapter's
`bluetoothPoweredOffAlertEnabled` property to true:

#### Swift

```
AirshipGimbalAdapter.shared.bluetoothPoweredOffAlertEnabled = true
```

#### Obj-C

```
[AirshpGimbalAdapter shared].bluetoothPoweredOffAlertEnabled = YES;
```
