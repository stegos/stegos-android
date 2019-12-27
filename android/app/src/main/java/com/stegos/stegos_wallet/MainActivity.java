package com.stegos.stegos_wallet;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {

  private static final String TAG = "stegos";

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
    //initChannels(getApplicationContext());
    GeneratedPluginRegistrant.registerWith(this);
  }


  private void startStegosNode() {
    if (service == null) {
      Log.i(TAG, "Connecting to stegos service");
      Intent intent = new Intent(this, Stegos.class);
      startService(intent);
      bindService(intent, connection, Context.BIND_AUTO_CREATE);
    } else {
      Log.i(TAG, "Service already connected!");
    }
  }

  private void stopStegosNode() {
    unbindService(connection);
    if (service != null) {
      Intent intent = new Intent(this, Stegos.class);
      stopService(intent);
      service = null;
    }
  }


  @Override
  protected void onStart() {
    super.onStart();
    startStegosNode();
  }
  
  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    // TODO:
  }
}