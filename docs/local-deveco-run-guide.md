# 本地 DevEco Studio 运行指南（新手版）

1. 从 GitHub clone 或下载 ZIP 后解压进入仓库根目录。
2. DevEco Studio 用 Open 打开仓库根目录。
3. 若提示依赖同步，先 Trust Project，再点击 Sync Now。
4. 在 Settings/Preferences 的 HarmonyOS SDK 页面检查并安装所需 SDK。
5. 在签名配置页补齐 debug 签名并绑定到 debug 构建。
6. 真机连接：开启开发者模式、开启 USB 调试、USB 连接并允许调试授权。
7. 选择 entry 模块与设备后点 Run 安装运行。
8. 构建 debug HAP：执行 Build Hap(s)/Build Module（debug）。
9. 常见输出目录：entry/build/default/outputs/default/*.hap。
10. 常见错误：SDK 缺失、签名缺失、设备识别失败、module.json5 配置错误、ArkTS 编译错误。
11. 本文档不修改业务代码。
12. 路径：docs/local-deveco-run-guide.md。
