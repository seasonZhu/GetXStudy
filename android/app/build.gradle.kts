import java.util.Properties

plugins {
    id("com.android.application")
    id("com.android.built-in-kotlin")
    // Flutter 插件必须在 Android 和内置 Kotlin 插件之后应用。
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningFile = rootProject.file("key.properties")
val releaseSigning = Properties().apply {
    if (releaseSigningFile.isFile) {
        releaseSigningFile.reader(Charsets.UTF_8).use { load(it) }
    }
}

extensions.configure<com.android.build.api.dsl.ApplicationExtension> {
    namespace = "com.example.getx_study"
    compileSdk = flutter.compileSdkVersion
    // 引用gradle.properties中的ndkVersion属性
    ndkVersion = project.property("ndkVersion") as String

    buildFeatures {
        resValues = true
    }

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
        resValue("string", "display_build_number", flutter.versionCode.toString())
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (releaseSigningFile.isFile) {
        signingConfigs.create("release") {
            fun requiredProperty(name: String): String =
                requireNotNull(releaseSigning.getProperty(name)?.takeIf { it.isNotEmpty() }) {
                    "发布签名配置缺少 $name"
                }

            storeFile = rootProject.file(requiredProperty("storeFile"))
            storePassword = requiredProperty("storePassword")
            keyPassword = requiredProperty("keyPassword")
            keyAlias = requiredProperty("keyAlias")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(
                if (releaseSigningFile.isFile) "release" else "debug"
            )
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
