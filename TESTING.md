# TESTING（付款截图记账）

## 一、自动化脚本

在仓库根目录执行：

```bash
node scripts/payment_parser_20_cases_test.js
node scripts/category_service_user_rules_test.js
node scripts/bill_repository_crud_test.js
node scripts/capture_review_state_test.js
```

再执行已有脚本：

```bash
node scripts/bill_repository_smoke_test.js
node scripts/ocr_service_smoke_test.js
node scripts/payment_parser_smoke_test.js
node scripts/screenshot_import_flow_smoke_test.js
node scripts/screenshot_auto_reminder_smoke_test.js
node scripts/screen_capture_service_smoke_test.js
node scripts/floating_capture_button_smoke_test.js
node scripts/settings_page_options_smoke_test.js
node scripts/user_rule_service_smoke_test.js
node scripts/capture_review_flow_smoke_test.js
node scripts/quick_add_validation_smoke_test.js
```

## 二、手动测试（微信/支付宝/美团/淘宝/京东）

1. 在设置页开启：
   - 自动识别新截图
   - 付款后显示浮窗
2. 用微信/支付宝/美团/淘宝/京东完成一笔支付（或打开历史支付详情页）。
3. 截图后回到 App 首页。
4. 验证出现“是否用于记账”的轻提示。
5. 点击“记账”进入识别确认页。
6. 检查：
   - OCR 状态展示正常
   - 金额/商户/分类建议可编辑
   - 若有多个金额候选可切换
7. 点击保存后：
   - 首页出现新账单
   - 账单列表出现新账单
8. 在设置页“用户规则管理”查看新增规则；删除后再次测试同商户，确认规则不再生效。

## 三、异常回归

- OCR 失败时：应有错误提示，不崩溃。
- 无金额：不允许保存。
- 无商户：不允许保存。
- 重复点击保存：应阻止重复保存。
- 一键截图不支持时：明确提示“使用系统截图后返回识别”，不假装成功。
