package com.lynra.vehicle.locator

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodChannel


class LocatorPresenceForegroundService : Service() {

    private companion object {
        const val FOREGROUND_NOTIFICATION_ID = 3001
    }

    private var flutterEngine: FlutterEngine? = null

    // =========================================================
    // NATIVE 30 SECOND TIMER
    // =========================================================

    private val handler =
        Handler(Looper.getMainLooper())

    private val presenceRunnable =
        object : Runnable {

            override fun run() {

                Log.e(
                    "LYNRA_SERVICE",
                    "NATIVE TIMER => tick",
                )

                flutterEngine?.let { engine ->

                    MethodChannel(
                        engine.dartExecutor.binaryMessenger,
                        "lynra/presence_service_dart",
                    ).invokeMethod(
                        "nativeTimerTick",
                        null,
                    )
                }

                handler.postDelayed(
                    this,
                    30_000L,
                )
            }
        }


    // =========================================================
    // SERVICE CREATE
    // =========================================================

    override fun onCreate() {
        super.onCreate()

        Log.e(
            "LYNRA_SERVICE",
            "Foreground service created",
        )

        startForeground(
            FOREGROUND_NOTIFICATION_ID,
            createNotification(),
        )
    }


    // =========================================================
    // SERVICE START
    // =========================================================

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int,
    ): Int {

        val locatorId =
            intent?.getStringExtra("locatorId")

        Log.e(
            "LYNRA_SERVICE",
            "locatorId=$locatorId",
        )

        Log.e(
            "LYNRA_SERVICE",
            "Foreground service started action=${intent?.action}",
        )


        // =====================================================
        // START FLUTTER ENGINE
        // =====================================================

        if (flutterEngine == null) {

            Log.e(
                "LYNRA_SERVICE",
                "Starting FlutterEngine",
            )

            flutterEngine =
                FlutterEngine(
                    applicationContext,
                )


            // =================================================
            // METHOD CHANNEL
            // =================================================

            MethodChannel(
                flutterEngine!!
                    .dartExecutor
                    .binaryMessenger,
                "lynra/presence_service",
            ).setMethodCallHandler { call, result ->

                when (call.method) {

                    // =========================================
                    // GET PRESENCE IDS
                    // =========================================

                    "getPresenceIds" -> {

                        result.success(
                            mapOf(
                                "locatorId" to locatorId,
                            )
                        )
                    }


                    // =========================================
                    // APP FOREGROUND STATE
                    // =========================================

                    "setAppForeground" -> {

                        val value =
                            call.argument<Boolean>(
                                "value"
                            ) ?: false

                        MethodChannel(
                            flutterEngine!!
                                .dartExecutor
                                .binaryMessenger,
                            "lynra/presence_service_dart",
                        ).invokeMethod(
                            "setAppForeground",
                            mapOf(
                                "value" to value,
                            ),
                        )

                        result.success(true)
                    }


                    // =========================================

                    else -> {
                        result.notImplemented()
                    }
                }
            }


            // =================================================
            // LOAD FLUTTER
            // =================================================

            val flutterLoader =
                FlutterLoader()

            flutterLoader.startInitialization(
                applicationContext,
            )

            flutterLoader
                .ensureInitializationComplete(
                    applicationContext,
                    null,
                )

            val bundlePath =
                flutterLoader.findAppBundlePath()


            // =================================================
            // START DART ENTRYPOINT
            // =================================================

            flutterEngine!!
                .dartExecutor
                .executeDartEntrypoint(
                    DartExecutor.DartEntrypoint(
                        bundlePath,
                        "locatorPresenceServiceMain",
                    )
                )


            // =================================================
            // START NATIVE TIMER
            // =================================================

            handler.removeCallbacks(
                presenceRunnable,
            )

            handler.postDelayed(
                presenceRunnable,
                30_000L,
            )

            Log.e(
                "LYNRA_SERVICE",
                "NATIVE TIMER => started",
            )
        }


        return START_STICKY
    }


    // =========================================================
    // SERVICE DESTROY
    // =========================================================

    override fun onDestroy() {

        handler.removeCallbacks(
            presenceRunnable,
        )

        Log.e(
            "LYNRA_SERVICE",
            "NATIVE TIMER => stopped",
        )

        flutterEngine?.destroy()
        flutterEngine = null

        Log.e(
            "LYNRA_SERVICE",
            "Foreground service destroyed",
        )

        super.onDestroy()
    }


    // =========================================================
    // BIND
    // =========================================================

    override fun onBind(
        intent: Intent?,
    ): IBinder? {

        return null
    }


    // =========================================================
    // NOTIFICATION
    // =========================================================

    private fun createNotification(): Notification {

        val channelId =
            "lynra_presence_service"

        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.O
        ) {

            val channel =
                NotificationChannel(
                    channelId,
                    getString(
                        R.string
                            .presence_service_channel_name
                    ),
                    NotificationManager
                        .IMPORTANCE_LOW,
                )

            val manager =
                getSystemService(
                    NotificationManager::class.java,
                )

            manager.createNotificationChannel(
                channel,
            )
        }

        return Notification.Builder(
            this,
            channelId,
        )
            .setContentTitle(
                getString(
                    R.string
                        .presence_service_notification_title
                ),
            )
            .setContentText(
                getString(
                    R.string
                        .presence_service_notification_body
                ),
            )
            .setSmallIcon(
                android.R.drawable
                    .ic_menu_mylocation
            )
            .build()
    }
}