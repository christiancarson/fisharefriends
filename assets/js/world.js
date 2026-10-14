{
const flip = document.querySelector('.flip'), cv = flip && flip.querySelector('canvas.world'), geo = document.getElementById('world')
if (cv && geo) {
  const map = JSON.parse(geo.textContent), ctx = cv.getContext('2d'), D = Math.PI / 180
  const globe = lines => {
    const n = lines.reduce((t, l) => t + l.length / 2, 0), xyz = new Float32Array(n * 3), starts = new Int32Array(lines.length), ll = new Float32Array(n * 2)
    let i = 0
    lines.forEach((l, j) => { starts[j] = i; let lon = 0, lat = 0; for (let k = 0; k < l.length; k += 2) { lon += l[k]; lat += l[k + 1]; const a = lon / 1e4 * D, b = lat / 1e4 * D, c = Math.cos(b); xyz[i * 3] = c * Math.cos(a); xyz[i * 3 + 1] = c * Math.sin(a); xyz[i * 3 + 2] = Math.sin(b); ll[i * 2] = lon / 1e4; ll[i * 2 + 1] = lat / 1e4; i++ } })
    return { xyz, starts, ll, n }
  }
  const land = ['world', 'landx', 'region', 'local'].map(k => globe(map[k]))
  const data = JSON.parse(document.getElementById('waters').textContent)
  const waters = [...flip.querySelectorAll('a.water')].map(a => {
    const g = globe(data[a.dataset.slug] || []), box = [Infinity, Infinity, -Infinity, -Infinity]
    for (let i = 0; i < g.n; i++) { box[0] = Math.min(box[0], g.ll[i * 2]); box[1] = Math.min(box[1], g.ll[i * 2 + 1]); box[2] = Math.max(box[2], g.ll[i * 2]); box[3] = Math.max(box[3], g.ll[i * 2 + 1]) }
    return { a, g, box, color: getComputedStyle(a).color, path: null }
  })
  const front = flip.querySelector('.front'), back = flip.querySelector('.back'), tip = flip.querySelector('.tip'), ink = getComputedStyle(document.body).color
  let lon0 = -125, lat0 = 50, z = 1, hot = [], dragged = false, tap = 0, due = false, spin = [0, 0], glide = 0, fly = 0, peek = false, soon = 0, away = 0
  const dpr = () => devicePixelRatio || 1
  const size = () => { const w = cv.clientWidth; cv.width = Math.round(w * dpr()); cv.height = Math.round(w * 9 / 16 * dpr()) }
  const radius = () => cv.height * .48 * z
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
  const paint = () => {
    due = false
    const r = radius()
    ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.clearRect(0, 0, cv.width, cv.height)
    ctx.lineCap = ctx.lineJoin = 'round'; ctx.strokeStyle = ink; ctx.lineWidth = 2 * dpr()
    ctx.beginPath(); ctx.arc(cv.width / 2, cv.height / 2, r, 0, 2 * Math.PI); ctx.stroke()
    if (z < 24) ctx.stroke(trace(land[0]))
    else { ctx.stroke(trace(land[1])); ctx.lineWidth = 1.4 * dpr(); ctx.stroke(trace(land[2])); ctx.stroke(trace(land[3])) }
    for (const w of waters) { w.path = trace(w.g); ctx.strokeStyle = w.color; ctx.lineWidth = (hot.includes(w) ? 5.5 : 3) * dpr(); ctx.stroke(w.path) }
    cv.dataset.view = `${lon0.toFixed(4)} ${lat0.toFixed(4)} ${z.toFixed(4)}`
    string()
  }
  const draw = () => { if (!due) { due = true; requestAnimationFrame(paint) } }
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
  const home = () => {
    const c = waters.map(w => [(w.box[0] + w.box[2]) / 2, (w.box[1] + w.box[3]) / 2])
    lon0 = c.reduce((t, p) => t + p[0], 0) / (c.length || 1); lat0 = c.reduce((t, p) => t + p[1], 0) / (c.length || 1); z = 1
    draw()
  }
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
  cv.addEventListener('pointerdown', e => { if (e.button) return; peek = false; cancelAnimationFrame(glide); cancelAnimationFrame(fly); spin = [0, 0]; vel = [0, 0]; t = e.timeStamp; if (e.pointerType === 'mouse') down.clear(); if (!down.size) { addEventListener('pointermove', move); addEventListener('pointerup', up); addEventListener('pointercancel', up) }; down.set(e.pointerId, [e.clientX, e.clientY]); last = [...down.values()]; start = [e.clientX, e.clientY]; dragged = false; cv.classList.add('held') })
  cv.addEventListener('wheel', e => { e.preventDefault(); peek = false; cancelAnimationFrame(fly); zoom(e.clientX, e.clientY, Math.exp(-e.deltaY * (e.deltaMode ? .05 : e.ctrlKey ? .01 : .003))) }, { passive: false })
  let pinch = 1
  cv.addEventListener('gesturestart', e => { e.preventDefault(); pinch = 1 })
  cv.addEventListener('gesturechange', e => { e.preventDefault(); zoom(e.clientX, e.clientY, e.scale / pinch); pinch = e.scale })
  cv.addEventListener('dblclick', e => { e.preventDefault(); clearTimeout(tap); zoom(e.clientX, e.clientY, 2.5) })
  const hit = (X, Y) => {
    const k = cv.getBoundingClientRect(), x = (X - k.left) * dpr(), y = (Y - k.top) * dpr()
    ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.lineWidth = 18 * dpr()
    for (let i = waters.length - 1; i >= 0; i--) if (waters[i].path && ctx.isPointInStroke(waters[i].path, x, y)) return waters[i]
    return null
  }
  const side = document.querySelector('.side'), garden = side && side.querySelector('.garden')
  const rows = ws => ws.map(w => side && side.querySelector(`li[data-sub] > a[href="${w.a.getAttribute('href')}"]`)).filter(Boolean).map(a => a.parentNode)
  const mark = (ws, on) => rows(ws).forEach(li => { const tab = li.closest('li[data-tab]'), petal = tab && garden && garden.querySelector(`.petal[data-tab="${tab.dataset.tab}"]`); [li, li.leaf, petal].forEach(x => x && !(x.classList.contains('on') || (x === petal && tab.classList.contains('on'))) && x.classList.toggle('lit', on)) })
  const thread = document.createElementNS('http://www.w3.org/2000/svg', 'svg'), petal = li => { const tab = li && li.closest('li[data-tab]'); return tab && garden && garden.querySelector(`.petal[data-tab="${tab.dataset.tab}"]`) }
  thread.setAttribute('class', 'thread'); document.body.appendChild(thread)
  let tie = null, cast = 0
  const light = (ws, title, note, from) => {
    mark(hot, false); hot = ws; mark(hot, true)
    const li = from || rows(ws)[0]; tie = li && li.leaf && li.offsetParent !== null ? li.leaf : petal(li); cast = performance.now()
    cv.classList.toggle('over', hot.length > 0); tip.hidden = !hot.length
    if (hot.length) { tip.firstChild.textContent = title; tip.lastChild.textContent = note; tip.style.color = hot[0].color }
    draw()
  }
  cv.addEventListener('pointermove', e => {
    const r = back.getBoundingClientRect()
    tip.style.left = (e.clientX - r.left + 14) + 'px'; tip.style.top = (e.clientY - r.top - 10) + 'px'
    const w = down.size ? null : hit(e.clientX, e.clientY)
    if (w !== hot[0] || hot.length !== (w ? 1 : 0)) light(w ? [w] : [], w && w.a.dataset.title, w && w.a.dataset.lands)
  })
  cv.addEventListener('pointerleave', () => { if (hot.length) light([]) })
  const where = w => {
    const r = radius(), a = lon0 * D, b = lat0 * D, A = (w.box[0] + w.box[2]) / 2 * D, B = (w.box[1] + w.box[3]) / 2 * D, x = Math.cos(B) * Math.cos(A), y = Math.cos(B) * Math.sin(A), v = Math.sin(B)
    return [cv.width / 2 + r * (-x * Math.sin(a) + y * Math.cos(a)), cv.height / 2 - r * (-x * Math.sin(b) * Math.cos(a) - y * Math.sin(b) * Math.sin(a) + v * Math.cos(b)), x * Math.cos(b) * Math.cos(a) + y * Math.cos(b) * Math.sin(a) + v * Math.sin(b) > 0]
  }
  const place = () => { if (!hot.length) return; const [x, y] = where(hot[0]); tip.style.left = (x / dpr() + 14) + 'px'; tip.style.top = (y / dpr() - 10) + 'px' }
  const string = () => {
    thread.replaceChildren()
    if (!flip.classList.contains('flipped') || !hot.length || !tie) return
    const a = tie.getBoundingClientRect(), k = cv.getBoundingClientRect(), t = Math.min(1, (performance.now() - cast) / 500)
    if (!a.width) return
    for (const w of hot) {
      const [x, y, seen] = where(w)
      if (!seen) continue
      const x1 = a.left + a.width / 2, y1 = a.top + a.height / 2, x2 = k.left + x / dpr(), y2 = k.top + y / dpr(), p = document.createElementNS('http://www.w3.org/2000/svg', 'path')
      p.setAttribute('d', `M ${x1} ${y1} C ${x1 - 160} ${y1 + 80}, ${x2 + 160} ${y2 + 80}, ${x2} ${y2}`); p.setAttribute('stroke', w.color); thread.appendChild(p)
      const L = p.getTotalLength(); p.setAttribute('stroke-dasharray', L); p.setAttribute('stroke-dashoffset', L * (1 - t))
    }
    if (t < 1) requestAnimationFrame(string)
  }
  addEventListener('scroll', string, { passive: true })
  const sail = (lon, lat, zt) => {
    cancelAnimationFrame(fly); cancelAnimationFrame(glide)
    const a0 = lon0, b0 = lat0, z0 = Math.log(z), dl = ((lon - a0 + 540) % 360) - 180, t0 = performance.now()
    const step = now => { const t = Math.min(1, (now - t0) / 900), e = t < .5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2; lon0 = a0 + dl * e; lat0 = b0 + (lat - b0) * e; z = Math.exp(z0 + (Math.log(zt) - z0) * e); draw(); if (t < 1) fly = requestAnimationFrame(step); else place() }
    fly = requestAnimationFrame(step)
  }
  const find = a => { const h = a.getAttribute('href'), n = a.textContent.trim().toLowerCase(); const own = waters.filter(w => w.a.getAttribute('href') === h); return own.length ? own : waters.filter(w => w.a.dataset.lands.toLowerCase().split(', ').includes(n)) }
  if (side) side.addEventListener('mouseover', e => {
    const a = e.target.closest('li[data-sub] > a[href^="/categories/"]'), ws = a ? find(a) : []
    if (!ws.length) return
    clearTimeout(away); clearTimeout(soon)
    soon = setTimeout(() => {
      if (!flip.classList.contains('flipped')) { peek = true; turn(true) }
      const b = [Math.min(...ws.map(w => w.box[0])), Math.min(...ws.map(w => w.box[1])), Math.max(...ws.map(w => w.box[2])), Math.max(...ws.map(w => w.box[3]))], lat = (b[1] + b[3]) / 2
      const km = Math.max(60, (b[2] - b[0]) * 111 * Math.cos(lat * D), (b[3] - b[1]) * 111 * 16 / 9) * 2
      sail((b[0] + b[2]) / 2, lat, Math.min(300, Math.max(1, cv.width * 6371 / km / (cv.height * .48))))
      light(ws, ws.length === 1 ? ws[0].a.dataset.title : a.textContent.trim(), ws.length === 1 ? ws[0].a.dataset.lands : ws.map(w => w.a.dataset.title).join(', '), a.parentNode)
    }, 120)
  })
  if (side) side.addEventListener('mouseout', e => {
    const a = e.target.closest('li[data-sub] > a[href^="/categories/"]')
    if (!a || (e.relatedTarget && a.contains(e.relatedTarget)) || !find(a).length) return
    clearTimeout(soon); light([])
    if (peek) away = setTimeout(() => { if (peek) turn(false) }, 500)
  })
  back.addEventListener('pointerenter', () => clearTimeout(away))
  const fit = () => { flip.style.height = (flip.classList.contains('flipped') ? back : front).offsetHeight + 'px' }
  const turn = on => { flip.classList.toggle('flipped', on); fit(); if (on) { size(); home() } else { peek = false; cancelAnimationFrame(glide); cancelAnimationFrame(fly); light([]) } }
  fit()
  addEventListener('resize', () => { fit(); size(); draw() }); addEventListener('load', fit)
  if (document.fonts) document.fonts.ready.then(fit)
  front.addEventListener('click', e => { if (!e.target.closest('a') && !getSelection().toString()) turn(true) })
  cv.addEventListener('click', e => {
    if (dragged) { dragged = false; return }
    const w = hit(e.clientX, e.clientY)
    if (w) (window.lockGo || (u => location.href = u))(w.a.getAttribute('href'))
    else { clearTimeout(tap); tap = setTimeout(() => turn(false), 300) }
  })
  addEventListener('keydown', e => { if (e.key === 'Escape') turn(false); else if ((e.key === 'Enter' || e.key === ' ') && e.target === front) { e.preventDefault(); turn(true) } })
}
}
