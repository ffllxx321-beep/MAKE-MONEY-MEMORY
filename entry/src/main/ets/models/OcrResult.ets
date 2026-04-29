export interface OcrLine {
  text: string
  confidence: number
}

export interface OcrResult {
  success: boolean
  fullText: string
  lines: OcrLine[]
  errorMessage?: string
}

export interface OcrInput {
  imageUri?: string
  // PixelMap 类型在不同 SDK 版本可能有差异，先以 unknown 做抽象占位
  pixelMap?: unknown
}
