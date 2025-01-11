package com.valueoutput.pip_mode

import android.os.Build
import android.app.Activity
import android.util.Rational
import androidx.annotation.NonNull
import android.app.PictureInPictureParams
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class PipModePlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.valueoutput.pip_mode")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "enterPipMode") {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                activity?.let {
                    val aspectRatio = Rational(16, 9) // Default aspect ratio; can be modified
                    val params = PictureInPictureParams.Builder().setAspectRatio(aspectRatio).build()
                    it.enterPictureInPictureMode(params)
                    result.success(null)
                } ?: run {
                    result.error("NO_ACTIVITY", "No activity available to enter PiP mode", null)
                }
            } else {
                result.error("UNSUPPORTED_VERSION", "Picture-in-Picture is only supported on Android O and above", null)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
