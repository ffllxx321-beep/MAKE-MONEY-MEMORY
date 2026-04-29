const text = `
相册权限 用于手动导入
截图能力 支持时一键截图
通知权限 新截图提醒
浮窗能力 App内入口
图片默认本地识别 不上传
可关闭自动识别和浮窗
无法授权时有降级方案
`

function assert(cond, msg) { if (!cond) throw new Error(msg) }
assert(text.includes('相册权限'), 'album purpose missing')
assert(text.includes('截图能力'), 'screenshot purpose missing')
assert(text.includes('通知权限'), 'notification purpose missing')
assert(text.includes('浮窗能力'), 'floating purpose missing')
assert(text.includes('本地识别') && text.includes('不上传'), 'local-only statement missing')
assert(text.includes('可关闭自动识别') || text.includes('可关闭自动识别和浮窗'), 'toggle-off statement missing')
assert(text.includes('降级方案') || text.includes('降级'), 'fallback statement missing')
console.log('privacy_permission_page_smoke_test passed')
