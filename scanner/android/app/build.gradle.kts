plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Must be last
}

android {
    namespace = "com.example.scanner"
    compileSdk = flutter.compileSdkVersion.toInteger() // Add .toInteger()
    ndkVersion = "27.0.12077973" //raj

    compileOptions {
        coreLibraryDesugaringEnabled true //raj
        sourceCompatibility = JavaVersion.VERSION_1_8 // Use VERSION_1_8 (not 11)
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8' // Use 1.8 (not 11)
    }

    defaultConfig {
        applicationId = "com.example.scanner"
        minSdk = flutter.minSdkVersion.toInteger() // Add .toInteger()
        targetSdk = flutter.targetSdkVersion.toInteger() // Add .toInteger()
        versionCode = flutter.versionCode.toInteger() // Add .toInteger()
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug // Simplified
        }
    }
}

//raj
dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.3' // Moved here
    implementation 'androidx.window:window:1.0.0' // Optional
    implementation 'androidx.window:window-java:1.0.0' // Optional
}

flutter {
    source = "../.."
}