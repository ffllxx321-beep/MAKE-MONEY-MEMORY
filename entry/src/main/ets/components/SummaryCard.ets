@Component
export struct SummaryCard {
  @Prop label: string = ''
  @Prop value: string = ''

  build() {
    Column({ space: 8 }) {
      Text(this.label)
        .fontSize(14)
        .fontColor('#666666')
      Text(this.value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius(12)
    .backgroundColor('#F5F7FA')
    .width('48%')
  }
}
