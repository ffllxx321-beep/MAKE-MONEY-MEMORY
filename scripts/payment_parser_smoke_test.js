class CategoryService {
  matchByKeyword(text) {
    if (/美团|外卖|餐|咖啡|奶茶/.test(text)) return { name: '餐饮' }
    if (/地铁|打车|公交/.test(text)) return { name: '交通' }
    if (/淘宝|京东|超市/.test(text)) return { name: '购物' }
    return { name: '其他' }
  }
}

class PaymentParser {
  constructor() { this.categoryService = new CategoryService() }
  parse({ rawText = '', lines = [] }) {
    const text = rawText || lines.join('\n')
    const lns = lines.length ? lines : text.split('\n')
    const warnings = []

    const amount = this.amount(text, warnings)
    const merchant = this.merchant(text, lns)
    const method = this.method(text)
    const paidAt = (text.match(/(20\d{2}[-/.]\d{1,2}[-/.]\d{1,2}\s*\d{1,2}:\d{2})/) || [])[1]

    if (!merchant) warnings.push('未识别到商户')
    if (!method) warnings.push('未识别到支付方式')
    if (amount == null) warnings.push('未识别到金额')

    let confidence = 0.15 + (amount != null ? 0.45 : 0) + (merchant ? 0.2 : 0) + (method ? 0.15 : 0) + (paidAt ? 0.05 : 0)
    confidence = Math.max(0, Math.min(1, confidence))

    return [{ amount, merchant, paymentMethod: method, paidAt, categorySuggestion: this.categoryService.matchByKeyword(merchant || text).name, confidence, warnings, shouldConfirmManually: confidence < 0.75 }]
  }
  amount(text, warnings) {
    const keys = ['实付', '支付金额', '付款金额', '合计', '总计', '已支付']
    const noise = ['优惠', '红包', '积分', '运费', '订单号', '手机号', '时间']
    const arr = []
    for (const k of keys) {
      const idx = text.indexOf(k)
      if (idx >= 0) {
        const win = text.slice(Math.max(0, idx - 8), Math.min(text.length, idx + 28))
        const m = win.match(/([0-9]{1,6}(?:\.[0-9]{1,2})?)/)
        if (m) arr.push(Number(m[1]))
      }
    }
    const re = /(?:¥|￥)?\s*([0-9]{1,6}(?:\.[0-9]{1,2})?)/g
    let mm
    while ((mm = re.exec(text))) {
      const around = text.slice(Math.max(0, mm.index - 6), Math.min(text.length, mm.index + 12))
      if (noise.some((w) => around.includes(w))) continue
      const n = Number(mm[1]); if (n > 0) arr.push(n)
    }
    const uniq = [...new Set(arr)]
    if (uniq.length > 1) warnings.push('存在多个金额候选')
    return uniq.length ? uniq[0] : undefined
  }
  method(text) {
    for (const k of ['微信支付', '支付宝', '银行卡', '信用卡', '花呗', '余额', '云闪付']) if (text.includes(k)) return k
    return undefined
  }
  merchant(text, lines) {
    for (const line of lines) {
      if (/(商户|收款方|店铺|门店)/.test(line)) return line.replace(/(商户|收款方|店铺|门店|:|：)/g, '').trim()
    }
    const m = text.match(/向([\u4e00-\u9fa5A-Za-z0-9·\-]{2,24})付款/)
    return m ? m[1] : undefined
  }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }
const parser = new PaymentParser()
const cases = [
  ['微信','微信支付\n商户: 瑞幸咖啡\n实付¥23.50\n时间 2026-04-29 09:20',23.5,'微信支付','餐饮'],
  ['支付宝','支付宝\n收款方：盒马鲜生\n支付金额 88.00',88,'支付宝','其他'],
  ['美团','美团外卖\n店铺：小杨生煎\n已支付 34.2',34.2,undefined,'其他'],
  ['淘宝','淘宝订单\n店铺: Apple旗舰店\n合计 5999.00',5999,undefined,'其他'],
  ['京东','京东\n商户：京东自营\n总计 129.00',129,undefined,'购物'],
  ['银行','中国银行\n商户：中石化\n付款金额 300.00\n银行卡',300,'银行卡','其他'],
  ['花呗','支付宝\n收款方: 优衣库\n实付 199.00\n花呗',199,'支付宝','其他'],
  ['云闪付','云闪付\n商户: 全家\n支付金额 17.00',17,'云闪付','其他'],
  ['干扰数字','实付 45.00 优惠5.00 订单号123456',45,undefined,'其他'],
  ['手机号干扰','支付金额 66.00 手机号13800138000',66,undefined,'其他'],
  ['时间干扰','合计 15.00 时间2026-04-29 12:00',15,undefined,'其他'],
  ['向XX付款','向星巴克付款\n已支付 39.00\n微信支付',39,'微信支付','其他']
]

for (const c of cases) {
  const r = parser.parse({ rawText: c[1] })[0]
  assert(Math.abs((r.amount || 0) - c[2]) < 0.01, `${c[0]} amount`)
  if (c[3]) assert(r.paymentMethod === c[3], `${c[0]} method`)
  assert(r.categorySuggestion === c[4], `${c[0]} category`)
}

const low = parser.parse({ rawText: '订单号123456\n手机号13800138000' })[0]
assert(low.shouldConfirmManually === true, 'low confidence should require manual confirm')
console.log('payment_parser_smoke_test passed')
