import { Bill } from '../models/Bill'
import { LocalStore } from './storage/LocalStore'
import { InMemoryStore } from './storage/InMemoryStore'

export class BillRepository {
  private static readonly STORAGE_KEY: string = 'bills'
  private static readonly SHARED_STORE: LocalStore = new InMemoryStore()

  private readonly store: LocalStore

  constructor(store?: LocalStore) {
    this.store = store ?? BillRepository.SHARED_STORE
  }

  create(input: Omit<Bill, 'id'>): Bill {
    const bills = this.getAll()
    const bill: Bill = { ...input, id: `bill_${Date.now()}_${Math.floor(Math.random() * 10000)}` }
    bills.unshift(bill)
    this.saveAll(bills)
    return bill
  }

  update(bill: Bill): Bill | null {
    const bills = this.getAll()
    const index = bills.findIndex((item) => item.id === bill.id)
    if (index < 0) {
      return null
    }
    bills[index] = bill
    this.saveAll(bills)
    return bill
  }

  delete(id: string): boolean {
    const bills = this.getAll()
    const next = bills.filter((item) => item.id !== id)
    if (next.length === bills.length) {
      return false
    }
    this.saveAll(next)
    return true
  }

  findById(id: string): Bill | null {
    return this.getAll().find((item) => item.id === id) ?? null
  }

  listByMonth(year: number, month: number): Bill[] {
    const prefix = `${year}-${month.toString().padStart(2, '0')}`
    return this.getAll().filter((item) => item.occurredAt.startsWith(prefix))
  }

  listRecent(limit: number = 10): Bill[] {
    const all = [...this.getAll()]
    all.sort((a, b) => (a.occurredAt < b.occurredAt ? 1 : -1))
    return all.slice(0, limit)
  }

  private getAll(): Bill[] {
    return this.store.get<Bill[]>(BillRepository.STORAGE_KEY, [])
  }

  private saveAll(bills: Bill[]): void {
    this.store.set<Bill[]>(BillRepository.STORAGE_KEY, bills)
  }
}
