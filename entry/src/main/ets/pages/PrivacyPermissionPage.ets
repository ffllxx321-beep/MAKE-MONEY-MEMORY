@Component
export struct PrivacyPermissionPage {
  @Prop onBack: () => void = () => {}

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('隐私和权限说明')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        Text('我们只做记账需要的最少权限，你可以随时关。')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')
          .textAlign(TextAlign.Start)

        Text('1) 相册权限：用于你手动导入付款截图。')
          .fontSize(14).width('100%').textAlign(TextAlign.Start)
        Text('2) 截图相关能力：用于一键截图（支持时），不支持会提示你用系统截图。')
          .fontSize(14).width('100%').textAlign(TextAlign.Start)
        Text('3) 通知权限：用于给你“有新截图可记账”的提醒。')
          .fontSize(14).width('100%').textAlign(TextAlign.Start)
        Text('4) 浮窗能力：仅用于 App 内快速入口，不做跨 App 悬浮。')
          .fontSize(14).width('100%').textAlign(TextAlign.Start)

        Text('图片默认本地识别，不上传。账单也默认只存本地。')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)

        Text('你可以在设置里关闭：自动识别新截图、付款后显示浮窗。')
          .fontSize(14)
          .width('100%')
          .textAlign(TextAlign.Start)

        Text('如果你不授权：')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)
        Text('- 不能直接导入相册时，可改用系统截图后回到 App 自动识别。')
          .fontSize(13).width('100%').textAlign(TextAlign.Start)
        Text('- 不能一键截图时，会明确提示降级，不会假装成功。')
          .fontSize(13).width('100%').textAlign(TextAlign.Start)
        Text('- 不能用通知/浮窗时，仍可从首页手动导入截图记账。')
          .fontSize(13).width('100%').textAlign(TextAlign.Start)

        Button('返回设置')
          .width('100%')
          .height(40)
          .onClick(() => this.onBack())
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor('#F2F3F5')
  }
}
