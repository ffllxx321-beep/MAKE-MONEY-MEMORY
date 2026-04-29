class SettingsStore {
  static autoSave = false
  static sec = 8
  static apps = ['微信', '支付宝']
  static x = 260
  static y = 520
  isAutoSaveAfterRecognizeEnabled() { return SettingsStore.autoSave }
  setAutoSaveAfterRecognizeEnabled(v) { SettingsStore.autoSave = v }
  getFloatingDisplaySeconds() { return SettingsStore.sec }
  setFloatingDisplaySeconds(s) { if ([5,8,15].includes(s)) SettingsStore.sec = s }
  getFloatingEnabledApps() { return [...SettingsStore.apps] }
  setFloatingEnabledApps(a) { SettingsStore.apps = [...a] }
  resetFloatingPosition() { SettingsStore.x = 260; SettingsStore.y = 520 }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

const store = new SettingsStore()
assert(store.isAutoSaveAfterRecognizeEnabled() === false, 'auto save should be off by default')
store.setFloatingDisplaySeconds(15)
assert(store.getFloatingDisplaySeconds() === 15, 'display seconds should support 15')
store.setFloatingDisplaySeconds(9)
assert(store.getFloatingDisplaySeconds() === 15, 'invalid seconds should be ignored')
store.setFloatingEnabledApps(['微信', '美团'])
assert(store.getFloatingEnabledApps().length === 2, 'enabled app list should persist')
store.resetFloatingPosition()
console.log('settings_page_options_smoke_test passed')
