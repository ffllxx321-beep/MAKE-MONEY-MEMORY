@Component
export struct StatsPage {
  build() {
    Column({ space: 12 }) {
      Text('统计')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
      Text('这里将展示按分类/按月份的支出统计（Mock阶段）')
        .fontSize(14)
        .fontColor('#666666')
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F3F5')
    .alignItems(HorizontalAlign.Start)
  }
}
