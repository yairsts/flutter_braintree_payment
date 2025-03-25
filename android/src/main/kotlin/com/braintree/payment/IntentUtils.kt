package com.braintree.payment

import android.content.Intent
import android.util.Log

public object IntentUtils {
    fun putArguments(intent: Intent, arguments: Map<String, Any>?) {
        arguments?.forEach { (key, value) ->
            when (value) {
                is String -> intent.putExtra(key, value)
                is Int -> intent.putExtra(key, value)
                is Boolean -> intent.putExtra(key, value)
                is Double -> intent.putExtra(key, value)
                is Float -> intent.putExtra(key, value)
                is Long -> intent.putExtra(key, value)
                else -> Log.w("IntentUtils", "Unsupported argument type for key: $key")
            }
        }
    }
}