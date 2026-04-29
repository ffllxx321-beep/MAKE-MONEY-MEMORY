import { OcrResult } from '../models/OcrResult'
import { ParseCandidate } from '../models/ParseCandidate'
import { CategoryService } from './CategoryService'

export class PaymentParser {
  private readonly categoryService: CategoryService = new CategoryService()

  parse(input: { rawText?: string; lines?: string[] }): ParseCandidate[] {
    const text = this.buildText(input)
    const lines = this.buildLines(input, text)

    const warnings: string[] = []
    const amountMatches = this.extractAmountCandidates(text)
    if (amountMatches.length === 0) {
      warnings.push('未识别到金额')
    }
    if (amountMatches.length > 1) {
      warnings.push('存在多个金额候选')
    }

    const amount = amountMatches.length > 0 ? amountMatches[0].amount : undefined
    const merchant = this.extractMerchant(text, lines)
    if (!merchant) {
      warnings.push('未识别到商户')
    }

    const paymentMethod = this.extractPaymentMethod(text)
    if (!paymentMethod) {
      warnings.push('未识别到支付方式')
    }

    const paidAt = this.extractPaidTime(text)
    const categorySuggestion = merchant
      ? this.categoryService.matchByKeyword(merchant).name
      : amount ? this.categoryService.matchByKeyword(text).name : undefined

    let confidence = 0.15
    if (amount !== undefined) confidence += 0.45
    if (merchant) confidence += 0.2
    if (paymentMethod) confidence += 0.15
    if (paidAt) confidence += 0.05
    if (warnings.length > 1) confidence -= 0.1
    confidence = Math.max(0, Math.min(1, confidence))

    const candidate: ParseCandidate = {
      amount,
      amountCandidates: amountMatches.map((item) => item.amount),
      merchant: merchant ?? undefined,
      paymentMethod: paymentMethod ?? undefined,
      paidAt: paidAt ?? undefined,
      categorySuggestion,
      confidence,
      warnings,
      shouldConfirmManually: confidence < 0.75
    }

    return [candidate]
  }

  parseFromOcrResult(ocrResult: OcrResult): ParseCandidate[] {
    const lines = ocrResult.lines.map((item) => item.text)
    return this.parse({ rawText: ocrResult.fullText, lines })
  }

  private buildText(input: { rawText?: string; lines?: string[] }): string {
    const raw = input.rawText?.trim() ?? ''
    if (raw.length > 0) return raw
    return (input.lines ?? []).join('\n')
  }

  private buildLines(input: { rawText?: string; lines?: string[] }, text: string): string[] {
    if (input.lines && input.lines.length > 0) return input.lines
    return text.split('\n').map((item) => item.trim()).filter((item) => item.length > 0)
  }

  private extractAmountCandidates(text: string): Array<{ amount: number; score: number }> {
    const keywords = ['实付', '支付金额', '付款金额', '合计', '总计', '已支付']
    const noiseWords = ['优惠', '红包', '积分', '运费', '订单号', '手机号', '时间']

    const candidates: Array<{ amount: number; score: number }> = []
    const allAmountRegex = /(?:¥|￥)?\s*([0-9]{1,6}(?:\.[0-9]{1,2})?)/g

    for (const keyword of keywords) {
      const idx = text.indexOf(keyword)
      if (idx < 0) continue
      const windowText = text.slice(Math.max(0, idx - 8), Math.min(text.length, idx + 28))
      const m = windowText.match(/([0-9]{1,6}(?:\.[0-9]{1,2})?)/)
      if (m) {
        const amount = Number(m[1])
        if (amount > 0) {
          candidates.push({ amount, score: 0.9 })
        }
      }
    }

    let match: RegExpExecArray | null
    while ((match = allAmountRegex.exec(text)) !== null) {
      const amount = Number(match[1])
      if (!(amount > 0)) continue

      const start = Math.max(0, match.index - 6)
      const end = Math.min(text.length, match.index + 12)
      const around = text.slice(start, end)
      const isNoise = noiseWords.some((word) => around.includes(word))
      if (isNoise) continue

      const score = amount < 100000 ? 0.45 : 0.2
      candidates.push({ amount, score })
    }

    const uniq = new Map<string, { amount: number; score: number }>()
    for (const c of candidates) {
      const key = c.amount.toFixed(2)
      const old = uniq.get(key)
      if (!old || c.score > old.score) uniq.set(key, c)
    }

    return [...uniq.values()].sort((a, b) => b.score - a.score || b.amount - a.amount)
  }

  private extractPaymentMethod(text: string): string | null {
    const mapping: Array<{ key: string; name: string }> = [
      { key: '微信支付', name: '微信支付' },
      { key: '支付宝', name: '支付宝' },
      { key: '银行卡', name: '银行卡' },
      { key: '信用卡', name: '信用卡' },
      { key: '花呗', name: '花呗' },
      { key: '余额', name: '余额' },
      { key: '云闪付', name: '云闪付' }
    ]
    for (const item of mapping) {
      if (text.includes(item.key)) return item.name
    }
    return null
  }

  private extractMerchant(text: string, lines: string[]): string | null {
    const keys = ['商户', '收款方', '店铺', '门店']
    for (const line of lines) {
      for (const key of keys) {
        const idx = line.indexOf(key)
        if (idx >= 0) {
          const cleaned = line.replace(/(商户|收款方|店铺|门店|:|：)/g, '').trim()
          if (cleaned.length > 0) return cleaned
        }
      }
    }

    // fallback: look for “向XXX付款”
    const toPay = text.match(/向([\u4e00-\u9fa5A-Za-z0-9·\-]{2,24})付款/)
    if (toPay && toPay[1]) return toPay[1]
    return null
  }

  private extractPaidTime(text: string): string | null {
    const m = text.match(/(20\d{2}[-/.]\d{1,2}[-/.]\d{1,2}\s*\d{1,2}:\d{2}(?::\d{2})?)/)
    if (m && m[1]) return m[1].replace(/\./g, '-').replace(/\//g, '-')
    return null
  }
}
