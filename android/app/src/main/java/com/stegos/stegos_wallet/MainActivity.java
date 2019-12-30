package com.stegos.stegos_wallet;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {

  private static final String TAG = "stegos";

  private static final String CHANNEL = "stegos/control";

  private IBinder service;

  private ServiceConnection connection = new ServiceConnection() {

    @Override
    public void onServiceConnected(ComponentName className, IBinder service) {
      Log.i(TAG, "Stegos service connected");
      MainActivity.this.service = service;
    }

    @Override
    public void onServiceDisconnected(ComponentName cn) {
      Log.i(TAG, "Service disconnected");
      MainActivity.this.service = null;
    }
  };

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(this);
  }


  private void startStegosNode(String network, String apiToken) {
    if (service == null) {
      Log.i(TAG, "Connecting to stegos service, network: " + network);
      Intent intent = new Intent(this, Stegos.class);
      intent.putExtra("network", network);
      intent.putExtra("apiToken", apiToken);
      startService(intent);
      bindService(intent, connection, Context.BIND_AUTO_CREATE | Context.BIND_IMPORTANT);
    } else {
      Log.i(TAG, "Service already connected!");
    }
  }

  private void stopStegosNode() {
    Log.i(TAG, "Stopping stegos node");
    if (service != null) {
      unbindService(connection);
      Intent intent = new Intent(this, Stegos.class);
      stopService(intent);
      service = null;
    }
  }

  @Override
  protected void onStart() {
    super.onStart();
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    String method = call.method;
    Log.i(TAG, "On main activity call: " + method);
    try {
      switch (method) {
        case "startNode": {
          String network = call.argument("network");
          String apiToken = call.argument("apiToken");
          Log.i(TAG, "Start node network: " + network);
          startStegosNode(network, apiToken);
          result.success(null);
          break;
        }
        case "stopNode":
          stopStegosNode();
          result.success(null);
          break;
        case "nodeRunning":
          result.success(service != null);
          break;
        default:
          break;
      }
    } catch (Exception e) {
      Log.e(TAG, "onMethodCall", e);
      result.error("@stegos", e.getMessage(), null);
    }
  }
}