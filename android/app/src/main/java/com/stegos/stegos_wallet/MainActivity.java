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

  Stegos stegos;

  private ServiceConnection connection = new ServiceConnection() {

    @Override
    public void onServiceConnected(ComponentName className, IBinder service) {
      Log.i(TAG, "Stegos service connected?");
      Stegos.StegosServiceBinder binder = (Stegos.StegosServiceBinder) service;
      stegos = binder.getService();
      Log.i(TAG, "Stegos service connected: " + stegos);
      stegos.start();
    }

    @Override
    public void onServiceDisconnected(ComponentName arg0) {
      Log.i(TAG, "Service disconnected");
    }
  };

  private void connectToService() {
    if (stegos == null) {
      Log.i(TAG, "Connecting to service");
      Intent service = new Intent(this, Stegos.class);
      startService(service);
      bindService(service, connection, Context.BIND_AUTO_CREATE);
    } else {
      Log.i(TAG, "Service already connected!");
    }
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }

  @Override
  protected void onStart() {
    super.onStart();
    connectToService();
  }

  @Override
  protected void onResume() {
    super.onResume();
    connectToService();
  }

  @Override
  protected void onDestroy() {
    try {
      if (stegos != null) {
        stegos.stop();
      }
    } finally {
      stegos = null;
      super.onDestroy();
    }
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    // TODO:
  }
}