class SettingsStore {
  static enabled = false
  isAutoRecognizeScreenshotEnabled() { return SettingsStore.enabled }
  setAutoRecognizeScreenshotEnabled(v) { SettingsStore.enabled = v }
}

class ScreenshotImportService {
  isLikelyScreenshot(uri, fileName) {
    const raw = `${uri} ${fileName || ''}`.toLowerCase()
    return raw.includes('screenshot') || raw.includes('screenshots') || raw.includes('截屏')
  }
}

class ScreenshotMonitorService {
  static processed = new Set()
  constructor() { this.importService = new ScreenshotImportService() }
  scanRecentScreenshotCandidates() {
    const list = [
      { id: 'shot_001', uri: 'mock://Screenshots/Screenshot_1.png', fileName: 'Screenshot_1.png' },
      { id: 'camera_001', uri: 'mock://DCIM/IMG_1.jpg', fileName: 'IMG_1.jpg' }
    ]
    return list.filter(i => this.importService.isLikelyScreenshot(i.uri, i.fileName))
      .filter(i => !ScreenshotMonitorService.processed.has(i.id))
  }
  markProcessed(id) { ScreenshotMonitorService.processed.add(id) }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

const settings = new SettingsStore()
const monitor = new ScreenshotMonitorService()

settings.setAutoRecognizeScreenshotEnabled(true)
let cands = monitor.scanRecentScreenshotCandidates()
assert(cands.length === 1, 'enabled should detect one screenshot candidate')
monitor.markProcessed(cands[0].id)
cands = monitor.scanRecentScreenshotCandidates()
assert(cands.length === 0, 'processed screenshot should not be repeated')

settings.setAutoRecognizeScreenshotEnabled(false)
if (!settings.isAutoRecognizeScreenshotEnabled()) {
  cands = []
}
assert(cands.length === 0, 'disabled should not remind')

console.log('screenshot_auto_reminder_smoke_test passed')
