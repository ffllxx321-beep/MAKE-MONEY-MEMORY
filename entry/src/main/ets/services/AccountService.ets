import { Account } from '../models/Account'

export class AccountService {
  private readonly defaultAccounts: Account[] = [
    { id: 'a_wechat', name: '微信', type: 'wallet', isDefault: true },
    { id: 'a_alipay', name: '支付宝', type: 'wallet', isDefault: false },
    { id: 'a_cash', name: '现金', type: 'cash', isDefault: false }
  ]

  getDefaultAccounts(): Account[] {
    return [...this.defaultAccounts]
  }

  getPrimaryAccount(): Account {
    return this.defaultAccounts.find((item) => item.isDefault) ?? this.defaultAccounts[0]
  }
}
