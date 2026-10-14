{
const side = document.querySelector('.side'), svg = side && side.querySelector('.garden'), stem = svg && svg.querySelector('#stem')
if (stem) {
  const leaves = svg.querySelector('.leaves'), ns = 'http://www.w3.org/2000/svg', top = stem.getAttribute('d').match(/M70 ([\d.]+)/)[1]
  let len = 0
  const scale = () => Math.max(.2, parseFloat(getComputedStyle(svg).width) / 280)
  const fit = () => {
    const nav = side.querySelector('.nav'), H = Math.max(Number(top) + 60, Math.round((nav.getBoundingClientRect().bottom - side.getBoundingClientRect().top) / scale()) + 6)
    let d, y
    if (H < 400) { d = `M70 ${top} C 70 ${Number(top) + 80}, 86 ${H - 80}, 70 ${H}`; y = H }
    else { d = `M70 ${top} C 70 200, 92 320, 70 400`; y = 400 }
    while (y + 340 <= H) { d += ` C 48 ${y + 110}, 92 ${y + 220}, 70 ${y + 340}`; y += 340 }
    if (y < H) { d += ` C 56 ${y + (H - y) / 2}, 70 ${H - 4}, 70 ${H}` }
    const V = Math.min(40000, Math.max(H, Math.round(side.clientHeight / scale())))
    svg.setAttribute('viewBox', `0 0 280 ${V}`); svg.style.height = Math.round(V * scale()) + 'px'; stem.setAttribute('d', d); len = stem.getTotalLength()
  }
  fit()
  const at = y => { let lo = 0, hi = len; for (let i = 0; i < 30; i++) { const m = (lo + hi) / 2; if (stem.getPointAtLength(m).y < y) lo = m; else hi = m }; return lo }
  const pose = (g, L, k) => {
    const p = stem.getPointAtLength(L), q = stem.getPointAtLength(Math.min(len, L + 2)), side = g.side || 1
    const a = Math.atan2(q.y - p.y, q.x - p.x) * 180 / Math.PI - (side > 0 ? 0 : 180)
    g.setAttribute('transform', `translate(${p.x} ${p.y}) rotate(${a * (1 - k)}) scale(${-.5 * side} .5) translate(-77 0)`)
  }
  const ease = t => 1 - Math.pow(1 - t, 3)
  const swim = (g, L1, delay) => {
    const t0 = performance.now() + delay
    const step = now => { const t = Math.min(1, Math.max(0, (now - t0) / 1100)); pose(g, L1 * ease(t), Math.max(0, (t - .75) / .25)); if (t < 1) requestAnimationFrame(step) }
    requestAnimationFrame(step)
  }
  const row = li => li.querySelector(':scope > details > summary') || li.querySelector(':scope > a, :scope > span') || li
  const target = li => { const r = row(li).getBoundingClientRect(); return (r.top + r.height / 2 - svg.getBoundingClientRect().top) / scale() }
  const textStart = li => { const rg = document.createRange(); rg.selectNodeContents(row(li)); const r = rg.getBoundingClientRect(), b = svg.getBoundingClientRect(); return (r.left - b.left) / scale() }
  const rows = d => [...d.querySelectorAll(':scope > ul > li[data-sub]')]
  const clear = d => rows(d).forEach(li => { if (li.leaf) li.leaf.remove(); li.leaf = null })
  const grow = (d, animate) => {
    clear(d)
    const tab = d.closest('li[data-tab]'), hue = tab ? tab.style.getPropertyValue('--hue') || 120 : 120
    rows(d).forEach((li, j) => {
      if (row(li).offsetParent === null) return
      const g = document.createElementNS(ns, 'g'), u = document.createElementNS(ns, 'use')
      const col = `hsl(${hue} 60% ${li.dataset.l || 50}%)`
      g.setAttribute('class', 'leaf' + (li.classList.contains('on') ? ' lit' : '')); g.setAttribute('stroke', col); g.setAttribute('color', col)
      u.setAttribute('href', '#gfish'); g.appendChild(u); leaves.appendChild(g); li.leaf = g
      g.addEventListener('mouseenter', () => { g.classList.add('lit'); li.classList.add('lit') })
      g.addEventListener('mouseleave', () => { if (!li.classList.contains('on')) { g.classList.remove('lit'); li.classList.remove('lit') } })
      g.addEventListener('click', () => { const a = li.querySelector(':scope > a'), d = li.querySelector(':scope > details'); if (d) d.open = !d.open; else if (a) (window.lockGo || (u => location.href = u))(a.getAttribute('href')) })
      const L = at(target(li)), x = stem.getPointAtLength(L).x
      g.side = (j % 2 && x + 40 < textStart(li) - 4) ? 1 : -1
      animate ? swim(g, L, j * 140) : pose(g, L, 1)
    })
  }
  const shown = d => d.open && d.offsetParent !== null
  const regrow = skip => { fit(); side.querySelectorAll('details').forEach(d => { if (skip && (d === skip || skip.contains(d))) return; shown(d) ? grow(d, false) : clear(d) }) }
  const toggle = (d, animate) => { const kids = [...d.querySelectorAll('details')]; if (shown(d)) { grow(d, animate); kids.forEach(x => shown(x) ? grow(x, animate) : clear(x)) } else { clear(d); kids.forEach(clear) } }
  side.querySelectorAll('details').forEach(d => { if (shown(d)) grow(d, true); d.addEventListener('toggle', () => { fit(); toggle(d, true); regrow(d) }) })
  addEventListener('resize', () => regrow())
  addEventListener('load', () => regrow())
  if (document.fonts) document.fonts.ready.then(() => regrow())
  side.querySelectorAll('li[data-tab]').forEach(li => {
    const p = svg.querySelector(`.petal[data-tab="${li.dataset.tab}"]`)
    if (!p) return
    const on = () => { p.classList.add('lit'); li.classList.add('lit') }, off = () => { if (!li.classList.contains('on')) { p.classList.remove('lit'); li.classList.remove('lit') } }
    li.addEventListener('mouseenter', on); li.addEventListener('mouseleave', off)
    p.addEventListener('mouseenter', on); p.addEventListener('mouseleave', off)
    p.addEventListener('click', () => { const d = li.querySelector(':scope > details'), a = li.querySelector(':scope > a'); if (d) d.open = !d.open; else if (a) (window.lockGo || (u => location.href = u))(a.getAttribute('href')) })
  })
  side.addEventListener('mouseover', e => { const li = e.target.closest('li[data-sub]'); if (li && li.leaf && !li.contains(e.relatedTarget)) li.leaf.classList.add('lit') })
  side.addEventListener('mouseout', e => { const li = e.target.closest('li[data-sub]'); if (li && li.leaf && !li.classList.contains('on') && !li.contains(e.relatedTarget)) li.leaf.classList.remove('lit') })
  document.querySelectorAll('main .tablink').forEach(a => {
    const n = a.dataset.link, li = side.querySelector(`li[data-tab][data-name="${n}"]`)
    const p = li && svg.querySelector(`.petal[data-tab="${li.dataset.tab}"]`)
    a.addEventListener('mouseenter', () => { li && li.classList.add('lit'); p && p.classList.add('lit') })
    a.addEventListener('mouseleave', () => { if (li && !li.classList.contains('on')) { li.classList.remove('lit'); p && p.classList.remove('lit') } })
  })
  const go = document.getElementById('random')
  let whirl = 0, k = 0
  const petals = [...svg.querySelectorAll('.petal')]
  const spinFast = () => { petals.forEach(p => p.classList.remove('lit')); petals[k++ % petals.length].classList.add('lit') }
  if (go) go.addEventListener('mouseenter', () => { clearInterval(whirl); whirl = setInterval(spinFast, 45) })
  if (go) go.addEventListener('mouseleave', () => { clearInterval(whirl); petals.forEach(p => p.classList.remove('lit')); side.querySelectorAll('li.on').forEach(li => { const p = svg.querySelector(`.petal[data-tab="${li.dataset.tab}"]`); if (p) p.classList.add('lit') }) })
  if (go) go.addEventListener('click', e => {
    clearInterval(whirl)
    e.preventDefault()
    const pages = go.dataset.pages.split(' ').filter(p => p && p !== location.pathname)
    const target = pages[Math.floor(Math.random() * pages.length)] || go.href
    const steps = petals.length * 2 + Math.floor(Math.random() * petals.length)
    let i = 0, delay = 55
    const tick = () => {
      petals.forEach(p => p.classList.remove('lit')); petals[i % petals.length].classList.add('lit')
      if (++i < steps) { delay *= 1.09; setTimeout(tick, delay) } else setTimeout(() => (window.lockGo || (u => location.href = u))(target), 400)
    }
    tick()
  })
}
}
