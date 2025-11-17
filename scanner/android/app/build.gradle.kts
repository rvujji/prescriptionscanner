plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

java { toolchain { languageVersion.set(JavaLanguageVersion.of(17)) } }

android {
    namespace = "com.vuzi.scanner"
    compileSdk = flutter.compileSdkVersion.toInt()

    ndkVersion = "27.0.12077973" //raj

    defaultConfig {
        applicationId = "com.vuzi.scanner"
        minSdk = flutter.minSdkVersion.toInt()
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        setProperty("archivesBaseName", "Scanner-${versionName}-${versionCode}")
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
getDefaultProguardFile("proguard-android-optimize.txt"),
"proguard-rules.pro"
)
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}
//raj
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
}

flutter {
    source = "../.."
}
