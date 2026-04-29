class ScreenshotImportService {
  async createPreviewImage(uri) { return `preview://${uri}` }
  async prepareImageForOcr(uri, maxEdgePx = 2048) { return `ocr://${maxEdgePx}/${uri}` }
  async releaseTempImage(_uri) { return }
}

class MockOcrService {
  async recognize({ imageUri }) {
    return { success: true, fullText: `实付 12.3 ${imageUri}`, lines: [{ text: '实付 12.3', confidence: 0.9 }] }
  }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

;(async () => {
  const importService = new ScreenshotImportService()
  const ocr = new MockOcrService()

  const uris = Array.from({ length: 20 }).map((_, i) => `mock://shot_${i}.png`)
  let success = 0

  for (const uri of uris) {
    const preview = await importService.createPreviewImage(uri)
    assert(preview.startsWith('preview://'), 'preview should be compressed uri')
    const ocrInput = await importService.prepareImageForOcr(uri, 2048)
    const r = await ocr.recognize({ imageUri: ocrInput })
    assert(r.success === true, 'ocr should succeed')
    await importService.releaseTempImage(ocrInput)
    success += 1
  }

  assert(success === 20, 'all multi-import runs should complete')
  console.log('multi_import_stability_smoke_test passed')
})()
