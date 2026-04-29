import { UserRule } from '../models/UserRule'

export class UserRuleService {
  private static readonly sharedRules: UserRule[] = []

  listRules(): UserRule[] {
    return [...UserRuleService.sharedRules]
  }

  upsertMerchantCategoryRule(keyword: string, categoryId: string, categoryName: string): UserRule | null {
    const normalized = keyword.trim()
    if (normalized.length < 2) {
      return null
    }

    const existed = UserRuleService.sharedRules.find((item) => item.keyword === normalized)
    if (existed) {
      existed.categoryId = categoryId
      existed.categoryName = categoryName
      existed.priority = Math.min(100, existed.priority + 1)
      return existed
    }

    const rule: UserRule = {
      id: `rule_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
      keyword: normalized,
      categoryId,
      categoryName,
      priority: 10
    }
    UserRuleService.sharedRules.push(rule)
    return rule
  }

  deleteRule(ruleId: string): boolean {
    const before = UserRuleService.sharedRules.length
    const next = UserRuleService.sharedRules.filter((item) => item.id !== ruleId)
    if (next.length === before) {
      return false
    }
    UserRuleService.sharedRules.splice(0, UserRuleService.sharedRules.length, ...next)
    return true
  }
}
