import { HomePage } from '../pages/HomePage'
import { BillListPage } from '../pages/BillListPage'
import { StatsPage } from '../pages/StatsPage'
import { SettingsPage } from '../pages/SettingsPage'

@Component
export struct App {
  @State currentTab: number = 0

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        HomePage()
      }
      .tabBar('首页')

      TabContent() {
        BillListPage()
      }
      .tabBar('账单')

      TabContent() {
        StatsPage()
      }
      .tabBar('统计')

      TabContent() {
        SettingsPage()
      }
      .tabBar('设置')
    }
    .vertical(false)
    .barMode(BarMode.Fixed)
  }
}
