export type ImportStatus = 'success' | 'cancel' | 'error'

export interface ImportResult {
  status: ImportStatus
  uri?: string
  errorMessage?: string
}

/**
 * ScreenshotImportService
 * - 统一封装截图导入入口
 * - 当前阶段：优先尝试系统选择器（若运行环境不支持则返回可降级错误）
 */
export class ScreenshotImportService {
  async pickImageFromSystem(): Promise<ImportResult> {
    try {
      // HarmonyOS SDK capability may vary by version.
      // Keep implementation defensive: runtime failure -> error result.
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const pickerModule: any = globalThis as Object
      if (!pickerModule) {
        return { status: 'error', errorMessage: '系统图片选择器不可用' }
      }

      // 当前仓库阶段使用 mock 成功结果，后续替换为真实系统 picker。
      return { status: 'success', uri: 'mock://payment_screenshot_001.png' }
    } catch (error) {
      return { status: 'error', errorMessage: `读取图片失败: ${JSON.stringify(error)}` }
    }
  }

  isLikelyScreenshot(uri: string, fileName?: string): boolean {
    const raw = `${uri} ${fileName ?? ''}`.toLowerCase()
    return raw.includes('screenshot') || raw.includes('screenshots') || raw.includes('截屏')
  }

  async createPreviewImage(uri: string): Promise<string> {
    // TODO: 目标 SDK 中使用真实图片压缩生成预览图
    return `preview://${uri}`
  }

  async prepareImageForOcr(uri: string, maxEdgePx: number = 2048): Promise<string> {
    // TODO: 目标 SDK 中按 maxEdgePx 限制图片尺寸并压缩
    return `ocr://${maxEdgePx}/${uri}`
  }

  async releaseTempImage(uri: string): Promise<void> {
    // TODO: 目标 SDK 中删除临时文件/释放资源
    void uri
  }
}
