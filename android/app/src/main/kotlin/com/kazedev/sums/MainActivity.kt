package com.kazedev.sums

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Control 16: Evitar ataques de Tapjacking / superposición
        window.decorView.filterTouchesWhenObscured = true
        // Bloquea capturas/grabación de pantalla en toda la app (datos médicos y
        // familiares sensibles). Se fija una sola vez para toda la Activity: antes
        // se activaba/desactivaba por pantalla (login, captura de cédula) vía un
        // MethodChannel, pero al compartir una sola Activity el dispose() de una
        // pantalla podía llegar después del initState() de la siguiente y apagar
        // la protección justo al entrar a login.
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
