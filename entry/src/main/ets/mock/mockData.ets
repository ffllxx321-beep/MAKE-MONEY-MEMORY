import { Bill } from '../models/Bill'

export const monthlyExpense: number = 1865.5
export const monthlyBudget: number = 3000

export const todayBills: Bill[] = [
  { id: 'b1', title: '午餐', category: '餐饮', amount: 32, date: '2026-04-29' },
  { id: 'b2', title: '打车', category: '交通', amount: 18.5, date: '2026-04-29' },
  { id: 'b3', title: '咖啡', category: '餐饮', amount: 22, date: '2026-04-29' }
]

export const allBills: Bill[] = [
  ...todayBills,
  { id: 'b4', title: '超市', category: '日用', amount: 86, date: '2026-04-28' },
  { id: 'b5', title: '电影票', category: '娱乐', amount: 68, date: '2026-04-27' }
]
