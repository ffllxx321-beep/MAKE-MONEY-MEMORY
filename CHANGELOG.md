# Changelog

## 0.1.0-beta (2026-04-29)

### Added
- 付款截图记账主流程：导入截图 -> OCR（Mock）-> 文本解析 -> 草稿确认 -> 保存。
- 手动记账页面与账单列表页面。
- OCR 抽象层（`OcrService`）与 `MockOcrService`，`HuaweiOcrService` 占位实现。
- 文本解析器 `PaymentParser`（金额、商户、支付方式、时间、置信度、warning）。
- 用户规则：商户关键词 -> 分类映射，支持查看与删除。
- 自动识别新截图提醒（前台扫描降级方案）。
- App 内浮窗入口（完整/缩边/隐藏），支持位置持久化。
- 一键截图能力封装与降级（不支持时提示系统截图）。
- 隐私和权限说明页。
- OCR 评测框架基础：`test_assets` + `ocr_evaluation_runner`。

### Changed
- 设置页完善：
  - 自动识别开关
  - 浮窗开关与显示时长（5/8/15）
  - 浮窗位置重置
  - 自动保存开关（默认关闭）
  - 指定 App 启用范围
- 识别性能优化：
  - 预览压缩图
  - OCR 前尺寸限制
  - 异步识别流程
  - 识别完成后释放临时资源

### Fixed
- 增强系统能力失败降级：
  - 截图失败明确引导系统截图
  - 浮窗能力不可用时隐藏浮窗设置并给出替代路径
  - OCR 失败进入手动填写状态
- 防止识别确认页重复保存同一草稿。

### Testing
- 新增并维护多组脚本测试（parser/repository/ocr/settings/fallback/stability）。
- 详细人工验收步骤见 `TESTING.md` 与 `docs/acceptance-checklist.md`。
