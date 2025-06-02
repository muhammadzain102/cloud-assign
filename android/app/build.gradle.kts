plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Required for Firebase
}

android {
    compileSdk = 35
    namespace = "com.example.cloud_assign"
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.cloud_assign"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))

    // Firebase Authentication
    implementation("com.google.firebase:firebase-auth-ktx")

    // Firestore dependency
    implementation("com.google.firebase:firebase-firestore-ktx")

    // Analytics dependency (Optional, remove if not needed)
    implementation("com.google.firebase:firebase-analytics-ktx")

    // Other dependencies (if any)...
}
