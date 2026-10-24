import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Push notifications need app/google-services.json from the Firebase console (Android app
// com.vidyasethu.pvs). Without it the app builds and runs, just without push.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

// Release signing (Google Play upload key): android/key.properties - never committed (see android/.gitignore):
//   storeFile=D:/Keys/pvs-upload.jks
//   storePassword=...
//   keyAlias=upload
//   keyPassword=...
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKey = !keystoreProperties.isEmpty

// A Play upload must never be debug-signed: stop the bundle build when the key is missing.
gradle.taskGraph.whenReady {
    if (!hasReleaseKey && allTasks.any { it.name == "bundleRelease" }) {
        throw GradleException(
            "Release signing key not set up: create android/key.properties (see the comment in android/app/build.gradle.kts).",
        )
    }
}

android {
    namespace = "com.vidyasethu.pvs"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vidyasethu.pvs"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // The upload key when android/key.properties exists; otherwise the debug key, so `flutter run --release`
            // still works on this PC (bundleRelease is refused above).
            signingConfig = signingConfigs.getByName(if (hasReleaseKey) "release" else "debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
