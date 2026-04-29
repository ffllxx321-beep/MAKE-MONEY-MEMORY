import { Category } from '../models/Category'
import { UserRule } from '../models/UserRule'
import { UserRuleService } from './UserRuleService'

export class CategoryService {
  private readonly categories: Category[] = [
    { id: 'c_food', name: '餐饮', keywords: ['餐', '奶茶', '咖啡', '外卖'], isDefault: true },
    { id: 'c_transport', name: '交通', keywords: ['打车', '地铁', '公交'], isDefault: true },
    { id: 'c_shopping', name: '购物', keywords: ['超市', '商场', '淘宝', '京东'], isDefault: true },
    { id: 'c_entertainment', name: '娱乐', keywords: ['电影', '游戏', 'KTV'], isDefault: true },
    { id: 'c_grocery', name: '买菜', keywords: ['盒马', '生鲜'], isDefault: true },
    { id: 'c_other', name: '其他', keywords: [], isDefault: true }
  ]

  private readonly userRuleService: UserRuleService = new UserRuleService()

  getDefaultCategories(): Category[] {
    return [...this.categories]
  }

  matchByKeyword(text: string, externalRules?: UserRule[]): Category {
    const normalized = text.toLowerCase()

    // 1) 用户规则优先
    const rules = externalRules ?? this.userRuleService.listRules()
    const sortedRules = [...rules].sort((a, b) => b.priority - a.priority)
    for (const rule of sortedRules) {
      if (normalized.includes(rule.keyword.toLowerCase())) {
        return { id: rule.categoryId, name: rule.categoryName, keywords: [], isDefault: false }
      }
    }

    // 2) 默认关键词规则
    for (const category of this.categories) {
      for (const keyword of category.keywords) {
        if (normalized.includes(keyword.toLowerCase())) {
          return category
        }
      }
    }

    return this.categories[this.categories.length - 1]
  }
}
