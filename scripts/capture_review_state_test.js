function validateSave(state){
  if(state.hasSaved) return 'duplicate'
  if(!state.amount || Number(state.amount)<=0) return 'invalid_amount'
  if(!state.merchant) return 'missing_merchant'
  return 'ok'
}
function assert(c,m){if(!c)throw new Error(m)}

// OCR失败
let state={hasSaved:false,amount:'',merchant:'',ocrSuccess:false}
assert(validateSave(state)==='invalid_amount','ocr fail should not crash')
// 无金额
state={hasSaved:false,amount:'',merchant:'便利店'}
assert(validateSave(state)==='invalid_amount','no amount')
// 无商户
state={hasSaved:false,amount:'12.3',merchant:''}
assert(validateSave(state)==='missing_merchant','no merchant')
// 多金额候选可选中
const candidates=[12,18,20]; state={hasSaved:false,amount:String(candidates[1]),merchant:'店铺'}
assert(validateSave(state)==='ok','multi amount select')
// 重复保存
state={hasSaved:true,amount:'12',merchant:'店铺'}
assert(validateSave(state)==='duplicate','duplicate save')
console.log('capture_review_state_test passed')
