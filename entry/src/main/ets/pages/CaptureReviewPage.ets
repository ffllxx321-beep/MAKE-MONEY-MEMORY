import { OcrResult } from '../models/OcrResult'
import { OcrService } from '../services/ocr/OcrService'
import { MockOcrService } from '../services/ocr/MockOcrService'
import { PaymentParser } from '../services/PaymentParser'
import { ParseCandidate } from '../models/ParseCandidate'
import { CategoryService } from '../services/CategoryService'
import { UserRuleService } from '../services/UserRuleService'
import { AccountService } from '../services/AccountService'
import { Category } from '../models/Category'
import { Account } from '../models/Account'
import { BillRepository } from '../data/BillRepository'
import { ScreenshotImportService } from '../services/ScreenshotImportService'

@Component
export struct CaptureReviewPage {
  @Prop imageUri: string = ''
  @Prop onBack: () => void = () => {}
  @Prop onSaved: () => void = () => {}

  @State isRecognizing: boolean = false
  @State ocrResult: OcrResult = { success: false, fullText: '', lines: [] }
  @State parseCandidates: ParseCandidate[] = []
  @State previewImageUri: string = ''
  @State userManualText: string = ''

  @State amountText: string = ''
  @State merchantText: string = ''
  @State occurredAtText: string = '2026-04-29 12:00'
  @State noteText: string = ''
  @State saveErrorText: string = ''
  @State saveSuccessText: string = ''
  @State hasSaved: boolean = false

  @State categories: Category[] = []
  @State accounts: Account[] = []
  @State selectedCategoryIndex: number = 0
  @State selectedAccountIndex: number = 0

  private readonly ocrService: OcrService = new MockOcrService()
  private readonly paymentParser: PaymentParser = new PaymentParser()
  private readonly categoryService: CategoryService = new CategoryService()
  private readonly accountService: AccountService = new AccountService()
  private readonly billRepository: BillRepository = new BillRepository()
  private readonly userRuleService: UserRuleService = new UserRuleService()
  private readonly screenshotImportService: ScreenshotImportService = new ScreenshotImportService()

  async aboutToAppear(): Promise<void> {
    this.categories = this.categoryService.getDefaultCategories()
    this.accounts = this.accountService.getDefaultAccounts()
    this.previewImageUri = await this.screenshotImportService.createPreviewImage(this.imageUri)
  }

  private async startRecognize(): Promise<void> {
    this.isRecognizing = true
    this.ocrResult = { success: false, fullText: '', lines: [] }
    this.parseCandidates = []
    this.saveErrorText = ''
    this.saveSuccessText = ''
    this.hasSaved = false

    let ocrInputUri = ''
    try {
      // 1) OCR 前限制图片尺寸
      ocrInputUri = await this.screenshotImportService.prepareImageForOcr(this.imageUri, 2048)

      // 2) OCR 与解析异步执行
      const result = await this.ocrService.recognize({ imageUri: ocrInputUri })
      this.ocrResult = result
      if (result.success) {
        this.parseCandidates = this.paymentParser.parseFromOcrResult(result)
        this.fillDraftFromBestCandidate()
      }
    } finally {
      // 3) 识别完成后释放临时资源
      if (ocrInputUri.length > 0) {
        await this.screenshotImportService.releaseTempImage(ocrInputUri)
      }
      this.isRecognizing = false
    }
  }

  private fillDraftFromBestCandidate(): void {
    if (this.parseCandidates.length === 0) {
      return
    }
    const best = this.parseCandidates[0]
    this.amountText = best.amount ? best.amount.toFixed(2) : ''
    this.merchantText = best.merchant ?? ''
    this.occurredAtText = best.paidAt ?? this.occurredAtText
    this.noteText = best.paymentMethod ? `支付方式: ${best.paymentMethod}` : ''

    if (best.categorySuggestion) {
      const idx = this.categories.findIndex((item) => item.name === best.categorySuggestion)
      if (idx >= 0) {
        this.selectedCategoryIndex = idx
      }
    }
  }

  private pickAmount(value: number): void {
    this.amountText = value.toFixed(2)
  }

  private saveBill(): void {
    if (this.hasSaved) {
      this.saveErrorText = '该账单已保存，请勿重复保存'
      return
    }

    const amount = Number(this.amountText)
    if (!this.amountText || Number.isNaN(amount) || amount <= 0) {
      this.saveErrorText = '请填写有效金额（大于0）'
      return
    }
    if (!this.merchantText || this.merchantText.trim().length === 0) {
      this.saveErrorText = '请填写商户'
      return
    }
    if (this.categories.length === 0 || this.accounts.length === 0) {
      this.saveErrorText = '分类或账户不可用'
      return
    }

    const category = this.categories[this.selectedCategoryIndex]
    const account = this.accounts[this.selectedAccountIndex]

    this.billRepository.create({
      title: this.merchantText.trim(),
      billType: 'expense',
      source: 'screenshot',
      categoryId: category.id,
      categoryName: category.name,
      accountId: account.id,
      accountName: account.name,
      amount,
      occurredAt: this.occurredAtText,
      note: this.noteText.length > 0 ? this.noteText : this.userManualText
    })

    if (this.merchantText.trim().length > 0 && category.id.length > 0) {
      this.userRuleService.upsertMerchantCategoryRule(this.merchantText.trim(), category.id, category.name)
    }

    this.saveErrorText = ''
    this.saveSuccessText = '保存成功'
    this.hasSaved = true
    this.onSaved()
  }

  build() {
    Column({ space: 10 }) {
      Text('识别确认').fontSize(22).fontWeight(FontWeight.Bold).width('100%').textAlign(TextAlign.Start)

      // 1) 截图预览
      Text('截图预览').fontSize(14).fontColor('#666666').width('100%').textAlign(TextAlign.Start)
      Text(this.previewImageUri.length > 0 ? this.previewImageUri : (this.imageUri.length > 0 ? this.imageUri : '未选择图片'))
        .fontSize(12).fontColor('#888888').width('100%').textAlign(TextAlign.Start)
        .padding(10).backgroundColor(Color.White).borderRadius(8)

      // 2) OCR 状态
      Text(this.isRecognizing ? 'OCR 状态：识别中...' : 'OCR 状态：待识别')
        .fontSize(12).fontColor('#666').width('100%').textAlign(TextAlign.Start)
      if (this.isRecognizing) {
        Text('正在识别，请稍候...')
          .fontSize(12)
          .fontColor('#666')
          .width('100%')
          .textAlign(TextAlign.Start)
      }

      Button(this.isRecognizing ? '识别中...' : '开始识别')
        .width('100%').height(40).enabled(!this.isRecognizing).onClick(() => this.startRecognize())

      // 3) 最佳候选
      if (this.parseCandidates.length > 0) {
        const best = this.parseCandidates[0]
        Text(`候选：金额 ${best.amount ?? '-'} / 商户 ${best.merchant ?? '-'} / 方式 ${best.paymentMethod ?? '-'}`)
          .fontSize(12).width('100%').textAlign(TextAlign.Start)
        Text(`置信度 ${best.confidence.toFixed(2)}${best.shouldConfirmManually ? '（需确认）' : ''}`)
          .fontSize(12).fontColor(best.shouldConfirmManually ? Color.Red : '#666')
          .width('100%').textAlign(TextAlign.Start)
      }

      // 4) 可编辑核心字段（简洁）
      TextInput({ placeholder: '金额', text: this.amountText })
        .type(InputType.Number)
        .onChange((value: string) => this.amountText = value)
      TextInput({ placeholder: '商户', text: this.merchantText })
        .onChange((value: string) => this.merchantText = value)
      Select(this.categories.map((item) => ({ value: item.name })))
        .selected(this.selectedCategoryIndex)
        .onSelect((idx: number) => this.selectedCategoryIndex = idx)
      Select(this.accounts.map((item) => ({ value: item.name })))
        .selected(this.selectedAccountIndex)
        .onSelect((idx: number) => this.selectedAccountIndex = idx)
      TextInput({ placeholder: '时间', text: this.occurredAtText })
        .onChange((value: string) => this.occurredAtText = value)
      TextInput({ placeholder: '备注', text: this.noteText })
        .onChange((value: string) => this.noteText = value)

      // 5) 多金额候选
      if (this.parseCandidates.length > 0 && this.parseCandidates[0].amountCandidates && this.parseCandidates[0].amountCandidates!.length > 1) {
        Row({ space: 8 }) {
          Text('候选金额:').fontSize(12)
          ForEach(this.parseCandidates[0].amountCandidates!, (value: number) => {
            Button(`¥${value.toFixed(2)}`)
              .height(30)
              .onClick(() => this.pickAmount(value))
          }, (value: number) => value.toString())
        }
      }

      if (this.saveErrorText.length > 0) {
        Text(this.saveErrorText).fontSize(12).fontColor(Color.Red)
      }
      if (this.saveSuccessText.length > 0) {
        Text(this.saveSuccessText).fontSize(12).fontColor('#2E8B57')
      }

      Row({ space: 10 }) {
        Button('返回').layoutWeight(1).onClick(() => this.onBack())
        Button('保存').layoutWeight(1).onClick(() => this.saveBill())
      }
    }
    .padding(16)
    .backgroundColor('#F2F3F5')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
