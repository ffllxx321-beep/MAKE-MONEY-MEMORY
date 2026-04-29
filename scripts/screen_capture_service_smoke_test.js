class ScreenCaptureService {
  async captureCurrentScreen() {
    const support = this.detectSupport()
    if (!support.supported) {
      return {
        status: support.requirePermission ? 'permission_required' : 'unsupported',
        message: support.message
      }
    }
    const uri = await this.doSystemCapture()
    if (!uri) return { status: 'failed', message: '截图失败，请改用系统截图后返回 App 自动识别。' }
    return { status: 'success', imageUri: uri, message: '截图成功' }
  }
  detectSupport() {
    return { supported: false, requirePermission: false, message: '当前环境不支持普通三方 App 直接截取其它 App 页面。请使用系统截图后返回本 App 自动识别。' }
  }
  async doSystemCapture() { return null }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

;(async () => {
  const svc = new ScreenCaptureService()
  const r = await svc.captureCurrentScreen()
  assert(r.status === 'unsupported', 'unsupported env should return unsupported')
  assert(!r.imageUri, 'unsupported should not fake success uri')
  assert(r.message.includes('系统截图'), 'unsupported should provide fallback message')
  console.log('screen_capture_service_smoke_test passed')
})()
