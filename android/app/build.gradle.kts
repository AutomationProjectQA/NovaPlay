plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.novaplay.novaplay"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.novaplay.novaplay"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Build flavors (Sprint 5). Each maps to a `lib/main_<flavor>.dart`
    // entrypoint and its own applicationId suffix so dev/staging/prod can be
    // installed side by side. Wire per-flavor google-services.json under
    // android/app/src/<flavor>/ when Firebase is connected (docs/ARCHITECTURE.md §13).
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "NovaPlay Dev")
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "NovaPlay Staging")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "NovaPlay")
        }
    }

    buildTypes {
        release {
            // TODO: Replace with a real release signing config before store upload
            // (docs/RELEASE_PLAN.md). Debug keys are used for now so
            // `flutter run --release` works locally.
            signingConfig = signingConfigs.getByName("debug")
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
