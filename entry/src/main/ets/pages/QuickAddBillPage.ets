import { BillType } from '../models/Bill'
import { BillRepository } from '../data/BillRepository'
import { CategoryService } from '../services/CategoryService'
import { AccountService } from '../services/AccountService'
import { Category } from '../models/Category'
import { Account } from '../models/Account'

@Component
export struct QuickAddBillPage {
  private readonly repo: BillRepository = new BillRepository()
  private readonly categoryService: CategoryService = new CategoryService()
  private readonly accountService: AccountService = new AccountService()

  @Prop onSaved: () => void = () => {}
  @Prop onCancel: () => void = () => {}

  @State amountText: string = ''
  @State title: string = '手动记账'
  @State note: string = ''
  @State occurredAt: string = '2026-04-29'
  @State billType: BillType = 'expense'

  @State categories: Category[] = []
  @State accounts: Account[] = []
  @State selectedCategoryIndex: number = 0
  @State selectedAccountIndex: number = 0
  @State errorText: string = ''

  aboutToAppear(): void {
    this.categories = this.categoryService.getDefaultCategories()
    this.accounts = this.accountService.getDefaultAccounts()
  }

  private recommendCategoryByNote(note: string): void {
    if (!note || note.trim().length === 0) {
      return
    }
    const suggested = this.categoryService.matchByKeyword(note)
    const idx = this.categories.findIndex((item) => item.id === suggested.id)
    if (idx >= 0) {
      this.selectedCategoryIndex = idx
    }
  }

  private validate(): boolean {
    const amount = Number(this.amountText)
    if (!this.amountText || Number.isNaN(amount)) {
      this.errorText = '请输入有效金额'
      return false
    }
    if (amount <= 0) {
      this.errorText = '金额必须大于 0'
      return false
    }
    if (this.categories.length === 0 || this.accounts.length === 0) {
      this.errorText = '分类或账户不可用'
      return false
    }
    this.errorText = ''
    return true
  }

  private saveBill(): void {
    if (!this.validate()) {
      return
    }
    const amount = Number(this.amountText)
    const category = this.categories[this.selectedCategoryIndex]
    const account = this.accounts[this.selectedAccountIndex]

    this.repo.create({
      title: this.title.trim().length > 0 ? this.title.trim() : '手动记账',
      billType: this.billType,
      source: 'manual',
      categoryId: category.id,
      categoryName: category.name,
      accountId: account.id,
      accountName: account.name,
      amount,
      occurredAt: this.occurredAt,
      note: this.note
    })
    this.onSaved()
  }

  build() {
    Column({ space: 12 }) {
      Text('记一笔')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      TextInput({ placeholder: '金额（必填）', text: this.amountText })
        .type(InputType.Number)
        .onChange((value: string) => this.amountText = value)

      Select([{ value: '支出' }, { value: '收入' }])
        .selected(this.billType === 'expense' ? 0 : 1)
        .onSelect((index: number) => {
          this.billType = index === 0 ? 'expense' : 'income'
        })

      Select(this.categories.map((item) => ({ value: item.name })))
        .selected(this.selectedCategoryIndex)
        .onSelect((index: number) => {
          this.selectedCategoryIndex = index
        })

      Select(this.accounts.map((item) => ({ value: item.name })))
        .selected(this.selectedAccountIndex)
        .onSelect((index: number) => {
          this.selectedAccountIndex = index
        })

      TextInput({ placeholder: '备注（可选，用于分类推荐）', text: this.note })
        .onChange((value: string) => {
          this.note = value
          this.recommendCategoryByNote(value)
        })

      TextInput({ placeholder: '时间，如 2026-04-29', text: this.occurredAt })
        .onChange((value: string) => this.occurredAt = value)

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(12)
          .fontColor(Color.Red)
          .width('100%')
          .textAlign(TextAlign.Start)
      }

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .onClick(() => this.onCancel())
        Button('保存')
          .layoutWeight(1)
          .onClick(() => this.saveBill())
      }
    }
    .padding(16)
    .backgroundColor('#F2F3F5')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
