allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// flutter_jailbreak_detection 1.10.0 no declara `namespace` en su build.gradle,
// lo cual AGP 8+/9 exige para configurar el proyecto. Se lo inyectamos aquí
// (mismo paquete que su AndroidManifest.xml) sin tener que parchear el paquete.
subprojects {
    afterEvaluate {
        if (project.name == "flutter_jailbreak_detection") {
            extensions.findByName("android")?.withGroovyBuilder {
                if (getProperty("namespace") == null) {
                    setProperty("namespace", "appmire.be.flutterjailbreakdetection")
                }
                // El plugin fija compileSdkVersion 33, pero otras dependencias de la
                // app (androidx.lifecycle 2.7+) exigen compilar contra 34+.
                setProperty("compileSdkVersion", 36)
            }

            // Este plugin trae su propio classpath de Kotlin (1.7.20) vía un bloque
            // buildscript legado, lo que deja sus tareas Java (target 11 por defecto)
            // y Kotlin (target 21, heredado del JDK que corre Gradle) en conflicto.
            // Se fuerzan ambas a JVM 17, igual que el resto de la app.
            extensions.findByName("android")?.withGroovyBuilder {
                getProperty("compileOptions")?.withGroovyBuilder {
                    setProperty("sourceCompatibility", JavaVersion.VERSION_17)
                    setProperty("targetCompatibility", JavaVersion.VERSION_17)
                }
            }
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
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
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
