export interface FloatingCapability {
  available: boolean
  message: string
}

/**
 * FloatingTriggerService
 *
 * 统一管理浮窗触发能力检测。
 * 当前仓库默认仅支持 App 内浮窗演示；若运行环境能力不足，给出明确降级文案。
 */
export class FloatingTriggerService {
  detectCapability(): FloatingCapability {
    // 当前默认可用：App 内浮窗
    // 若目标环境关闭该能力，可改为 false 并显示降级提示
    const appInFloatingAvailable = true

    if (!appInFloatingAvailable) {
      return {
        available: false,
        message: '当前设备不支持浮窗入口，可继续用截图导入与自动识别。'
      }
    }

    return {
      available: true,
      message: '浮窗可用'
    }
  }
}
