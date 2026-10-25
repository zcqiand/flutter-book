// 段二：android { } 块增量（Kotlin DSL）
// 最小骨架，gradle 全文件以仓库为准；key 与占位值全部为示意值
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