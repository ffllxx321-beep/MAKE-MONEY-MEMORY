class InMemoryStore {
  constructor() { this.data = new Map() }
  get(key, fallback) { return this.data.has(key) ? this.data.get(key) : fallback }
  set(key, value) { this.data.set(key, value) }
  remove(key) { this.data.delete(key) }
}

class BillRepository {
  static STORAGE_KEY = 'bills'
  static SHARED_STORE = new InMemoryStore()
  constructor(store = BillRepository.SHARED_STORE) { this.store = store }
  create(input) {
    const bills = this.getAll()
    const bill = { ...input, id: `bill_${Date.now()}_${Math.floor(Math.random() * 10000)}` }
    bills.unshift(bill); this.saveAll(bills); return bill
  }
  delete(id) {
    const bills = this.getAll(); const next = bills.filter((i) => i.id !== id)
    if (next.length === bills.length) return false
    this.saveAll(next); return true
  }
  listByMonth(year, month) {
    const prefix = `${year}-${String(month).padStart(2, '0')}`
    return this.getAll().filter((i) => i.occurredAt.startsWith(prefix))
  }
  listRecent(limit = 10) {
    return [...this.getAll()].sort((a,b)=>a.occurredAt < b.occurredAt ? 1 : -1).slice(0, limit)
  }
  getAll() { return this.store.get(BillRepository.STORAGE_KEY, []) }
  saveAll(bills) { this.store.set(BillRepository.STORAGE_KEY, bills) }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

const repoA = new BillRepository()
const created = repoA.create({ title: '午餐', billType: 'expense', categoryId: 'c_food', categoryName: '餐饮', accountId: 'a_wechat', accountName: '微信', amount: 30, occurredAt: '2026-04-29' })
assert(!!created.id, 'create should return id')
assert(repoA.listByMonth(2026, 4).length === 1, 'listByMonth should return created bill')
assert(repoA.listRecent(1).length === 1, 'listRecent should return newest bill')

const repoB = new BillRepository()
assert(repoB.listRecent(1).length === 1, 'cross-instance visibility should work')

assert(repoB.delete(created.id) === true, 'delete should return true')
assert(repoA.listByMonth(2026, 4).length === 0, 'bill should be deleted')
console.log('bill_repository_smoke_test passed')
