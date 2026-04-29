import { UserRule } from '../models/UserRule'
import { UserRuleService } from '../services/UserRuleService'
import { SettingsStore } from '../services/SettingsStore'
import { PrivacyPermissionPage } from './PrivacyPermissionPage'
import { FloatingTriggerService } from '../services/FloatingTriggerService'

@Component
export struct SettingsPage {
  @State screenshotEntryEnabled: boolean = false
  @State autoRecognizeEnabled: boolean = false
  @State autoSaveEnabled: boolean = false
  @State rules: UserRule[] = []

  @State floatingCaptureEnabled: boolean = true
  @State floatingDisplaySeconds: number = 8

  @State enabledApps: string[] = []
  private readonly appOptions: string[] = ['微信', '支付宝', '美团', '淘宝', '京东', '银行 App']

  @State showPrivacyText: boolean = false
  @State showRulesPanel: boolean = false
  @State floatingAvailable: boolean = true
  @State floatingFallbackText: string = ''
  @State showPrivacyPage: boolean = false

  private readonly userRuleService: UserRuleService = new UserRuleService()
  private readonly settingsStore: SettingsStore = new SettingsStore()
  private readonly floatingTriggerService: FloatingTriggerService = new FloatingTriggerService()

  aboutToAppear(): void {
    this.autoRecognizeEnabled = this.settingsStore.isAutoRecognizeScreenshotEnabled()
    this.autoSaveEnabled = this.settingsStore.isAutoSaveAfterRecognizeEnabled()
    this.floatingCaptureEnabled = this.settingsStore.isFloatingCaptureEnabled()
    this.floatingDisplaySeconds = this.settingsStore.getFloatingDisplaySeconds()
    this.enabledApps = this.settingsStore.getFloatingEnabledApps()
    const capability = this.floatingTriggerService.detectCapability()
    this.floatingAvailable = capability.available
    this.floatingFallbackText = capability.available ? '' : capability.message
    this.refreshRules()
  }

  private refreshRules(): void {
    this.rules = this.userRuleService.listRules()
  }

  private deleteRule(ruleId: string): void {
    this.userRuleService.deleteRule(ruleId)
    this.refreshRules()
  }

  private toggleApp(appName: string): void {
    const has = this.enabledApps.includes(appName)
    this.enabledApps = has
      ? this.enabledApps.filter((x) => x !== appName)
      : [...this.enabledApps, appName]
    this.settingsStore.setFloatingEnabledApps(this.enabledApps)
  }

  build() {
    if (this.showPrivacyPage) {
      PrivacyPermissionPage({
        onBack: () => { this.showPrivacyPage = false }
      })
    } else {
    Column({ space: 10 }) {
      Text('付款截图记账设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Row() {
        Text('自动识别新截图').fontSize(16)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.autoRecognizeEnabled })
          .onChange((value: boolean) => {
            this.autoRecognizeEnabled = value
            this.settingsStore.setAutoRecognizeScreenshotEnabled(value)
            // TODO: 在目标 SDK 中，开启时再申请所需权限
          })
      }
      .padding(12).borderRadius(10).backgroundColor(Color.White)

      if (this.floatingAvailable) {
      Row() {
        Text('付款后显示浮窗').fontSize(16)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.floatingCaptureEnabled })
          .onChange((value: boolean) => {
            this.floatingCaptureEnabled = value
            this.settingsStore.setFloatingCaptureEnabled(value)
            // TODO: 在目标 SDK 中，开启时再申请所需权限
          })
      }
      .padding(12).borderRadius(10).backgroundColor(Color.White)

      Text('浮窗显示时长').fontSize(14).fontColor('#666').width('100%').textAlign(TextAlign.Start)
      Row({ space: 8 }) {
        ForEach([5, 8, 15], (sec: number) => {
          Button(`${sec}秒`)
            .height(32)
            .backgroundColor(this.floatingDisplaySeconds === sec ? '#1677FF' : '#EEE')
            .fontColor(this.floatingDisplaySeconds === sec ? Color.White : '#333')
            .onClick(() => {
              this.floatingDisplaySeconds = sec
              this.settingsStore.setFloatingDisplaySeconds(sec)
            })
        }, (sec: number) => sec.toString())
      }

      Button('浮窗位置重置')
        .width('100%')
        .height(36)
        .onClick(() => this.settingsStore.resetFloatingPosition())

      } else {
        Text(this.floatingFallbackText)
          .fontSize(12)
          .fontColor('#A66')
          .width('100%')
          .textAlign(TextAlign.Start)
      }

      Row() {
        Text('识别后自动保存').fontSize(16)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.autoSaveEnabled })
          .onChange((value: boolean) => {
            this.autoSaveEnabled = value
            this.settingsStore.setAutoSaveAfterRecognizeEnabled(value)
          })
      }
      .padding(12).borderRadius(10).backgroundColor(Color.White)

      Text('仅在这些 App 启用').fontSize(14).fontColor('#666').width('100%').textAlign(TextAlign.Start)
      Row({ space: 8 }) {
        ForEach(this.appOptions, (app: string) => {
          Button(app)
            .height(30)
            .fontSize(12)
            .backgroundColor(this.enabledApps.includes(app) ? '#1677FF' : '#EEE')
            .fontColor(this.enabledApps.includes(app) ? Color.White : '#333')
            .onClick(() => this.toggleApp(app))
        }, (app: string) => app)
      }

      Button('隐私和权限说明')
        .width('100%')
        .height(34)
        .onClick(() => this.showPrivacyPage = true)

      if (this.showPrivacyText) {
        Text('只在你开启后处理截图；默认不上传。敏感权限只在你打开功能时申请。')
          .fontSize(12).fontColor('#666').width('100%').textAlign(TextAlign.Start)
      }

      Button('用户规则管理')
        .width('100%')
        .height(34)
        .onClick(() => this.showRulesPanel = !this.showRulesPanel)

      if (this.showRulesPanel) {
        if (this.rules.length === 0) {
          Text('暂无规则').fontSize(12).fontColor('#888').width('100%').textAlign(TextAlign.Start)
        } else {
          ForEach(this.rules, (rule: UserRule) => {
            Row() {
              Text(`${rule.keyword} → ${rule.categoryName}`).fontSize(14)
              Blank()
              Button('删除').height(28).onClick(() => this.deleteRule(rule.id))
            }
            .padding(10).borderRadius(8).backgroundColor(Color.White)
          }, (rule: UserRule) => rule.id)
        }
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F3F5')
    }
  }
}
