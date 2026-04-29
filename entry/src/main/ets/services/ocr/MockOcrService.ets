import { OcrInput, OcrResult } from '../../models/OcrResult'
import { OcrService } from './OcrService'

export class MockOcrService implements OcrService {
  async recognize(input: OcrInput): Promise<OcrResult> {
    if (!input.imageUri && !input.pixelMap) {
      return {
        success: false,
        fullText: '',
        lines: [],
        errorMessage: '未提供可识别的图片数据'
      }
    }

    if (input.imageUri?.includes('fail')) {
      return {
        success: false,
        fullText: '',
        lines: [],
        errorMessage: 'Mock OCR 识别失败（用于测试）'
      }
    }

    return {
      success: true,
      fullText: '商户: 便利店\n金额: 23.50\n时间: 2026-04-29 12:36\n支付方式: 微信支付',
      lines: [
        { text: '商户: 便利店', confidence: 0.96 },
        { text: '金额: 23.50', confidence: 0.99 },
        { text: '时间: 2026-04-29 12:36', confidence: 0.92 },
        { text: '支付方式: 微信支付', confidence: 0.94 }
      ]
    }
  }
}
