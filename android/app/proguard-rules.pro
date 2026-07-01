# Flutter ya agrega sus propias reglas para el engine/embedding. Estas son
# adicionales para plugins con puente nativo Android que R8 podría renombrar
# o eliminar por no ver referencias directas desde Kotlin/Java (se referencian
# por nombre de clase o vía reflexión desde AndroidX WorkManager / Keystore).

# workmanager: el dispatcher de sincronización en segundo plano depende de que
# WorkManager pueda instanciar estas clases por nombre.
-keep class dev.fluttercommunity.workmanager.** { *; }
-keep class androidx.work.** { *; }

# flutter_secure_storage: Android Keystore / EncryptedSharedPreferences.
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# flutter_jailbreak_detection.
-keep class com.scottyab.rootbeer.** { *; }
-keep class appmire.be.flutterjailbreakdetection.** { *; }
