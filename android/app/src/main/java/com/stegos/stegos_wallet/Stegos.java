
package com.stegos.stegos_wallet;

import java.io.File;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;

public class Stegos extends Service {

  private static final String TAG = "stegos";

  static {
    System.loadLibrary("stegos");
  }

  private static native int init(String chain, String data_dir, String api_token, String api_endpoint);

  private final IBinder binder = new StegosServiceBinder();

  private Thread worker;

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    return START_STICKY;
  }

  @Override
  public IBinder onBind(Intent intent) {
    return binder;
  }

  @Override
  public void onCreate() {
    super.onCreate();
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
  }

  // Cache dir:
  // /data/user/0/com.stegos.stegos_wallet/cache

  synchronized void start() {
    if (worker != null && worker.isAlive()) {
      Log.w(TAG, "Stegos node is active, skpping start request");
      return;
    }
    Log.i(TAG, "Starting node thread!");
    worker = new Thread(() -> {
      File dir = getCacheDir();
      Log.i(TAG, "Node data dir: " + dir);
      int code = 0;
      try {
        // todo: hardcoded
        code = init("testnet", dir.toString(), "xPM4oRn0/GintAaKOZA6Qw==", "127.0.0.1:3145");
      } catch (Throwable tr) {
        Log.e(TAG, "Stegos node inialization faile", tr);
      }
      Log.w(TAG, "Stegos node exited. Code: " + code);
    });
    worker.start();
  }

  synchronized void stop() {
    if (worker != null) {
      try {
        worker.stop(); // FIXME: !!! We do not have good shutdown methods for node
      } catch (Throwable tr) {
        Log.e(TAG, "Error stopping stegos node", tr);
      } finally {
        Log.w(TAG, "Stegos node stopped");
        worker = null;
      }
    }
  }

  public class StegosServiceBinder extends Binder {
    public Stegos getService() {
      return Stegos.this;
    }
  }
}