// 申报：密钥口令一律环境变量注入，本文件正文与注释零真实密钥材料；
// keystore 路径为示意值。环境变量缺失时本配置即构建失败，缺什么补什么
// android { } 块内增量：
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

// keystore 生成示意（-storepass 引用环境变量形态，不落明文）：
// 申报：下行命令为 Windows %VAR% 示意，POSIX 下 $VAR 同形替换
// keytool -genkey -v -keystore %KEYSTORE_PATH% -alias %KEY_ALIAS% -keyalg RSA -keysize 2048 -validity 10000 -storepass %STORE_PASSWORD%

// 产物构建命令两条：
// 签名 APK：flutter build apk --release（产物路径 build/app/outputs/flutter-apk/）
// Web release：flutter build web --release（静态资源，产物路径 build/web/）