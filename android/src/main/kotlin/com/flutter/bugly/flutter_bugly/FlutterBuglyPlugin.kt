package com.flutter.bugly.flutter_bugly

import android.app.Activity
import android.os.Environment
import androidx.annotation.NonNull
import com.tencent.bugly.beta.Beta

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FlutterBuglyPlugin */
class FlutterBuglyPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var mActivity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_bugly")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "initCrashReport" -> {
                val appId = call.argument<String>("appId")
                val debug = call.argument<Boolean>("debug")
                val appReportDelay = call.argument<Int>("appReportDelay")
                val devDevice = call.argument<Boolean>("devDevice")
                FlutterBuglyCrash.initCrashReport(
                    mActivity!!,
                    appId ?: "",
                    debug ?: false,
                    appReportDelay ?: 5000,
                    devDevice ?: false
                )
                result.success(0)
            }
            "setUserId" -> {
                val userId = call.argument<String>("userId")
                userId?.let {
                    FlutterBuglyCrash.setUserId("$it")
                }
                result.success(0)
            }
            "postException" -> {
                val error = call.argument<String>("error")
                val stackTrace = call.argument<String>("stackTrace")
                FlutterBuglyCrash.postException(error, stackTrace)
                result.success(0)
            }
            "putUserData" -> {
                val key = call.argument<String>("key")
                val value = call.argument<String>("value")
                FlutterBuglyCrash.putUserData(mActivity!!.applicationContext, key, value)
                result.success(0)
            }
            "checkUpgrade" -> {
                Beta.checkAppUpgrade(false, false)
            }
            "testJavaCrash" -> {
                FlutterBuglyCrash.testJavaCrash()
                result.success(0)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }
}
