import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.chastechgroup.zen_garden_jam_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
                ?: System.getenv("ANDROID_KEY_ALIAS")
            keyPassword = keystoreProperties["keyPassword"] as String?
                ?: System.getenv("ANDROID_KEY_PASSWORD")
            storeFile = (keystoreProperties["storeFile"] as String?
                ?: System.getenv("ANDROID_KEYSTORE_PATH"))
                    ?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
                ?: System.getenv("ANDROID_STORE_PASSWORD")
        }
    }

    defaultConfig {
        applicationId = "com.chastechgroup.zengardenjam"
        minSdk = 21  // Required for google_mobile_ads
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Falls back to Google test AdMob ID — app will load but show test ads
        // Replace by adding ADMOB_APP_ID_ANDROID to your GitHub secrets
        manifestPlaceholders["admobAppId"] =
            System.getenv("ADMOB_APP_ID_ANDROID") ?: "ca-app-pub-3940256099942544~3347511713"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
