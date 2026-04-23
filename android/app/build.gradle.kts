plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
}

// ─────────────────────────────────────────────────────────

android {
    namespace = "com.example.screenshare"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // ── Signing config ────────────────────────────────────
    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")

            if (!keystorePath.isNullOrEmpty()) {
                storeFile = file(keystorePath)
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
            }
        }
    }
    // ─────────────────────────────────────────────────────

    defaultConfig {
        // applicationId removed from here — each flavor sets its own
        minSdk     = flutter.minSdkVersion
        targetSdk  = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ── Flavors ───────────────────────────────────────────
    val flavorName = project.findProperty("FLAVOR")?.toString() ?: "dev"
    val appId = project.findProperty("APP_ID")?.toString() ?: "com.example.app"
    val appName = project.findProperty("APP_NAME")?.toString() ?: "My App"

    flavorDimensions += "environment"

    productFlavors {
        create(flavorName) {
            dimension = "environment"
            applicationId = appId
            resValue("string", "app_name", appName)
        }
    }
    // ─────────────────────────────────────────────────────

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled    = false
            isShrinkResources  = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    dependencies {
        implementation(platform("com.google.firebase:firebase-bom:33.6.0"))
        implementation("com.google.firebase:firebase-analytics")
    }
}

flutter {
    source = "../.."
}