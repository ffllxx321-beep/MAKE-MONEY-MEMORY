# 一键截图能力支持说明（ScreenCaptureService）

## 当前实现结论

- 已提供 `ScreenCaptureService.captureCurrentScreen()` 能力封装。
- 当前仓库环境下，默认判定为：
  - 普通三方 App 无法稳定、可验证地“直接截取其它 App 页面”；
  - 因此**不假装成功**，明确返回 `unsupported`/`permission_required`/`failed`。

## 结果状态

- `success`：成功获取截图 URI，直接进入 OCR 流程。
- `permission_required`：能力可用但需系统授权（后续目标 SDK 接入时触发系统授权/引导）。
- `unsupported`：当前环境不支持，提示用户使用系统截图后返回 App 自动识别。
- `failed`：调用失败，给出明确错误并走降级。

## 降级方案

当不支持或失败时：

1. 提示用户使用系统截图（快捷键或系统手势）。
2. 用户回到 App 后，走“自动识别新截图”提醒流程。
3. 保证不崩溃、不假成功。

## 权限策略

- 仅在用户主动触发“一键截图”功能时进行能力判断。
- 若未来目标 SDK 需要授权，必须在此时弹系统授权或展示引导说明。
- 不使用未公开 API，不滥用高风险权限。

## TODO

- 在目标 HarmonyOS SDK 中验证官方公开截屏 API：
  - 接入真实探测逻辑（是否支持 + 是否需授权）
  - 接入真实截图调用并返回 `imageUri`
