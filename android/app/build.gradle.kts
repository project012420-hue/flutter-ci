plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
}

// ── Load keystore properties ──────────────────────────────
val keystoreProperties = java.util.Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
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
            keyAlias      = keystoreProperties["keyAlias"] as String?
            keyPassword   = keystoreProperties["keyPassword"] as String?
            storeFile     = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
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
    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension        = "environment"
            applicationId    = "com.example.screenshare.dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "ScreenShare Dev")
        }
        create("staging") {
            dimension        = "environment"
            applicationId    = "com.example.screenshare.staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "ScreenShare Staging")
        }
        create("prod") {
            dimension     = "environment"
            applicationId = "com.example.screenshare"
            resValue("string", "app_name", "ScreenShare")
        }
    }
    // ─────────────────────────────────────────────────────

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled    = true
            isShrinkResources  = true
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