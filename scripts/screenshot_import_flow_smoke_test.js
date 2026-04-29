class ScreenshotImportService {
  constructor(mode = 'success') { this.mode = mode }
  async pickImageFromSystem() {
    if (this.mode === 'cancel') return { status: 'cancel' }
    if (this.mode === 'error') return { status: 'error', errorMessage: '读取图片失败' }
    return { status: 'success', uri: 'mock://payment_screenshot_001.png' }
  }
}

async function runFlow(service) {
  const result = await service.pickImageFromSystem()
  if (result.status === 'cancel') return 'cancel'
  if (result.status === 'error' || !result.uri) return 'error'
  return 'review'
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

;(async () => {
  assert(await runFlow(new ScreenshotImportService('success')) === 'review', 'success should enter review page')
  assert(await runFlow(new ScreenshotImportService('cancel')) === 'cancel', 'cancel should be handled')
  assert(await runFlow(new ScreenshotImportService('error')) === 'error', 'error should be handled')
  console.log('screenshot_import_flow_smoke_test passed')
})()
