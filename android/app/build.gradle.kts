plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    id("com.google.gms.google-services")

}


dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))

    // Firebase BoM — don't specify versions in Firebase dependencies
    implementation("com.google.firebase:firebase-analytics")

    // Google Play Feature Delivery (provides SplitInstall classes for Flutter R8 release)
    implementation("com.google.android.play:feature-delivery:2.1.0")

    // Core library desugaring (required by flutter_local_notifications)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}


android {
    namespace = "com.andrewmichel.vaxguide"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.andrewmichel.vaxguide"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with debug keys for now.
            // Replace with your own keystore for Play Store upload.
            signingConfig = signingConfigs.getByName("debug")

            // Enable code shrinking, obfuscation, and resource shrinking
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
