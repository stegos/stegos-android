
package com.stegos.stegos_wallet;

import java.io.File;
import java.util.Objects;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import androidx.core.app.NotificationCompat;

public class Stegos extends Service {

  private static final String TAG = "stegos_node";

  private static boolean libraryLoaded;

  static {
    try {
      System.loadLibrary("stegos");
      libraryLoaded = true;
    } catch (Throwable e) {
      Log.e(TAG, "Failed to load stegos library, stegos node will not be available", e);
    }
  }

  private static native int init(String chain, String data_dir, String api_token, String api_endpoint);

  private static native int shutdown();

  private static native int restart();

  private static final int FOREGROUND_ID = 1;

  private final IBinder binder = new Binder();

  private Thread worker;

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    super.onStartCommand(intent, flags, startId);
    if (flags == 0) {
      initChannels(getApplicationContext());
    }
    Intent notificationIntent = new Intent(this, MainActivity.class);
    PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);
    NotificationCompat.Builder nb;
    if (Build.VERSION.SDK_INT < 26) {
      // noinspection deprecation
      nb = new NotificationCompat.Builder(this);
    } else {
      nb = new NotificationCompat.Builder(this, "node");
    }
    // todo: review
    nb.setContentTitle("Stegos").setContentText("Stegos node is active...").setContentIntent(pendingIntent);
    startForeground(FOREGROUND_ID, nb.build());

    String network = Objects.requireNonNull(intent.getStringExtra("network"));
    String apiToken = Objects.requireNonNull(intent.getStringExtra("apiToken"));
    startBackgroundWork(network, apiToken);

    return START_REDELIVER_INTENT;
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
    Log.w(TAG, "Stegos node destroyed");
    try {
      stopForeground(true); // todo: needed?
    } finally {
      stopBackgroundWork();
    }
    super.onDestroy();
  }

  private void initChannels(Context context) {
    if (Build.VERSION.SDK_INT < 26) {
      return;
    }
    NotificationManager notificationManager = (NotificationManager) context
        .getSystemService(Context.NOTIFICATION_SERVICE);
    notificationManager.createNotificationChannel(
        new NotificationChannel("node", "Stegos node", NotificationManager.IMPORTANCE_DEFAULT));
  }

  private synchronized void startBackgroundWork(String network, String apiToken) {
    if (!libraryLoaded) {
      Log.w(TAG, "Stegos node native library is not loaded");
      return;
    }
    if (worker != null && worker.isAlive()) {
      Log.w(TAG, "Stegos node is active, skpping start request");
      return;
    }
    worker = new Thread(() -> {
      File dir = new File(getCacheDir(), network);
      Log.i(TAG, "Node data dir: " + dir);
      int code = 0;
      try {
        code = init(network, dir.toString(), apiToken, "127.0.0.1:3145");
      } catch (Throwable tr) {
        Log.e(TAG, "Stegos node inialization failed", tr);
      }
      Log.w(TAG, "Stegos node exited. Code: " + code);
    });
    worker.start();
  }

  private synchronized void stopBackgroundWork() {
    if (!libraryLoaded) {
      Log.w(TAG, "Stegos node native library is not loaded");
      return;
    }
    int code = 0;
    if (worker != null) {
      try {
        code = shutdown();
        worker.join(); // FIXME: !!! We do not have good shutdown methods for node
      } catch (Throwable tr) {
        Log.e(TAG, "Error stopping stegos node", tr);
      } finally {
        Log.w(TAG, "Stegos node stopped. Code: " + code);
        worker = null;
      }
    }
  }
}