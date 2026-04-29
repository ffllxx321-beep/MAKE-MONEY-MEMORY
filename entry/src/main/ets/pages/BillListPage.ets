import { BillItem } from '../components/BillItem'
import { BillRepository } from '../data/BillRepository'
import { Bill } from '../models/Bill'

@Component
export struct BillListPage {
  private readonly repo: BillRepository = new BillRepository()
  @State bills: Bill[] = []

  aboutToAppear(): void {
    this.refreshBills()
  }

  private refreshBills(): void {
    this.bills = this.repo.listRecent(50)
  }

  build() {
    Column({ space: 12 }) {
      Text('账单列表')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      List({ space: 10 }) {
        ForEach(this.bills, (item: Bill) => {
          ListItem() {
            BillItem({ bill: item })
          }
        }, (item: Bill) => item.id)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .padding(16)
    .backgroundColor('#F2F3F5')
    .height('100%')
  }
}
