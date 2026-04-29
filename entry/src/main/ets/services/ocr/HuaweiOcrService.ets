import { OcrInput, OcrResult } from '../../models/OcrResult'
import { OcrService } from './OcrService'

/**
 * HuaweiOcrService
 *
 * 占位实现：当前仓库环境无法验证 HarmonyOS/HiAI OCR 真实 API 接入。
 * 后续在目标 SDK 环境下按官方文档替换 recognize 逻辑。
 */
export class HuaweiOcrService implements OcrService {
  async recognize(_input: OcrInput): Promise<OcrResult> {
    return {
      success: false,
      fullText: '',
      lines: [],
      errorMessage: '当前环境未接入华为 OCR SDK，请在目标 HarmonyOS SDK 中完成接入（TODO）'
    }
  }
}
