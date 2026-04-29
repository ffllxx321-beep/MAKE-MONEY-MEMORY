import { OcrInput, OcrResult } from '../../models/OcrResult'

export interface OcrService {
  recognize(input: OcrInput): Promise<OcrResult>
}
