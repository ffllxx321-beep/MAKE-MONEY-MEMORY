import { SummaryCard } from '../components/SummaryCard'
import { BillItem } from '../components/BillItem'
import { BillRepository } from '../data/BillRepository'
import { AccountService } from '../services/AccountService'
import { CategoryService } from '../services/CategoryService'
import { ScreenshotImportService } from '../services/ScreenshotImportService'
import { Bill } from '../models/Bill'
import { SettingsStore } from '../services/SettingsStore'
import { ScreenshotMonitorService, ScreenshotCandidate } from '../services/ScreenshotMonitorService'
import { QuickAddBillPage } from './QuickAddBillPage'
import { CaptureReviewPage } from './CaptureReviewPage'
import { FloatingCaptureButton, FloatingState } from '../components/FloatingCaptureButton'
import { ScreenCaptureService } from '../services/ScreenCaptureService'
import { FloatingTriggerService } from '../services/FloatingTriggerService'

@Component
export struct HomePage {
  private readonly repo: BillRepository = new BillRepository()
  private readonly accountService: AccountService = new AccountService()
  private readonly categoryService: CategoryService = new CategoryService()
  private readonly screenshotImportService: ScreenshotImportService = new ScreenshotImportService()

  @State todayBills: Bill[] = []
  @State monthExpense: number = 0
  @State monthBudget: number = 3000
  @State showQuickAdd: boolean = false

  @State showCaptureReview: boolean = false
  @State selectedImageUri: string = ''
  @State importErrorText: string = ''
  @State reminderVisible: boolean = false
  @State reminderText: string = ''
  @State floatingState: FloatingState = 'full'
  @State floatingX: number = 260
  @State floatingY: number = 520
  @State captureHintText: string = ''
  @State floatingAvailable: boolean = true

  private pendingScreenshot: ScreenshotCandidate | null = null

  private readonly settingsStore: SettingsStore = new SettingsStore()
  private readonly screenshotMonitorService: ScreenshotMonitorService = new ScreenshotMonitorService()
  private readonly screenCaptureService: ScreenCaptureService = new ScreenCaptureService()
  private readonly floatingTriggerService: FloatingTriggerService = new FloatingTriggerService()

  aboutToAppear(): void {
    this.seedIfEmpty()
    this.refreshData()
    this.tryAutoRecognizeReminder()
    const pos = this.settingsStore.getFloatingPosition()
    this.floatingX = pos.x
    this.floatingY = pos.y
    this.floatingState = this.settingsStore.getFloatingState()
    this.floatingAvailable = this.floatingTriggerService.detectCapability().available
  }

  private async importPaymentScreenshot(): Promise<void> {
    this.importErrorText = ''
    const result = await this.screenshotImportService.pickImageFromSystem()
    if (result.status === 'cancel') {
      this.importErrorText = '已取消选择图片'
      return
    }
    if (result.status === 'error' || !result.uri) {
      this.importErrorText = result.errorMessage ?? '图片读取失败'
      return
    }
    this.selectedImageUri = result.uri
    this.showCaptureReview = true
  }


  private async tryAutoRecognizeReminder(): Promise<void> {
    if (!this.settingsStore.isAutoRecognizeScreenshotEnabled()) {
      this.reminderVisible = false
      return
    }

    const candidates = await this.screenshotMonitorService.scanRecentScreenshotCandidates()
    if (candidates.length === 0) {
      this.reminderVisible = false
      return
    }

    const first = candidates[0]
    this.pendingScreenshot = first
    this.reminderText = `检测到新截图：${first.fileName}，是否用于记账？`
    this.reminderVisible = true
  }

  private openReminderScreenshot(): void {
    if (!this.pendingScreenshot) return
    this.selectedImageUri = this.pendingScreenshot.uri
    this.screenshotMonitorService.markProcessed(this.pendingScreenshot.id)
    this.pendingScreenshot = null
    this.reminderVisible = false
    this.showCaptureReview = true
  }

  private dismissReminder(): void {
    if (this.pendingScreenshot) {
      this.screenshotMonitorService.markProcessed(this.pendingScreenshot.id)
      this.pendingScreenshot = null
    }
    this.reminderVisible = false
  }


  private async openFloatingCapture(): Promise<void> {
    const result = await this.screenCaptureService.captureCurrentScreen()
    if (result.status === 'success' && result.imageUri) {
      this.selectedImageUri = result.imageUri
      this.showCaptureReview = true
      this.captureHintText = ''
      return
    }

    this.captureHintText = result.message
    // 降级：引导用户先系统截图，再用导入/自动识别新截图流程
  }

  private seedIfEmpty(): void {
    if (this.repo.listRecent(1).length > 0) {
      return
    }
    const account = this.accountService.getPrimaryAccount()
    const c1 = this.categoryService.matchByKeyword('午餐')
    const c2 = this.categoryService.matchByKeyword('打车')
    const c3 = this.categoryService.matchByKeyword('咖啡')

    this.repo.create({ title: '午餐', billType: 'expense', source: 'manual', categoryId: c1.id, categoryName: c1.name, accountId: account.id, accountName: account.name, amount: 32, occurredAt: '2026-04-29' })
    this.repo.create({ title: '打车', billType: 'expense', source: 'manual', categoryId: c2.id, categoryName: c2.name, accountId: account.id, accountName: account.name, amount: 18.5, occurredAt: '2026-04-29' })
    this.repo.create({ title: '咖啡', billType: 'expense', source: 'manual', categoryId: c3.id, categoryName: c3.name, accountId: account.id, accountName: account.name, amount: 22, occurredAt: '2026-04-29' })
  }

  private refreshData(): void {
    const monthBills = this.repo.listByMonth(2026, 4)
    this.monthExpense = monthBills
      .filter((bill) => bill.billType === 'expense')
      .reduce((sum, bill) => sum + bill.amount, 0)
    this.todayBills = monthBills.filter((item) => item.occurredAt === '2026-04-29')
  }

  build() {
    if (this.showQuickAdd) {
      QuickAddBillPage({
        onSaved: () => {
          this.showQuickAdd = false
          this.refreshData()
        },
        onCancel: () => {
          this.showQuickAdd = false
        }
      })
    } else if (this.showCaptureReview) {
      CaptureReviewPage({
        imageUri: this.selectedImageUri,
        onSaved: () => {
          this.showCaptureReview = false
          this.selectedImageUri = ''
          this.refreshData()
        },
        onBack: () => {
          this.showCaptureReview = false
          this.selectedImageUri = ''
        }
      })
    } else {
      Scroll() {
        Column({ space: 16 }) {
          Text('本月概览')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Start)

          Row({ space: '4%' }) {
            SummaryCard({ label: '本月支出', value: `¥${this.monthExpense.toFixed(2)}` })
            SummaryCard({ label: '本月预算', value: `¥${this.monthBudget.toFixed(2)}` })
          }

          Column({ space: 10 }) {
            Text('今日账单')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .textAlign(TextAlign.Start)

            ForEach(this.todayBills, (item: Bill) => {
              BillItem({ bill: item })
            }, (item: Bill) => item.id)
          }
          .width('100%')

          Button('记一笔')
            .width('100%')
            .height(44)
            .onClick(() => {
              this.showQuickAdd = true
            })

          Button('导入付款截图')
            .width('100%')
            .height(44)
            .onClick(() => {
              this.importPaymentScreenshot()
            })

          Button('付款截图记账（预留入口）').type(ButtonType.Capsule).width('100%').height(40)


          if (this.reminderVisible) {
            Row() {
              Text(this.reminderText)
                .fontSize(12)
                .width('70%')
              Blank()
              Button('记账')
                .height(30)
                .onClick(() => this.openReminderScreenshot())
              Button('忽略')
                .height(30)
                .onClick(() => this.dismissReminder())
            }
            .padding(10)
            .borderRadius(8)
            .backgroundColor('#FFF7E6')
          }


          if (this.settingsStore.isFloatingCaptureEnabled() && this.floatingAvailable) {
            FloatingCaptureButton({
              initialX: this.floatingX,
              initialY: this.floatingY,
              initialState: this.floatingState,
              fullDurationMs: 8000,
              hideDurationMs: this.settingsStore.getFloatingDisplaySeconds() * 1000,
              onCaptureClick: () => { this.openFloatingCapture() },
              onStateChange: (state: FloatingState) => {
                this.floatingState = state
                this.settingsStore.setFloatingState(state)
              },
              onPositionChange: (x: number, y: number) => {
                this.floatingX = x
                this.floatingY = y
                this.settingsStore.setFloatingPosition(x, y)
              }
            })
          }

          if (this.captureHintText.length > 0) {
            Text(this.captureHintText)
              .fontSize(12)
              .fontColor('#A66')
              .width('100%')
              .textAlign(TextAlign.Start)
          }

          if (this.importErrorText.length > 0) {
            Text(this.importErrorText)
              .fontSize(12)
              .fontColor(Color.Red)
              .width('100%')
              .textAlign(TextAlign.Start)
          }
        }
        .padding(16)
        .width('100%')
      }
      .backgroundColor('#F2F3F5')
    }
  }
}
