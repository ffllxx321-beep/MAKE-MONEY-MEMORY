class CategoryService {
  constructor() { this.rules = [] }
  learnMerchantRule(merchant, categoryId, categoryName) {
    this.rules.push({ merchant, categoryId, categoryName })
  }
  getUserRules() { return this.rules }
}

class BillRepository {
  constructor() { this.list = [] }
  create(b) { const x = { ...b, id: 'b_' + (this.list.length + 1) }; this.list.push(x); return x }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

const repo = new BillRepository()
const categoryService = new CategoryService()

const edited = {
  merchant: '瑞幸咖啡',
  amount: 28.8,
  categoryId: 'c_food',
  categoryName: '餐饮',
  accountId: 'a_wechat',
  accountName: '微信',
  occurredAt: '2026-04-29 13:20',
  note: '支付方式: 微信支付'
}

const bill = repo.create({
  title: edited.merchant,
  billType: 'expense',
  source: 'screenshot',
  categoryId: edited.categoryId,
  categoryName: edited.categoryName,
  accountId: edited.accountId,
  accountName: edited.accountName,
  amount: edited.amount,
  occurredAt: edited.occurredAt,
  note: edited.note
})

categoryService.learnMerchantRule(edited.merchant, edited.categoryId, edited.categoryName)

assert(bill.source === 'screenshot', 'saved bill should be screenshot source')
assert(bill.amount === 28.8, 'edited amount should be saved')
assert(categoryService.getUserRules().length === 1, 'rule should be learned after save')
console.log('capture_review_flow_smoke_test passed')
