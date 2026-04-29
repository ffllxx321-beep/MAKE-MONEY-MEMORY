export type ScreenCaptureStatus =
  | 'success'
  | 'permission_required'
  | 'unsupported'
  | 'failed'

export interface ScreenCaptureResult {
  status: ScreenCaptureStatus
  imageUri?: string
  message: string
}

/**
 * ScreenCaptureService
 *
 * 说明：
 * - 当前仓库环境无法验证“普通三方 App 一键截取其它 App 页面”的稳定公开 API。
 * - 因此默认采取能力探测 + 安全降级策略。
 * TODO: 在目标 HarmonyOS SDK 验证官方公开截屏 API 后，替换 `detectSupport` 与 `doSystemCapture`。
 */
export class ScreenCaptureService {
  async captureCurrentScreen(): Promise<ScreenCaptureResult> {
    const support = this.detectSupport()
    if (!support.supported) {
      return {
        status: support.requirePermission ? 'permission_required' : 'unsupported',
        message: support.message
      }
    }

    try {
      const uri = await this.doSystemCapture()
      if (!uri) {
        return {
          status: 'failed',
          message: '截图失败，请改用系统截图后返回 App 自动识别。'
        }
      }
      return {
        status: 'success',
        imageUri: uri,
        message: '截图成功'
      }
    } catch (error) {
      return {
        status: 'failed',
        message: `截图失败：${JSON.stringify(error)}`
      }
    }
  }

  private detectSupport(): { supported: boolean; requirePermission: boolean; message: string } {
    // 当前默认：不假装支持跨应用截图。
    return {
      supported: false,
      requirePermission: false,
      message: '当前环境不支持普通三方 App 直接截取其它 App 页面。请使用系统截图后返回本 App 自动识别。'
    }
  }

  private async doSystemCapture(): Promise<string | null> {
    // TODO: 目标 SDK 可用时，调用官方公开 API 完成一次性截图并返回图片 URI。
    return null
  }
}
