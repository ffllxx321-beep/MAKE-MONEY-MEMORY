class UserRuleService {
  constructor(){this.rules=[]}
  upsert(k,id,name){const r=this.rules.find(x=>x.keyword===k); if(r){r.categoryId=id;r.categoryName=name;return} this.rules.push({keyword:k,categoryId:id,categoryName:name,priority:10})}
  list(){return [...this.rules]}
  del(k){this.rules=this.rules.filter(x=>x.keyword!==k)}
}
class CategoryService {
  constructor(rs){this.rs=rs}
  match(t){for(const r of this.rs.list()) if(t.includes(r.keyword)) return r.categoryName; if(t.includes('盒马')) return '购物'; return '其他'}
}
function assert(c,m){if(!c)throw new Error(m)}
const rs=new UserRuleService(); const cs=new CategoryService(rs)
assert(cs.match('盒马鲜生')==='购物','default')
rs.upsert('盒马','c_grocery','买菜')
assert(cs.match('盒马鲜生')==='买菜','user rule override')
rs.upsert('盒马','c_food','餐饮')
assert(cs.match('盒马鲜生')==='餐饮','update existing rule')
rs.del('盒马')
assert(cs.match('盒马鲜生')==='购物','delete fallback')
console.log('category_service_user_rules_test passed')
