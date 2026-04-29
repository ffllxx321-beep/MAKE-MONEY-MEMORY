# 付款截图记账浮窗能力限制说明（HarmonyOS）

## 调研结论（当前阶段）

1. 在 OpenHarmony/HarmonyOS 文档与能力描述中，常见“悬浮”能力主要体现在**应用窗口模式（floating window mode）**，并不等价于“普通三方 App 在其他 App 之上长期悬浮”的 Android 式跨应用悬浮窗。  
2. 当前仓库运行环境无法验证稳定、面向普通三方应用的跨 App 悬浮窗公开 API 与上架可行权限组合。  
3. 因此本实现采用**安全降级方案**：
   - 仅实现 **App 内浮窗**（本次已实现）
   - 保留 **通知入口** 与 **服务卡片入口** 的扩展位（TODO）
   - 不引入高风险权限，不在用户未开启功能时申请权限

## 参考资料（用于能力边界判断）

- OpenHarmony `StartOptions` 文档中提到窗口模式/悬浮相关能力（用于应用窗口模式，而非跨 App 常驻悬浮层）：  
  https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis-ability-kit/js-apis-app-ability-startOptions.md
- OpenHarmony 模块配置文档中涉及多窗与悬浮窗布局方向配置（同样是应用窗口能力）：  
  https://gitee.com/openharmony/docs/blob/5f3bd0ff81cfd09c9a059b7f9f6cfe452b3b01a9/zh-cn/application-dev/quick-start/module-configuration-file.md

## 当前落地策略

- ✅ App 内浮窗按钮（完整 / 缩边 / 隐藏）
- ✅ 8 秒自动缩边，30 秒自动隐藏
- ✅ 可拖动位置，状态和位置持久化
- ✅ 点击进入截图记账流程
- ✅ 设置项：
  - 付款后显示浮窗
  - 显示时长
  - 启用 App 列表（仅配置展示，跨 App 实际拦截为后续能力）

## 后续 TODO（目标 SDK 可用时）

1. 若 HarmonyOS 官方提供面向普通三方应用、稳定且可上架的跨 App 悬浮能力：
   - 按官方权限与窗口能力替换当前降级实现
   - 权限仅在用户开启功能时触发申请
2. 若仍不支持：
   - 继续增强 App 内浮窗 + 通知入口 + 服务卡片入口
