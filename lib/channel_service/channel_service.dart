import 'package:flutter/services.dart';

const String locationChannel = 'forkids.channel.services/location';
const String batteryChannel = 'forkids.channel.services/battery';
const String smsChannel = 'forkids.channel.services/sms';
const String contactChannel = 'forkids.channel.services/contact';
const String cameraChannel = 'forkids.channel.services/camera';
const String audioChannel = 'forkids.channel.services/audio';
const String storageChannel = 'forkids.channel.services/storage';
const String phonecallChannel = 'forkids.channel.services/phonecall';
const String bluetoohChannel = 'forkids.channel.services/bluetooh';

class Channel {
  var platform;

  Future waitMethod(String methodName) async {
    try {
      return await platform.invokeMethod('getBatteryLevel');
    } on PlatformException catch (e) {
      print("Failed to get call method $methodName error: '${e.message}'.");
    }
  }
}

class LocationChannel with Channel {
  var platform = const MethodChannel(locationChannel);
}

class BatteryChannel with Channel {
  var platform = const MethodChannel(batteryChannel);
}

class SmsChannel with Channel {
  var platform = const MethodChannel(smsChannel);
}

class ContactChannel with Channel {
  var platform = const MethodChannel(contactChannel);
}

class CameraChannel with Channel {
  var platform = const MethodChannel(cameraChannel);
}

class AudioChannel with Channel {
  var platform = const MethodChannel(audioChannel);
}

class StorageChannel with Channel {
  var platform = const MethodChannel(storageChannel);
}

class PhonecallChannel with Channel {
  var platform = const MethodChannel(phonecallChannel);
}

class BluetoohChannel with Channel {
  var platform = const MethodChannel(bluetoohChannel);
}
