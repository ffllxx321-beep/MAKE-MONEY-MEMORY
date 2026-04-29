export interface Account {
  id: string
  name: string
  type: 'cash' | 'bank' | 'wallet' | 'credit'
  isDefault: boolean
}
