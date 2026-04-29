import { ScreenshotImportService } from './ScreenshotImportService'

export interface ScreenshotCandidate {
  id: string
  uri: string
  createdAt: string
  fileName: string
}

/**
 * 第一版降级方案：
 * - 当前环境未接入稳定“系统新截图监听”API
 * - 采用 App 打开/回前台时扫描最近截图列表
 * TODO: 在目标 HarmonyOS SDK 可用时替换为官方稳定监听能力
 */
export class ScreenshotMonitorService {
  private static readonly processedIds: Set<string> = new Set()

  private readonly importService: ScreenshotImportService = new ScreenshotImportService()

  async scanRecentScreenshotCandidates(): Promise<ScreenshotCandidate[]> {
    // 当前为 mock 数据，后续接入系统媒体查询 API。
    const recentImages: ScreenshotCandidate[] = [
      { id: 'shot_001', uri: 'mock://Screenshots/Screenshot_20260429_101200.png', createdAt: '2026-04-29 10:12:00', fileName: 'Screenshot_20260429_101200.png' },
      { id: 'camera_001', uri: 'mock://DCIM/Camera/IMG_20260429_090001.jpg', createdAt: '2026-04-29 09:00:01', fileName: 'IMG_20260429_090001.jpg' }
    ]

    return recentImages
      .filter((item) => this.importService.isLikelyScreenshot(item.uri, item.fileName))
      .filter((item) => !ScreenshotMonitorService.processedIds.has(item.id))
  }

  markProcessed(id: string): void {
    ScreenshotMonitorService.processedIds.add(id)
  }
}
