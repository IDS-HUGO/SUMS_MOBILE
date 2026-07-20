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
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Fix: flutter_jailbreak_detection es un plugin viejo y sin mantenimiento que
// choca con AGP 9 / Kotlin recientes: (1) no declara "namespace" (antes se
// inferia del AndroidManifest.xml), (2) su target de Kotlin (21) no coincide
// con el target de Java (11), y (3) su compileSdk (33) es menor al que exigen
// sus propias dependencias androidx (34+).
subprojects {
    if (project.name == "flutter_jailbreak_detection") {
        project.plugins.withId("com.android.library") {
            project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                namespace = "appmire.be.flutterjailbreakdetection"
            }
        }
        // afterEvaluate: el propio build.gradle del plugin fija compileSdkVersion 33
        // como parte de su evaluacion normal, asi que hay que sobreescribirlo despues.
        project.afterEvaluate {
            project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                compileSdk = 36
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_11
                    targetCompatibility = JavaVersion.VERSION_11
                }
            }
        }
        project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
