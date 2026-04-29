class Parser {
  parse(text) {
    const amountKeys = ['实付', '支付金额', '付款金额', '合计', '总计', '已支付']
    const noise = ['优惠', '红包', '积分', '运费', '订单号', '手机号', '时间']
    const methods = ['微信支付', '支付宝', '银行卡', '信用卡', '花呗', '余额', '云闪付']

    let amount
    const warnings = []
    for (const k of amountKeys) {
      const idx = text.indexOf(k)
      if (idx >= 0) {
        const m = text.slice(idx, idx + 24).match(/([0-9]+(?:\.[0-9]{1,2})?)/)
        if (m) { amount = Number(m[1]); break }
      }
    }
    if (amount == null) {
      const all = [...text.matchAll(/([0-9]+(?:\.[0-9]{1,2})?)/g)].map(x=>Number(x[1]))
      const filtered = all.filter(n => {
        const i = text.indexOf(String(n))
        const around = text.slice(Math.max(0,i-6), i+12)
        return !noise.some(w => around.includes(w))
      })
      if (filtered.length > 1) warnings.push('存在多个金额候选')
      amount = filtered[0]
    }

    let merchant
    const m1 = text.match(/(?:商户|收款方|店铺|门店)[:：]?\s*([^\n]+)/)
    if (m1) merchant = m1[1].trim()
    const m2 = text.match(/向([^\n]{2,24})付款/)
    if (!merchant && m2) merchant = m2[1].trim()
    if (!merchant) warnings.push('未识别到商户')

    const method = methods.find(m => text.includes(m))
    if (!method) warnings.push('未识别到支付方式')

    return { amount, merchant, method, warnings }
  }
}

function assert(c,m){if(!c) throw new Error(m)}
const p = new Parser()
const cases = [
['微信1','微信支付\n商户: 瑞幸\n实付23.5',23.5,'瑞幸','微信支付'],
['微信2','微信支付\n向星巴克付款\n已支付39.0',39,'星巴克','微信支付'],
['支付宝1','支付宝\n收款方：盒马\n支付金额88',88,'盒马','支付宝'],
['支付宝2','支付宝\n门店：麦当劳\n合计42',42,'麦当劳','支付宝'],
['美团1','美团\n店铺：小杨生煎\n已支付34.2',34.2,'小杨生煎',undefined],
['美团2','美团外卖\n门店: 绝味鸭脖\n总计58',58,'绝味鸭脖',undefined],
['淘宝1','淘宝\n店铺: Apple旗舰店\n合计5999',5999,'Apple旗舰店',undefined],
['淘宝2','淘宝\n商户: 天猫超市\n付款金额120',120,'天猫超市',undefined],
['京东1','京东\n商户：京东自营\n总计129',129,'京东自营',undefined],
['京东2','京东\n店铺: 小米旗舰店\n合计899',899,'小米旗舰店',undefined],
['银行1','银行卡\n商户：中石化\n付款金额300',300,'中石化','银行卡'],
['银行2','信用卡\n商户: 招商银行信用卡中心\n实付100',100,'招商银行信用卡中心','信用卡'],
['花呗','花呗\n收款方: 优衣库\n实付199',199,'优衣库','花呗'],
['余额','余额\n收款方: 便利店\n实付12.5',12.5,'便利店','余额'],
['云闪付','云闪付\n商户: 全家\n支付金额17',17,'全家','云闪付'],
['干扰1','实付45 优惠5 订单号123',45,undefined,undefined],
['干扰2','支付金额66 手机号13800138000',66,undefined,undefined],
['干扰3','合计15 时间2026-04-29 12:00',15,undefined,undefined],
['多金额','合计20 实付18 优惠2',18,undefined,undefined],
['无金额','商户: 某店 支付方式 微信支付',undefined,'某店 支付方式 微信支付','微信支付']
]
for (const c of cases){
  const r=p.parse(c[1])
  if (c[2]===undefined) assert(r.amount===undefined, c[0]+' amount undefined')
  else assert(Math.abs(r.amount-c[2])<0.01, c[0]+' amount')
  if (c[3]!==undefined) assert(r.merchant===c[3], c[0]+' merchant')
  if (c[4]!==undefined) assert(r.method===c[4], c[0]+' method')
}
console.log('payment_parser_20_cases_test passed')
