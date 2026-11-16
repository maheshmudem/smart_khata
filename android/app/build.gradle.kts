import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is read from android/key.properties (never committed).
// CI writes that file from GitHub secrets; see docs/engineering/ci-cd.md.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

// A release build without the keystore would be debug-signed. Such an APK
// can never be updated by the real one: the owner would have to remove the
// app, which deletes the shop's records. So it is refused unless asked for
// on purpose (CI smoke builds, local R8 checks):
//   SMART_KHATA_ALLOW_DEBUG_SIGNED_RELEASE=true flutter build apk --release
val allowDebugSignedRelease =
    providers.environmentVariable("SMART_KHATA_ALLOW_DEBUG_SIGNED_RELEASE")
        .orNull == "true"

gradle.taskGraph.whenReady {
    val buildsRelease = allTasks.any {
        it.project == project &&
            it.name.endsWith("Release") &&
            (it.name.startsWith("assemble") ||
                it.name.startsWith("bundle") ||
                it.name.startsWith("package"))
    }
    if (buildsRelease && !hasReleaseKeystore && !allowDebugSignedRelease) {
        throw GradleException(
            "No android/key.properties: this release build would be " +
                "debug-signed and could never be updated. Add the keystore " +
                "(docs/engineering/ci-cd.md) or, for a build that will not " +
                "be given to anyone, set " +
                "SMART_KHATA_ALLOW_DEBUG_SIGNED_RELEASE=true.",
        )
    }
}

android {
    namespace = "com.maheshmudem.smartkhata"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Needed by flutter_local_notifications for scheduled reminders
        // on older Android versions.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.maheshmudem.smartkhata"
        // minSdk 24 (Android 7.0); see docs/adr/ADR-018-android-app-id-and-sdk-levels.md.
        minSdk = maxOf(24, flutter.minSdkVersion)
        // Play requires API 36 for new apps; recheck at submission time.
        targetSdk = maxOf(36, flutter.targetSdkVersion)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Without key.properties a release build is refused (see the
            // check above) unless debug signing was asked for on purpose.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
