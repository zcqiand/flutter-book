plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.channel_lab"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.channel_lab"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 清单 21-5 段二：flavors 变体配置（android { } 块增量）
    // 最小骨架；key 与占位值全部为示意值
    // flavorDimensions 让 dev/prod 归入同一维度：同一次构建二选一，不组合爆炸
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            // applicationIdSuffix 让 dev 包与 prod 包可共存安装：调试机上互不覆盖
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "channel_lab dev")
        }
        create("prod") {
            dimension = "env"
            // prod 无后缀：分发面用正式包名
            resValue("string", "app_name", "channel_lab")
        }
    }

    // 清单 21-7：签名配置（环境变量注入）
    // 申报：密钥口令一律环境变量注入，本文件与注释零真实密钥材料；
    // keystore 路径为示意值。环境变量缺失时本配置即构建失败，缺什么补什么
    signingConfigs {
        create("release") {
            // 四材料全走环境变量：口令与密钥不进仓库，CI 与本机同一取值通道
            storeFile = System.getenv("KEYSTORE_PATH")?.let { file(it) }
            storePassword = System.getenv("STORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }
    buildTypes {
        release {
            // release 挂上签名配置：不挂则产出的是未签名 APK，装不上正版渠道
            signingConfig = signingConfigs.getByName("release")
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
