package io.github.adehikmatfr.exoditeanima

import android.content.pm.ApplicationInfo
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity is required by the biometric prompt (local_auth).
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // FEAT-003 AC-3 and AC-11: block screenshots and screen recording, and hide the
        // app in the recent-apps preview. Debug builds are left open so developers can
        // take screenshots; release builds always set the flag.
        val debuggable = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        if (!debuggable) {
            window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
        }
        super.onCreate(savedInstanceState)
    }
}
