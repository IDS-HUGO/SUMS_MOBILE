package com.kazedev.sums

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Control 19: Prevenir capturas de pantalla / grabaciones (FLAG_SECURE)
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        
        // Control 16: Evitar ataques de Tapjacking / superposición
        window.decorView.filterTouchesWhenObscured = true
    }
}
