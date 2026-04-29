function screenCaptureFallback() {
  return {
    status: 'unsupported',
    message: '当前环境不支持普通三方 App 直接截取其它 App 页面。请使用系统截图后返回本 App 自动识别。'
  }
}

function floatingCapability(available) {
  return available
    ? { available: true, message: '浮窗可用' }
    : { available: false, message: '当前设备不支持浮窗入口，可继续用截图导入与自动识别。' }
}

function ocrFailureState() {
  return { success: false, manualInputVisible: true }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

const cap = screenCaptureFallback()
assert(cap.status === 'unsupported', 'screen capture should degrade explicitly')
assert(cap.message.includes('系统截图'), 'screen capture fallback should guide system screenshot')

const f = floatingCapability(false)
assert(f.available === false, 'floating unavailable should be false')
assert(f.message.includes('截图导入'), 'floating fallback should point to screenshot recognition path')

const o = ocrFailureState()
assert(o.success === false && o.manualInputVisible === true, 'ocr failure should enter manual input state')

console.log('fallback_downgrade_smoke_test passed')
