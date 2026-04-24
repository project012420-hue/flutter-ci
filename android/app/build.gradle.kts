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
//    signingConfigs {
//        create("release") {
//            val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
//
//            if (!keystorePath.isNullOrEmpty()) {
//                storeFile = file(keystorePath)
//                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
//                keyAlias = System.getenv("ANDROID_KEY_ALIAS")
//                keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
//            }
//        }
//    }
    signingConfigs {
        create("release") {
            val keystorePath = project.findProperty("ANDROID_KEYSTORE_PATH")?.toString()
            val keystorePassword = project.findProperty("ANDROID_KEYSTORE_PASSWORD")?.toString()
            val keyAliasVal = project.findProperty("ANDROID_KEY_ALIAS")?.toString()
            val keyPasswordVal = project.findProperty("ANDROID_KEY_PASSWORD")?.toString()

            if (
                !keystorePath.isNullOrEmpty() &&
                !keystorePassword.isNullOrEmpty() &&
                !keyAliasVal.isNullOrEmpty() &&
                !keyPasswordVal.isNullOrEmpty()
            ) {
                val keystoreFile = file(keystorePath)
                if (keystoreFile.exists()) {
                    storeFile = keystoreFile
                    storePassword = keystorePassword
                    this.keyAlias = keyAliasVal
                    this.keyPassword = keyPasswordVal
                } else {
                    throw GradleException("Keystore file not found: ${keystoreFile.absolutePath}")
                }
            } else {
                throw GradleException(
                    "Missing signing props. Required: ANDROID_KEYSTORE_PATH, " +
                            "ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD"
                )
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
        create("therealappthe2") {
            dimension = "environment"
            applicationId = "com.example.TheRealAppThe2"
            resValue("string", "app_name", "TheRealAppThe2")
        }
        create("therealapp") {
            dimension = "environment"
            applicationId = "com.example.TheRealApp"
            resValue("string", "app_name", "TheRealApp")
        }
        create("dynamic") {
            dimension = "environment"

            applicationId = project.findProperty("APP_ID")?.toString() ?: "com.example.app"

            resValue(
                "string",
                "app_name",
                project.findProperty("APP_NAME")?.toString() ?: "My App"
            )
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