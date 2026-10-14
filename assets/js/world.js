{
const flip = document.querySelector('.flip'), svg = flip && flip.querySelector('svg.world'), land = svg && svg.querySelector('#land')
if (land) {
  const [cx, cy, s] = land.dataset.fit.split(' ').map(Number), ns = 'http://www.w3.org/2000/svg'
  const A1 = 1.340264, A2 = -0.081106, A3 = 0.000893, A4 = 0.003796, M = Math.sqrt(3) / 2, R = 6378137
  const proj = (lon, lat) => {
    const l = lon * Math.PI / 180, t = Math.asin(M * Math.sin(lat * Math.PI / 180)), t2 = t * t, t6 = t2 * t2 * t2
    return [cx + s * R * l * Math.cos(t) / (M * (A1 + 3 * A2 * t2 + t6 * (7 * A3 + 9 * A4 * t2))), cy - s * R * t * (A1 + A2 * t2 + t6 * (A3 + A4 * t2))]
  }
  const data = JSON.parse(document.getElementById('waters').textContent)
  const waters = [...svg.querySelectorAll('a.water')].map(a => {
    const box = [Infinity, Infinity, -Infinity, -Infinity]
    const d = (data[a.dataset.slug] || []).map(line => {
      let lon = 0, lat = 0
      const pts = []
      for (let i = 0; i < line.length; i += 2) {
        lon += line[i]; lat += line[i + 1]
        const [x, y] = proj(lon / 1e4, lat / 1e4)
        box[0] = Math.min(box[0], x); box[1] = Math.min(box[1], y); box[2] = Math.max(box[2], x); box[3] = Math.max(box[3], y)
        pts.push(x.toFixed(3) + ' ' + y.toFixed(3))
      }
      return 'M' + pts.join('L')
    }).join('')
    for (const c of ['hit', 'line']) { const p = document.createElementNS(ns, 'path'); p.setAttribute('d', d); p.setAttribute('class', c); a.appendChild(p) }
    return { a, box }
  })
  const front = flip.querySelector('.front'), back = flip.querySelector('.back'), tip = flip.querySelector('.tip')
  const layers = ['land', 'landx', 'detail'].map(id => svg.querySelector('#' + id)), pool = svg.querySelector('.waters')
  let vb = [0, 0, 640, 360], cur = vb, dragged = false, idle = 0, tap = 0
  const W = () => svg.clientWidth
  const settle = () => {
    clearTimeout(idle)
    vb = cur
    const k = vb[2] / W()
    svg.style.transform = ''
    svg.setAttribute('viewBox', vb.map(v => v.toFixed(4)).join(' '))
    layers.forEach((g, i) => g.setAttribute('stroke-width', [2 * k, 2 * k, 1400 * k][i]))
    pool.style.setProperty('--k', k)
    svg.classList.toggle('near', 640 / vb[2] >= 24)
  }
  const soon = () => { clearTimeout(idle); idle = setTimeout(settle, 150) }
  const view = (x, y, w) => {
    w = Math.min(640, Math.max(640 / 500, w))
    const h = w * 360 / 640
    cur = [Math.min(640 - w / 2, Math.max(-w / 2, x - w / 2)), Math.min(360 - h / 2, Math.max(-h / 2, y - h / 2)), w, h]
    const f = W() / cur[2]
    svg.style.transform = `translate(${(vb[0] - cur[0]) * f}px, ${(vb[1] - cur[1]) * f}px) scale(${vb[2] / cur[2]})`
  }
  const at = (X, Y) => { const r = back.getBoundingClientRect(); return [cur[0] + (X - r.left) / W() * cur[2], cur[1] + (Y - r.top) / W() * cur[2]] }
  const zoom = (X, Y, f) => { const [x, y] = at(X, Y), w = Math.min(640, Math.max(640 / 500, cur[2] / f)); f = cur[2] / w; view(x - (x - cur[0]) / f + w / 2, y - (y - cur[1]) / f + w * 360 / 640 / 2, w) }
  const random = () => {
    const left = waters.map(w => w.box), groups = []
    while (left.length) {
      const g = [left.pop()]
      for (let i = 0; i < g.length; i++) for (let j = left.length - 1; j >= 0; j--) if (Math.hypot((g[i][0] + g[i][2] - left[j][0] - left[j][2]) / 2, (g[i][1] + g[i][3] - left[j][1] - left[j][3]) / 2) < 3) g.push(left.splice(j, 1)[0])
      groups.push(g)
    }
    if (!groups.length) view(320, 180, 640)
    else {
      const g = groups[Math.floor(Math.random() * groups.length)]
      const b = [Math.min(...g.map(b => b[0])), Math.min(...g.map(b => b[1])), Math.max(...g.map(b => b[2])), Math.max(...g.map(b => b[3]))]
      view((b[0] + b[2]) / 2, (b[1] + b[3]) / 2, Math.max(1.2, (b[2] - b[0]) * 1.5, (b[3] - b[1]) * 1.5 * 640 / 360))
    }
    settle()
  }
  const down = new Map()
  let last = null, start = null
  const move = e => {
    if (!down.has(e.pointerId)) return
    down.set(e.pointerId, [e.clientX, e.clientY])
    const now = [...down.values()], k = cur[2] / W()
    if (now.length === 1) view(cur[0] + cur[2] / 2 - (now[0][0] - last[0][0]) * k, cur[1] + cur[3] / 2 - (now[0][1] - last[0][1]) * k, cur[2])
    else if (now.length === 2 && last.length === 2) {
      const d0 = Math.hypot(last[0][0] - last[1][0], last[0][1] - last[1][1]), d1 = Math.hypot(now[0][0] - now[1][0], now[0][1] - now[1][1])
      const mx = (now[0][0] + now[1][0]) / 2, my = (now[0][1] + now[1][1]) / 2, ox = (last[0][0] + last[1][0]) / 2, oy = (last[0][1] + last[1][1]) / 2
      view(cur[0] + cur[2] / 2 - (mx - ox) * k, cur[1] + cur[3] / 2 - (my - oy) * k, cur[2])
      zoom(mx, my, d0 ? d1 / d0 : 1)
    }
    last = now
    if (Math.hypot(e.clientX - start[0], e.clientY - start[1]) > 4) dragged = true
  }
  const up = e => { down.delete(e.pointerId); last = [...down.values()]; if (!down.size) { svg.classList.remove('held'); removeEventListener('pointermove', move); removeEventListener('pointerup', up); removeEventListener('pointercancel', up); settle(); setTimeout(() => { dragged = false }) } }
  svg.addEventListener('pointerdown', e => { if (e.button) return; if (e.pointerType === 'mouse') down.clear(); if (!down.size) { addEventListener('pointermove', move); addEventListener('pointerup', up); addEventListener('pointercancel', up) }; down.set(e.pointerId, [e.clientX, e.clientY]); last = [...down.values()]; start = [e.clientX, e.clientY]; dragged = false; svg.classList.add('held') })
  svg.addEventListener('wheel', e => { e.preventDefault(); zoom(e.clientX, e.clientY, Math.exp(-e.deltaY * (e.deltaMode ? .05 : .0015))); soon() }, { passive: false })
  svg.addEventListener('dblclick', e => { e.preventDefault(); clearTimeout(tap); zoom(e.clientX, e.clientY, 2.5); soon() })
  svg.addEventListener('pointerover', e => { const a = e.target.closest('a.water'); if (a) { tip.firstChild.textContent = a.dataset.title; tip.lastChild.textContent = a.dataset.lands; tip.style.color = getComputedStyle(a).color; tip.hidden = false } })
  svg.addEventListener('pointerout', e => { if (e.target.closest('a.water') && !(e.relatedTarget && e.relatedTarget.closest('a.water'))) tip.hidden = true })
  back.addEventListener('pointermove', e => { const r = back.getBoundingClientRect(); tip.style.left = (e.clientX - r.left + 14) + 'px'; tip.style.top = (e.clientY - r.top - 10) + 'px' })
  const fit = () => { flip.style.height = (flip.classList.contains('flipped') ? back : front).offsetHeight + 'px' }
  const turn = on => { flip.classList.toggle('flipped', on); fit(); if (on) random() }
  fit()
  addEventListener('resize', () => { fit(); settle() }); addEventListener('load', () => { fit(); settle() })
  if (document.fonts) document.fonts.ready.then(fit)
  front.addEventListener('click', e => { if (!e.target.closest('a') && !getSelection().toString()) turn(true) })
  back.addEventListener('click', e => { if (dragged) { e.preventDefault(); e.stopPropagation(); dragged = false; return } if (!e.target.closest('a')) { clearTimeout(tap); tap = setTimeout(() => turn(false), 300) } })
  addEventListener('keydown', e => { if (e.key === 'Escape') turn(false); else if ((e.key === 'Enter' || e.key === ' ') && e.target === front) { e.preventDefault(); turn(true) } })
}
}
