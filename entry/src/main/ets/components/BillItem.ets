import { Bill } from '../models/Bill'

@Component
export struct BillItem {
  @Prop bill: Bill = {
    id: '',
    title: '',
    categoryId: '',
    categoryName: '',
    accountId: '',
    accountName: '',
    amount: 0,
    occurredAt: ''
  }

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.bill.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(`${this.bill.categoryName} · ${this.bill.occurredAt}`)
          .fontSize(12)
          .fontColor('#888888')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text(`-¥${this.bill.amount.toFixed(2)}`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
    }
    .padding(12)
    .borderRadius(10)
    .backgroundColor(Color.White)
  }
}
