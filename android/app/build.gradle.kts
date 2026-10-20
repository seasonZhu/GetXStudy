plugins {
    id("com.android.application")
    id("com.android.built-in-kotlin")
    // Flutter 插件必须在 Android 和内置 Kotlin 插件之后应用。
    id("dev.flutter.flutter-gradle-plugin")
}

extensions.configure<com.android.build.api.dsl.ApplicationExtension> {
    namespace = "com.example.getx_study"
    compileSdk = flutter.compileSdkVersion
    // 引用gradle.properties中的ndkVersion属性
    ndkVersion = project.property("ndkVersion") as String

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    java {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of(17))
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.getx_study"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
