const fs = require('fs')
const path = require('path')

class CategoryService {
  matchByKeyword(text) {
    const t = text || ''
    if (/盒马|生鲜|买菜/.test(t)) return { name: '买菜' }
    if (/餐|咖啡|奶茶|外卖|瑞幸/.test(t)) return { name: '餐饮' }
    if (/京东|淘宝|天猫|超市/.test(t)) return { name: '购物' }
    if (/打车|地铁|公交/.test(t)) return { name: '交通' }
    return { name: '其他' }
  }
}

class PaymentParserLite {
  constructor() {
    this.categoryService = new CategoryService()
  }

  parse(rawText) {
    const text = rawText || ''
    const amountKeys = ['实付', '支付金额', '付款金额', '合计', '总计', '已支付']
    const methods = ['微信支付', '支付宝', '银行卡', '信用卡', '花呗', '余额', '云闪付']

    let amount
    for (const k of amountKeys) {
      const idx = text.indexOf(k)
      if (idx >= 0) {
        const m = text.slice(idx, idx + 30).match(/([0-9]+(?:\.[0-9]{1,2})?)/)
        if (m) { amount = Number(m[1]); break }
      }
    }

    if (amount == null) {
      const all = [...text.matchAll(/([0-9]+(?:\.[0-9]{1,2})?)/g)].map(x => Number(x[1]))
      amount = all.length > 0 ? all[0] : undefined
    }

    let merchant
    const m1 = text.match(/(?:商户|收款方|店铺|门店)[:：]?\s*([^\n]+)/)
    if (m1) merchant = m1[1].trim()
    const m2 = text.match(/向([^\n]{2,24})付款/)
    if (!merchant && m2) merchant = m2[1].trim()

    const paymentMethod = methods.find(m => text.includes(m)) || ''
    const category = this.categoryService.matchByKeyword(merchant || text).name

    return { amount, merchant: merchant || '', paymentMethod, category }
  }
}

function eqAmount(a, b) {
  if (a == null && b == null) return true
  if (a == null || b == null) return false
  return Math.abs(Number(a) - Number(b)) < 0.01
}

function run(labelPath) {
  const fullPath = path.resolve(labelPath)
  const data = JSON.parse(fs.readFileSync(fullPath, 'utf-8'))
  const parser = new PaymentParserLite()

  let total = 0
  let amountCorrect = 0
  let merchantCorrect = 0
  let methodCorrect = 0
  let categoryCorrect = 0

  const details = []

  for (const sample of data.samples) {
    total += 1
    const pred = parser.parse(sample.mock_text)
    const exp = sample.expected

    const a = eqAmount(pred.amount, exp.amount)
    const m = (pred.merchant || '') === (exp.merchant || '')
    const p = (pred.paymentMethod || '') === (exp.payment_method || '')
    const c = (pred.category || '') === (exp.category || '')

    if (a) amountCorrect += 1
    if (m) merchantCorrect += 1
    if (p) methodCorrect += 1
    if (c) categoryCorrect += 1

    details.push({ id: sample.id, amount_ok: a, merchant_ok: m, method_ok: p, category_ok: c, pred, exp })
  }

  const metrics = {
    total,
    amount_accuracy: total ? amountCorrect / total : 0,
    merchant_accuracy: total ? merchantCorrect / total : 0,
    payment_method_accuracy: total ? methodCorrect / total : 0,
    category_accuracy: total ? categoryCorrect / total : 0
  }

  return { dataset: data.dataset_name, version: data.version, metrics, details }
}

if (require.main === module) {
  const labelPath = process.argv[2] || 'test_assets/labels/sample_labels.json'
  const result = run(labelPath)
  console.log('OCR Evaluation Result')
  console.log(JSON.stringify(result.metrics, null, 2))
}

module.exports = { run }
