import { FloatingState } from '../components/FloatingCaptureButton'

export class SettingsStore {
  private static autoRecognizeEnabled: boolean = false
  private static floatingCaptureEnabled: boolean = true
  private static floatingDisplaySeconds: number = 8
  private static floatingEnabledApps: string[] = ['微信', '支付宝']
  private static floatingX: number = 260
  private static floatingY: number = 520
  private static floatingState: FloatingState = 'full'
  private static autoSaveAfterRecognize: boolean = false

  isAutoRecognizeScreenshotEnabled(): boolean {
    return SettingsStore.autoRecognizeEnabled
  }

  setAutoRecognizeScreenshotEnabled(enabled: boolean): void {
    SettingsStore.autoRecognizeEnabled = enabled
  }

  isFloatingCaptureEnabled(): boolean {
    return SettingsStore.floatingCaptureEnabled
  }

  setFloatingCaptureEnabled(enabled: boolean): void {
    SettingsStore.floatingCaptureEnabled = enabled
  }

  getFloatingDisplaySeconds(): number {
    return SettingsStore.floatingDisplaySeconds
  }

  setFloatingDisplaySeconds(seconds: number): void {
    if ([5, 8, 15].includes(seconds)) {
      SettingsStore.floatingDisplaySeconds = seconds
    }
  }

  getFloatingEnabledApps(): string[] {
    return [...SettingsStore.floatingEnabledApps]
  }

  setFloatingEnabledApps(apps: string[]): void {
    SettingsStore.floatingEnabledApps = [...apps]
  }

  getFloatingPosition(): { x: number; y: number } {
    return { x: SettingsStore.floatingX, y: SettingsStore.floatingY }
  }

  setFloatingPosition(x: number, y: number): void {
    SettingsStore.floatingX = x
    SettingsStore.floatingY = y
  }

  resetFloatingPosition(): void {
    SettingsStore.floatingX = 260
    SettingsStore.floatingY = 520
    SettingsStore.floatingState = 'full'
  }

  getFloatingState(): FloatingState {
    return SettingsStore.floatingState
  }

  setFloatingState(state: FloatingState): void {
    SettingsStore.floatingState = state
  }

  isAutoSaveAfterRecognizeEnabled(): boolean {
    return SettingsStore.autoSaveAfterRecognize
  }

  setAutoSaveAfterRecognizeEnabled(enabled: boolean): void {
    SettingsStore.autoSaveAfterRecognize = enabled
  }
}
