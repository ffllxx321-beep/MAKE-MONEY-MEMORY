class MockOcrService {
  async recognize(input) {
    if (!input.imageUri && !input.pixelMap) {
      return { success: false, fullText: '', lines: [], errorMessage: '未提供可识别的图片数据' }
    }
    if (input.imageUri && input.imageUri.includes('fail')) {
      return { success: false, fullText: '', lines: [], errorMessage: 'Mock OCR 识别失败（用于测试）' }
    }
    return {
      success: true,
      fullText: '金额: 23.50',
      lines: [{ text: '金额: 23.50', confidence: 0.99 }]
    }
  }
}

class HuaweiOcrService {
  async recognize() {
    return { success: false, fullText: '', lines: [], errorMessage: 'TODO: 华为 OCR 未接入' }
  }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

;(async () => {
  const mock = new MockOcrService()
  const ok = await mock.recognize({ imageUri: 'mock://ok.png' })
  assert(ok.success === true, 'mock service should return success for normal input')

  const failed = await mock.recognize({ imageUri: 'mock://fail.png' })
  assert(failed.success === false, 'mock service should return failure for fail input')
  assert(!!failed.errorMessage, 'failure should contain friendly error message')

  const huawei = new HuaweiOcrService()
  const hw = await huawei.recognize({ imageUri: 'x' })
  assert(hw.success === false, 'huawei placeholder should fail gracefully in this env')
  assert(!!hw.errorMessage, 'huawei placeholder should provide TODO message')

  console.log('ocr_service_smoke_test passed')
})()
