class Repo {
  constructor(){this.items=[]}
  create(b){const x={...b,id:'b'+(this.items.length+1)};this.items.push(x);return x}
  findById(id){return this.items.find(i=>i.id===id)||null}
  update(b){const i=this.items.findIndex(x=>x.id===b.id); if(i<0) return null; this.items[i]=b; return b}
  delete(id){const n=this.items.length; this.items=this.items.filter(i=>i.id!==id); return this.items.length<n}
  listByMonth(y,m){const p=`${y}-${String(m).padStart(2,'0')}`; return this.items.filter(i=>i.occurredAt.startsWith(p))}
  listRecent(n=10){return [...this.items].slice(-n).reverse()}
}
function assert(c,m){if(!c)throw new Error(m)}
const r=new Repo()
const a=r.create({title:'午餐',occurredAt:'2026-04-29',amount:20})
assert(!!a.id,'create')
assert(r.findById(a.id).title==='午餐','find')
a.title='晚餐'; r.update(a); assert(r.findById(a.id).title==='晚餐','update')
assert(r.listByMonth(2026,4).length===1,'listByMonth')
assert(r.listRecent(1)[0].id===a.id,'listRecent')
assert(r.delete(a.id)===true,'delete')
assert(r.findById(a.id)===null,'deleted')
console.log('bill_repository_crud_test passed')
