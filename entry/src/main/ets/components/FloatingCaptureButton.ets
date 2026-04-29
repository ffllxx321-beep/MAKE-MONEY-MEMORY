export type FloatingState = 'full' | 'edge' | 'hidden'

@Component
export struct FloatingCaptureButton {
  @Prop initialX: number = 260
  @Prop initialY: number = 520
  @Prop initialState: FloatingState = 'full'
  @Prop fullDurationMs: number = 8000
  @Prop hideDurationMs: number = 30000

  @Prop onCaptureClick: () => void = () => {}
  @Prop onStateChange: (state: FloatingState) => void = (_: FloatingState) => {}
  @Prop onPositionChange: (x: number, y: number) => void = (_x: number, _y: number) => {}

  @State x: number = 260
  @State y: number = 520
  @State state: FloatingState = 'full'

  private fullTimer: number = -1
  private hideTimer: number = -1

  aboutToAppear(): void {
    this.x = this.initialX
    this.y = this.initialY
    this.state = this.initialState
    this.scheduleTimers()
  }

  aboutToDisappear(): void {
    this.clearTimers()
  }

  private scheduleTimers(): void {
    this.clearTimers()
    if (this.state === 'full') {
      this.fullTimer = setTimeout(() => {
        this.state = 'edge'
        this.onStateChange(this.state)
      }, this.fullDurationMs) as unknown as number
    }
    this.hideTimer = setTimeout(() => {
      this.state = 'hidden'
      this.onStateChange(this.state)
    }, this.hideDurationMs) as unknown as number
  }

  private clearTimers(): void {
    if (this.fullTimer > 0) clearTimeout(this.fullTimer)
    if (this.hideTimer > 0) clearTimeout(this.hideTimer)
    this.fullTimer = -1
    this.hideTimer = -1
  }

  private expand(): void {
    this.state = 'full'
    this.onStateChange(this.state)
    this.scheduleTimers()
  }

  build() {
    if (this.state === 'hidden') {
      Blank()
    } else {
      Row() {
        if (this.state === 'full') {
          Button('截图记账')
            .height(40)
            .onClick(() => this.onCaptureClick())
        } else {
          Button('记')
            .height(40)
            .width(40)
            .onClick(() => this.expand())
        }
      }
      .position({ x: this.x, y: this.y })
      .gesture(
        PanGesture()
          .onActionUpdate((event) => {
            this.x += event.offsetX
            this.y += event.offsetY
            this.onPositionChange(this.x, this.y)
          })
      )
    }
  }
}
