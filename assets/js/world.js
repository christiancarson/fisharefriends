{
const cv = document.querySelector('canvas.world')
if (cv) (async () => {
  const text = async u => window.lockFile ? window.lockFile(u.replace(/^\//, '')) : await (await fetch(u)).text()
  const [map, pool, linked] = await Promise.all([cv.dataset.world, cv.dataset.waters, cv.dataset.links].map(async u => JSON.parse(await text(u))))
  const links = linked.waters, names = linked.names, ctx = cv.getContext('2d'), D = Math.PI / 180, wrap = cv.parentNode
  const globe = lines => {
    const n = lines.reduce((t, l) => t + l.length / 2, 0), xyz = new Float32Array(n * 3), starts = new Int32Array(lines.length), ll = new Float32Array(n * 2)
    let i = 0
    lines.forEach((l, j) => { starts[j] = i; let lon = 0, lat = 0; for (let k = 0; k < l.length; k += 2) { lon += l[k]; lat += l[k + 1]; const a = lon / 1e4 * D, b = lat / 1e4 * D, c = Math.cos(b); xyz[i * 3] = c * Math.cos(a); xyz[i * 3 + 1] = c * Math.sin(a); xyz[i * 3 + 2] = Math.sin(b); ll[i * 2] = lon / 1e4; ll[i * 2 + 1] = lat / 1e4; i++ } })
    return { xyz, starts, ll, n }
  }
  const land = ['world', 'landx', 'region', 'local'].map(k => globe(map[k]))
  const waters = Object.keys(pool).sort().map(slug => {
    const w = pool[slug], g = globe(w.lines), box = [Infinity, Infinity, -Infinity, -Infinity]
    for (let i = 0; i < g.n; i++) { box[0] = Math.min(box[0], g.ll[i * 2]); box[1] = Math.min(box[1], g.ll[i * 2 + 1]); box[2] = Math.max(box[2], g.ll[i * 2]); box[3] = Math.max(box[3], g.ll[i * 2 + 1]) }
    return { slug, title: w.title, lands: w.lands, href: w.href, g, box, path: null }
  })
  const find = h => { const own = waters.filter(w => w.href === h), ks = links[h] || []; return own.length ? own : waters.filter(w => ks.includes(w.slug)) }
  const blue = getComputedStyle(cv).color, shore = `hsl(${cv.style.getPropertyValue('--hue') || 215} 40% 72%)`
  const mid = waters.map(w => [(w.box[0] + w.box[2]) / 2, (w.box[1] + w.box[3]) / 2]), ml = mid.reduce((t, p) => t + p[0], 0) / (mid.length || 1), mb = mid.reduce((t, p) => t + p[1], 0) / (mid.length || 1)
  let lon0 = ml, lat0 = mb, z = 1, hot = [], hue = -1, due = false, tint = blue
  const dpr = () => devicePixelRatio || 1
  const size = () => { cv.width = Math.round(cv.clientWidth * dpr()); cv.height = Math.round(cv.clientHeight * dpr()) }
  const radius = () => Math.min(cv.width, cv.height) * .48 * z
  const trace = g => {
    const p = new Path2D(), r = radius(), ox = cv.width / 2, oy = cv.height / 2, a = lon0 * D, b = lat0 * D, sa = Math.sin(a), ca = Math.cos(a), sb = Math.sin(b), cb = Math.cos(b)
    let pen = false, next = 0, line = 0
    for (let i = 0; i < g.n; i++) {
      if (i === next) { pen = false; line++; next = line < g.starts.length ? g.starts[line] : Infinity }
      const x = g.xyz[i * 3], y = g.xyz[i * 3 + 1], w = g.xyz[i * 3 + 2]
      if (x * cb * ca + y * cb * sa + w * sb <= 0) { pen = false; continue }
      const X = ox + r * (-x * sa + y * ca), Y = oy - r * (-x * sb * ca - y * sb * sa + w * cb)
      pen ? p.lineTo(X, Y) : p.moveTo(X, Y); pen = true
    }
    return p
  }
  const where = w => {
    const r = radius(), a = lon0 * D, b = lat0 * D, A = (w.box[0] + w.box[2]) / 2 * D, B = (w.box[1] + w.box[3]) / 2 * D, x = Math.cos(B) * Math.cos(A), y = Math.cos(B) * Math.sin(A), v = Math.sin(B)
    return [cv.width / 2 + r * (-x * Math.sin(a) + y * Math.cos(a)), cv.height / 2 - r * (-x * Math.sin(b) * Math.cos(a) - y * Math.sin(b) * Math.sin(a) + v * Math.cos(b)), x * Math.cos(b) * Math.cos(a) + y * Math.cos(b) * Math.sin(a) + v * Math.sin(b) > 0]
  }
  const frame = ws => { const b = [Math.min(...ws.map(w => w.box[0])), Math.min(...ws.map(w => w.box[1])), Math.max(...ws.map(w => w.box[2])), Math.max(...ws.map(w => w.box[3]))], lat = (b[1] + b[3]) / 2; const km = Math.max(60, (b[2] - b[0]) * 111 * Math.cos(lat * D), (b[3] - b[1]) * 111 * cv.height / cv.width) * 2; return [(b[0] + b[2]) / 2, lat, Math.min(300, Math.max(1, cv.width * 6371 / km / (Math.min(cv.width, cv.height) * .48)))] }
  const ease = t => t < .5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2
  let extra = () => {}
  const paint = () => {
    due = false
    const r = radius()
    ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.clearRect(0, 0, cv.width, cv.height)
    ctx.lineCap = ctx.lineJoin = 'round'; ctx.strokeStyle = hue < 0 ? shore : `hsl(${hue} 75% 45%)`; ctx.lineWidth = 2 * dpr()
    ctx.beginPath(); ctx.arc(cv.width / 2, cv.height / 2, r, 0, 2 * Math.PI); ctx.stroke()
    if (z < 24) ctx.stroke(trace(land[0]))
    else { ctx.stroke(trace(land[1])); ctx.lineWidth = 1.4 * dpr(); ctx.stroke(trace(land[2])); ctx.stroke(trace(land[3])) }
    for (const w of waters) { w.path = trace(w.g); const on = hot.includes(w); ctx.strokeStyle = hue >= 0 ? `hsl(${(hue + 150) % 360} 75% 45%)` : on ? tint : blue; ctx.lineWidth = (on ? 5.5 : 3) * dpr(); ctx.stroke(w.path) }
    cv.dataset.view = `${lon0.toFixed(4)} ${lat0.toFixed(4)} ${z.toFixed(4)}`
    extra()
  }
  const draw = () => { if (!due) { due = true; requestAnimationFrame(paint) } }
  const tip = wrap.querySelector('.tip'), side = document.querySelector('.side'), garden = side && side.querySelector('.garden')
  const thread = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
  thread.setAttribute('class', 'thread'); document.body.appendChild(thread)
  let tie = null, cast = 0, dragged = false, touch = false, spin = [0, 0], glide = 0, fly = 0, soon = 0, away = 0, twirl = 0, sailing = false
  const string = () => {
    thread.replaceChildren()
    if (!hot.length || !tie) return
    const a = tie.getBoundingClientRect(), k = cv.getBoundingClientRect(), t = Math.min(1, (performance.now() - cast) / 500)
    if (!a.width) return
    for (const w of hot) {
      const [x, y, seen] = where(w)
      if (!seen) continue
      const x1 = a.left + a.width / 2, y1 = a.top + a.height / 2, x2 = k.left + x / dpr(), y2 = k.top + y / dpr(), p = document.createElementNS('http://www.w3.org/2000/svg', 'path')
      p.setAttribute('d', `M ${x1} ${y1} C ${x1 - 160} ${y1 + 80}, ${x2 + 160} ${y2 + 80}, ${x2} ${y2}`); p.setAttribute('stroke', tint); thread.appendChild(p)
      const L = p.getTotalLength(); p.setAttribute('stroke-dasharray', L); p.setAttribute('stroke-dashoffset', L * (1 - t))
    }
    if (t < 1) requestAnimationFrame(string)
  }
  extra = string
  const turnBy = (dx, dy) => { const r = radius(); lat0 = Math.min(89, Math.max(-89, lat0 + dy / r / D)); lon0 = ((lon0 - dx / (r * Math.max(.2, Math.cos(lat0 * D))) / D + 540) % 360) - 180; draw() }
  const at = (X, Y) => { const k = cv.getBoundingClientRect(), r = radius(), x = ((X - k.left) * dpr() - cv.width / 2) / r, y = (cv.height / 2 - (Y - k.top) * dpr()) / r, q = Math.hypot(x, y); if (q > 1) return null; const c = Math.asin(q), sc = Math.sin(c), cc = Math.cos(c), b = lat0 * D; return [lon0 + Math.atan2(x * sc, q * cc * Math.cos(b) - y * sc * Math.sin(b)) / D, Math.asin(cc * Math.sin(b) + (q ? y * sc * Math.cos(b) / q : 0)) / D] }
  const aim = (lon, lat, x2, y2) => {
    const A = lon * D, B = lat * D, q = x2 / Math.cos(B)
    if (Math.abs(q) > 1) return
    const d = Math.asin(q), z2 = Math.sqrt(Math.max(0, 1 - x2 * x2 - y2 * y2))
    lon0 = (A - d) / D; lat0 = Math.min(89, Math.max(-89, (Math.atan2(z2, y2) - Math.atan2(Math.cos(B) * Math.cos(d), Math.sin(B))) / D))
  }
  const zoom = (X, Y, f) => {
    const p = at(X, Y), k = cv.getBoundingClientRect()
    z = Math.min(300, Math.max(1, z * f))
    const r = radius(), x2 = ((X - k.left) * dpr() - cv.width / 2) / r, y2 = (cv.height / 2 - (Y - k.top) * dpr()) / r
    if (p && Math.hypot(x2, y2) < 1) aim(p[0], p[1], x2, y2)
    draw()
  }
  const still = () => { cancelAnimationFrame(fly); cancelAnimationFrame(glide); cancelAnimationFrame(twirl); clearTimeout(away); sailing = false; if (hue >= 0) { hue = -1; cv.classList.remove('rainbow') } }
  const rows = ws => ws.map(w => side && side.querySelector(`li[data-sub] > a[href="${w.href}"]`)).filter(Boolean).map(a => a.parentNode)
  const petal = li => { const tab = li && li.closest('li[data-tab]'); return tab && garden && garden.querySelector(`.petal[data-tab="${tab.dataset.tab}"]`) }
  const mark = (ws, on) => rows(ws).forEach(li => { const tab = li.closest('li[data-tab]'), p = petal(li); [li, li.leaf, p].forEach(x => x && !(x.classList.contains('on') || (x === p && tab.classList.contains('on'))) && x.classList.toggle('lit', on)) })
  const light = (ws, title, note, from) => {
    mark(hot, false); hot = ws; if (from) mark(hot, true)
    tie = from ? (from.leaf && from.offsetParent !== null ? from.leaf : petal(from)) : null; cast = performance.now()
    tint = from ? getComputedStyle(from.querySelector('a') || from).color : blue
    cv.classList.toggle('over', hot.length > 0); tip.hidden = !hot.length
    if (hot.length) { tip.firstChild.textContent = title; tip.lastChild.textContent = note; tip.style.color = tint }
    draw()
  }
  const place = () => { if (!hot.length) return; const [x, y] = where(hot[0]); tip.style.left = (x / dpr() + 14) + 'px'; tip.style.top = (y / dpr() - 10) + 'px' }
  const sail = (lon, lat, zt, ms, turns, done) => {
    still()
    const a0 = lon0, b0 = lat0, z0 = Math.log(z), dl = ((lon - a0 + 540) % 360) - 180, t0 = performance.now()
    sailing = true
    const step = now => {
      const t = Math.min(1, (now - t0) / (ms || 900)), e = ease(t)
      lon0 = a0 + dl * e + (turns || 0) * 360 * (1 - Math.pow(1 - t, 3)); lat0 = b0 + (lat - b0) * e; z = Math.exp(z0 + (Math.log(zt) - z0) * e)
      if (turns) hue = (now / 4) % 360
      draw(); place()
      if (t < 1) fly = requestAnimationFrame(step); else { sailing = false; lon0 = ((lon0 + 540) % 360) - 180; if (turns) { hue = -1; cv.classList.remove('rainbow') } done && done() }
    }
    fly = requestAnimationFrame(step)
  }
  const name = ws => ws.length === 1 ? ws[0].title : ws.map(w => w.title).join(', ')
  const who = h => { const n = names[h] || []; return n.length > 9 ? n.slice(0, 9).join(', ') + ' …' : n.join(', ') }
  const visit = (ws, title, from, note) => { sail(...frame(ws)); light(ws, ws.length === 1 && !note ? ws[0].title : title, note || (ws.length === 1 ? ws[0].lands : name(ws)), from) }
  const show = (ws, li, title, h) => { clearTimeout(away); clearTimeout(soon); soon = setTimeout(() => visit(ws, title, li, waters.some(w => w.href === h) ? '' : who(h)), 120) }
  const own = () => find(decodeURIComponent(location.pathname))
  const rest = () => { const ws = own(); return ws.length ? frame(ws) : [ml, mb, 1] }
  const same = (a, b) => a.length === b.length && a.every((w, i) => w === b[i])
  const settle = () => { const ws = own(); if (ws.length) { light(ws, ws.length === 1 ? ws[0].title : document.title.split(' | ')[0], ws.length === 1 ? ws[0].lands : ''); place() } else light([]) }
  const hide = () => { clearTimeout(soon); settle(); away = setTimeout(() => sail(...rest()), 600) }
  const down = new Map()
  let last = null, start = null, vel = [0, 0], t = 0
  const move = e => {
    if (!down.has(e.pointerId)) return
    down.set(e.pointerId, [e.clientX, e.clientY])
    const now = [...down.values()]
    if (now.length === 1) { const dx = (now[0][0] - last[0][0]) * dpr(), dy = (now[0][1] - last[0][1]) * dpr(), dt = Math.max(1, e.timeStamp - t); vel = [dx / dt, dy / dt]; t = e.timeStamp; turnBy(dx, dy) }
    else if (now.length === 2 && last.length === 2) {
      const d0 = Math.hypot(last[0][0] - last[1][0], last[0][1] - last[1][1]), d1 = Math.hypot(now[0][0] - now[1][0], now[0][1] - now[1][1])
      const mx = (now[0][0] + now[1][0]) / 2, my = (now[0][1] + now[1][1]) / 2, ox = (last[0][0] + last[1][0]) / 2, oy = (last[0][1] + last[1][1]) / 2
      turnBy((mx - ox) * dpr(), (my - oy) * dpr()); zoom(mx, my, d0 ? d1 / d0 : 1)
    }
    last = now
    if (Math.hypot(e.clientX - start[0], e.clientY - start[1]) > 4) dragged = true
  }
  const coast = now => { if (!down.size && Math.hypot(...spin) > .01 && now - t < 3000) { turnBy(spin[0] * 16, spin[1] * 16); spin = [spin[0] * .94, spin[1] * .94]; glide = requestAnimationFrame(coast) } }
  const up = e => { down.delete(e.pointerId); last = [...down.values()]; if (!down.size) { cv.classList.remove('held'); removeEventListener('pointermove', move); removeEventListener('pointerup', up); removeEventListener('pointercancel', up); if (e.timeStamp - t < 80) { spin = vel; t = e.timeStamp; glide = requestAnimationFrame(coast) }; setTimeout(() => { dragged = false }) } }
  cv.addEventListener('pointerdown', e => { if (e.button) return; still(); touch = e.pointerType === 'touch'; spin = [0, 0]; vel = [0, 0]; t = e.timeStamp; if (e.pointerType === 'mouse') down.clear(); if (!down.size) { addEventListener('pointermove', move); addEventListener('pointerup', up); addEventListener('pointercancel', up) }; down.set(e.pointerId, [e.clientX, e.clientY]); last = [...down.values()]; start = [e.clientX, e.clientY]; dragged = false; cv.classList.add('held') })
  cv.addEventListener('wheel', e => { e.preventDefault(); still(); zoom(e.clientX, e.clientY, Math.exp(-e.deltaY * (e.deltaMode ? .05 : e.ctrlKey ? .01 : .003))) }, { passive: false })
  let pinch = 1
  cv.addEventListener('gesturestart', e => { e.preventDefault(); pinch = 1 })
  cv.addEventListener('gesturechange', e => { e.preventDefault(); zoom(e.clientX, e.clientY, e.scale / pinch); pinch = e.scale })
  cv.addEventListener('dblclick', e => { e.preventDefault(); still(); zoom(e.clientX, e.clientY, 2.5) })
  const hit = (X, Y) => {
    const k = cv.getBoundingClientRect(), x = (X - k.left) * dpr(), y = (Y - k.top) * dpr()
    ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.lineWidth = 18 * dpr()
    for (let i = waters.length - 1; i >= 0; i--) if (waters[i].path && ctx.isPointInStroke(waters[i].path, x, y)) return waters[i]
    return null
  }
  cv.addEventListener('pointermove', e => {
    if (e.pointerType === 'touch') return
    const r = wrap.getBoundingClientRect()
    tip.style.left = (e.clientX - r.left + 14) + 'px'; tip.style.top = (e.clientY - r.top - 10) + 'px'
    const w = down.size ? null : hit(e.clientX, e.clientY)
    if (w) { if (!same(hot, [w])) light([w], w.title, w.lands) } else if (!same(hot, own())) settle()
  })
  cv.addEventListener('pointerenter', () => clearTimeout(away))
  cv.addEventListener('pointerleave', e => { if (e.pointerType !== 'touch' && !same(hot, own())) settle() })
  if (side) side.addEventListener('mouseover', e => { const a = e.target.closest('.side li > a[href]'), h = a && decodeURIComponent(a.getAttribute('href')), ws = a ? find(h) : []; if (ws.length) show(ws, a.parentNode, a.textContent.trim(), h) })
  if (side) side.addEventListener('mouseout', e => { const a = e.target.closest('.side li > a[href]'); if (a && !(e.relatedTarget && a.contains(e.relatedTarget)) && find(decodeURIComponent(a.getAttribute('href'))).length) hide() })
  if (garden) garden.querySelectorAll('.petal').forEach(p => {
    const li = side.querySelector(`li[data-tab="${p.dataset.tab}"]`), n = li && li.dataset.name, a = li && li.querySelector('a[href]'), h = a && decodeURIComponent(a.getAttribute('href')), ws = a ? find(h) : []
    if (!ws.length) return
    p.addEventListener('mouseenter', () => show(ws, li, n, h)); p.addEventListener('mouseleave', hide)
  })
  const whirl = now => { lon0 -= 1.2; hue = (now / 4) % 360; draw(); twirl = requestAnimationFrame(whirl) }
  document.addEventListener('gofish', e => {
    const d = e.detail
    if (d.spin) { still(); clearTimeout(soon); light([]); z = 1; cv.classList.add('rainbow'); twirl = requestAnimationFrame(whirl) }
    else if (d.spin === false) { still(); spin = [1.2 * D * radius() * Math.max(.2, Math.cos(lat0 * D)) / 16, 0]; t = performance.now(); glide = requestAnimationFrame(coast) }
    if (d.go) { const ws = find(d.go).length ? find(d.go) : waters.slice(Math.floor(Math.random() * waters.length)).slice(0, 1); if (!ws.length) return; cv.classList.add('rainbow'); sail(...frame(ws), Math.max(600, d.ms - 80), 3, () => light(ws, name(ws), ws.length === 1 ? ws[0].lands : '')) }
  })
  addEventListener('scroll', string, { passive: true })
  const go = w => (window.route || window.lockGo || (u => location.href = u))(w.href)
  cv.addEventListener('click', e => {
    if (dragged) { dragged = false; return }
    const w = hit(e.clientX, e.clientY)
    if (w && touch && !hot.includes(w)) { light([w], w.title, w.lands); place() }
    else if (w) go(w)
  })
  addEventListener('keydown', e => { if (e.key === 'Escape') { settle(); sail(...rest()) } })
  new ResizeObserver(() => { size(); draw() }).observe(cv)
  const kept = sessionStorage.getItem('globe')
  const arrive = animate => {
    clearTimeout(soon); clearTimeout(away)
    const h = decodeURIComponent(location.hash.slice(1)), asked = h.startsWith('/') ? find(h) : waters.filter(w => w.slug === h), ws = own()
    if (asked.length) visit(asked, h.split('/').filter(Boolean).pop().replace(/-/g, ' '), undefined, h.startsWith('/') ? who(h) : '')
    else if (ws.length) { if (animate) sail(...frame(ws)); else { still(); [lon0, lat0, z] = frame(ws) }; settle() }
    else if (!animate && kept) { [lon0, lat0, z] = kept.split(' ').map(Number); light([]) }
    else if (!sailing) light([])
  }
  sessionStorage.removeItem('globe'); size(); arrive(false)
  document.addEventListener('page', () => arrive(true))
  addEventListener('pagehide', () => sessionStorage.setItem('globe', [lon0, lat0, z].join(' ')))
})()
}
