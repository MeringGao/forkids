package com.example.forkids;

import android.os.Bundle;

import java.util.ArrayList;

import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {
  private static final ArrayList<String> channelNames = new ArrayList<String>();

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    channelNames.add("forkids.channel.services/location");
    channelNames.add("forkids.channel.services/battery");
    channelNames.add("forkids.channel.services/sms");
    channelNames.add("forkids.channel.services/contact");
    channelNames.add("forkids.channel.services/camera");
    channelNames.add("forkids.channel.services/audio");
    channelNames.add("forkids.channel.services/storage");
    channelNames.add("forkids.channel.services/phonecall");
    channelNames.add("forkids.channel.services/bluetooh");
    channelNames.add("forkids.channel.services/service");
    GeneratedPluginRegistrant.registerWith(this);
  }

  private void createChannel() {
    for (String name : channelNames) {
      new MethodChannel(getFlutterView(), name).setMethodCallHandler(new MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
          if (call.method.equals("getBatteryLevel")) {
            int batteryLevel = getBatteryLevel();

            if (batteryLevel != -1) {
              result.success(batteryLevel);
            } else {
              result.error("UNAVAILABLE", "Battery level not available.", null);
            }
          } else {
            result.notImplemented();
          }
        }
      });
    }
  }

  private int getBatteryLevel() {
    return 10;
  }
}
