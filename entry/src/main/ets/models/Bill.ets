export type BillType = 'expense' | 'income'
export type BillSource = 'manual' | 'screenshot'

export interface Bill {
  id: string
  title: string
  billType: BillType
  source: BillSource
  categoryId: string
  categoryName: string
  accountId: string
  accountName: string
  amount: number
  occurredAt: string
  note?: string
}
