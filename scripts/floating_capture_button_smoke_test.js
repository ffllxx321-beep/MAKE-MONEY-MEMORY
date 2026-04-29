class SettingsStore {
  static enabled = true
  static state = 'full'
  static x = 260
  static y = 520
  isFloatingCaptureEnabled() { return SettingsStore.enabled }
  setFloatingCaptureEnabled(v) { SettingsStore.enabled = v }
  getFloatingState() { return SettingsStore.state }
  setFloatingState(s) { SettingsStore.state = s }
  getFloatingPosition() { return { x: SettingsStore.x, y: SettingsStore.y } }
  setFloatingPosition(x, y) { SettingsStore.x = x; SettingsStore.y = y }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

const store = new SettingsStore()
assert(store.isFloatingCaptureEnabled() === true, 'floating should be enabled by default')
store.setFloatingState('edge')
assert(store.getFloatingState() === 'edge', 'state should persist edge')
store.setFloatingState('hidden')
assert(store.getFloatingState() === 'hidden', 'state should persist hidden')
store.setFloatingPosition(100, 200)
const pos = store.getFloatingPosition()
assert(pos.x === 100 && pos.y === 200, 'position should persist after drag')
console.log('floating_capture_button_smoke_test passed')
