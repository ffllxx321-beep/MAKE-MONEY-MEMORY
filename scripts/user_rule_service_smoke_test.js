class UserRuleService {
  static rules = []
  listRules() { return [...UserRuleService.rules] }
  upsertMerchantCategoryRule(keyword, categoryId, categoryName) {
    const existed = UserRuleService.rules.find((r) => r.keyword === keyword)
    if (existed) {
      existed.categoryId = categoryId
      existed.categoryName = categoryName
      existed.priority += 1
      return existed
    }
    const r = { id: 'r_' + (UserRuleService.rules.length + 1), keyword, categoryId, categoryName, priority: 10 }
    UserRuleService.rules.push(r)
    return r
  }
  deleteRule(id) {
    const before = UserRuleService.rules.length
    UserRuleService.rules = UserRuleService.rules.filter((r) => r.id !== id)
    return UserRuleService.rules.length < before
  }
}

class CategoryService {
  constructor(userRuleService) { this.userRuleService = userRuleService }
  matchByKeyword(text) {
    const rules = this.userRuleService.listRules().sort((a,b)=>b.priority-a.priority)
    for (const r of rules) if (text.includes(r.keyword)) return { id: r.categoryId, name: r.categoryName }
    if (text.includes('盒马')) return { id: 'c_shopping', name: '购物' }
    return { id: 'c_other', name: '其他' }
  }
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

const ruleService = new UserRuleService()
const categoryService = new CategoryService(ruleService)

// 默认：盒马 -> 购物
let c = categoryService.matchByKeyword('盒马鲜生')
assert(c.name === '购物', 'default category should be 购物')

// 用户改成买菜后，用户规则优先
ruleService.upsertMerchantCategoryRule('盒马', 'c_grocery', '买菜')
c = categoryService.matchByKeyword('盒马鲜生')
assert(c.name === '买菜', 'user rule should override default keyword rule')

// 删除规则后恢复默认
const rule = ruleService.listRules()[0]
ruleService.deleteRule(rule.id)
c = categoryService.matchByKeyword('盒马鲜生')
assert(c.name === '购物', 'after deleting rule should fallback to default')

console.log('user_rule_service_smoke_test passed')
