plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.easygps"  // تم إضافة namespace هنا
    compileSdk = 35  // تم تحديث compileSdk إلى 35 (مطلوب لبعض الحزم)

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.easygps"  // تأكد من أن applicationId صحيح
        minSdk = 21  // تم تحديث minSdk إلى 21 (أو أي إصدار تدعمه)
        targetSdk = 35  // تم تحديث targetSdk إلى 35
        versionCode = 1  // يمكنك تغيير هذا الرقم حسب إصدار تطبيقك
        versionName = "1.0"  // يمكنك تغيير هذا الرقم حسب إصدار تطبيقك

        // إضافة مفتاح خرائط Google (إذا كنت تستخدم خرائط Google)
        val mapsApiKey: String = project.findProperty("MAPS_API_KEY") as String? ?: ""
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so flutter run --release works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}