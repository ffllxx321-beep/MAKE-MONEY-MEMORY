function validateAmount(amountText) {
  const amount = Number(amountText)
  if (!amountText || Number.isNaN(amount)) return false
  if (amount <= 0) return false
  return true
}

function assert(cond, msg) { if (!cond) throw new Error(msg) }

assert(validateAmount('12.5') === true, 'positive amount should pass')
assert(validateAmount('0') === false, 'zero should fail')
assert(validateAmount('-1') === false, 'negative should fail')
assert(validateAmount('abc') === false, 'invalid number should fail')
console.log('quick_add_validation_smoke_test passed')
