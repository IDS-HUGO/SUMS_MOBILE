allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // ── PARCHE DE COMPATIBILIDAD DEFINITIVO (AGP 9 + Java 17 + SDK 36) ──

    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                // 1. Forzar compileSdk a 36 (Baklava) para resolver conflictos de sqflite
                try {
                    val setCompileSdk = android.javaClass.methods.find { it.name == "setCompileSdk" && it.parameterCount == 1 }
                    setCompileSdk?.invoke(android, 36)
                } catch (e: Exception) {
                    try {
                        android.javaClass.getMethod("setCompileSdkVersion", Int::class.java).invoke(android, 36)
                    } catch (e2: Exception) {}
                }

                // 2. Inyectar Namespace si falta
                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    if (getNamespace.invoke(android) == null) {
                        val manifestFile = project.file("src/main/AndroidManifest.xml")
                        var pkg: String? = null
                        if (manifestFile.exists()) {
                            val content = manifestFile.readText()
                            pkg = Regex("package=\"([^\"]+)\"").find(content)?.groups?.get(1)?.value
                        }
                        val finalNamespace = pkg ?: "com.${project.name.replace("-", ".").replace("_", ".")}"
                        setNamespace.invoke(android, finalNamespace)
                    }
                } catch (e: Exception) {}

                // 3. Forzar Java 17 en compileOptions
                try {
                    val compileOptions = android.javaClass.getMethod("getCompileOptions").invoke(android)
                    compileOptions.javaClass.getMethod("setSourceCompatibility", JavaVersion::class.java).invoke(compileOptions, JavaVersion.VERSION_17)
                    compileOptions.javaClass.getMethod("setTargetCompatibility", JavaVersion::class.java).invoke(compileOptions, JavaVersion.VERSION_17)
                } catch (e: Exception) {}
            }
        }

        // 4. Forzar JVM Target 17 en TODAS las tareas de Kotlin (Solución para inconsistencias)
        tasks.configureEach {
            val taskName = this.javaClass.name
            if (taskName.contains("KotlinCompile") || taskName.contains("KotlinJvmCompile")) {
                try {
                    // Intento con DSL moderno (Kotlin 2.0+)
                    val compilerOptions = this.javaClass.getMethod("getCompilerOptions").invoke(this)
                    val jvmTarget = compilerOptions.javaClass.getMethod("getJvmTarget").invoke(compilerOptions)
                    val jvmTargetClass = Class.forName("org.jetbrains.kotlin.gradle.dsl.JvmTarget")
                    val jvm17 = jvmTargetClass.getField("JVM_17").get(null)
                    jvmTarget.javaClass.getMethod("set", Object::class.java).invoke(jvmTarget, jvm17)
                } catch (e: Exception) {
                    try {
                        // Fallback para DSL antiguo (Kotlin 1.x)
                        val kotlinOptions = this.javaClass.getMethod("getKotlinOptions").invoke(this)
                        kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java).invoke(kotlinOptions, "17")
                    } catch (e2: Exception) {}
                }
            }
        }
        
        // 5. Forzar Java 17 en tareas de JavaCompile
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

// AGP 9 exige un `namespace` explícito en cada módulo Android; ya no basta
// con el atributo `package` del AndroidManifest.xml. Algunos plugins viejos
// (ej. flutter_jailbreak_detection 1.10.0) todavía no lo declaran en su
// build.gradle. En vez de parchear el paquete dentro de pub cache (se pierde
// con cada `flutter pub get`), se le asigna aquí un namespace derivado del
// `package` de su propio manifest — solo a los módulos que no traigan uno ya.
// Se usa `plugins.withType` (no `afterEvaluate`) porque para cuando este
// build.gradle.kts corre, algunos subproyectos ya fueron evaluados por el
// `evaluationDependsOn(":app")` de arriba, y `afterEvaluate` falla en ese caso.
subprojects {
    plugins.withType(com.android.build.gradle.LibraryPlugin::class.java) {
        val androidExt = extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
        if (androidExt.namespace == null) {
            val manifestFile = androidExt.sourceSets.getByName("main").manifest.srcFile
            val manifestPackage = manifestFile
                .takeIf { it.exists() }
                ?.let { Regex("package=\"([^\"]+)\"").find(it.readText())?.groupValues?.get(1) }
            androidExt.namespace = manifestPackage
                ?: "com.sums.thirdparty.${project.name.replace('-', '_').replace('.', '_')}"
        }
        // Algunos plugins viejos (misma causa que el namespace) no fijan su
        // propio Java target, y terminan compilando en un JDK distinto al
        // Kotlin del resto del build (17, ver app/build.gradle.kts) — eso
        // rompe con "Inconsistent JVM Target Compatibility". Se alinean aquí.
        androidExt.compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
        // Algunos plugins (ej. file_picker) traen su propio compileSdkVersion
        // viejo (34) hardcodeado en su build.gradle. AGP lee ese valor muy
        // temprano (asignarlo directo aquí se sobreescribe después con el 34
        // del propio plugin; hacerlo en afterEvaluate llega demasiado tarde:
        // "It is too late to set compileSdk"). `finalizeDsl` es el hook oficial
        // de la Variant API para este caso exacto — corre justo antes de que
        // AGP fije el DSL en piedra, así que sí gana sobre el 34 del plugin.
        extensions.getByType(com.android.build.api.variant.LibraryAndroidComponentsExtension::class.java)
            .finalizeDsl { ext -> ext.compileSdk = 36 }
    }
    // Se fija a nivel de tarea (no del toolchain de la extension Kotlin):
    // algunos plugins ya dejan esa propiedad del toolchain "final" antes de
    // que este hook corra, y jvmToolchain(...) explota con
    // "languageVersion is final and cannot be changed any further".
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
