const side = document.querySelector('.side'), svg = side && side.querySelector('.garden'), stem = svg && svg.querySelector('#stem')
if (stem) {
  const len = stem.getTotalLength(), leaves = svg.querySelector('.leaves'), ns = 'http://www.w3.org/2000/svg'
  const scale = () => svg.getBoundingClientRect().width / 280
  const at = y => { let lo = 0, hi = len; for (let i = 0; i < 30; i++) { const m = (lo + hi) / 2; if (stem.getPointAtLength(m).y < y) lo = m; else hi = m }; return lo }
  const pose = (g, L, k) => {
    const p = stem.getPointAtLength(L), q = stem.getPointAtLength(Math.min(len, L + 2))
    const a = Math.atan2(q.y - p.y, q.x - p.x) * 180 / Math.PI
    g.setAttribute('transform', `translate(${p.x} ${p.y}) rotate(${a * (1 - k)}) scale(-.55 .55) translate(-77 0)`)
  }
  const ease = t => 1 - Math.pow(1 - t, 3)
  const swim = (g, L1, delay) => {
    const t0 = performance.now() + delay
    const step = now => { const t = Math.min(1, Math.max(0, (now - t0) / 1100)); pose(g, L1 * ease(t), Math.max(0, (t - .75) / .25)); if (t < 1) requestAnimationFrame(step) }
    requestAnimationFrame(step)
  }
  const target = li => (li.getBoundingClientRect().top + li.getBoundingClientRect().height / 2 - svg.getBoundingClientRect().top) / scale()
  const clear = d => d.parentNode.querySelectorAll('li[data-sub]').forEach(li => { if (li.leaf) li.leaf.remove(); li.leaf = null })
  const grow = (d, animate) => {
    clear(d)
    const tab = d.parentNode, petal = svg.querySelector(`.petal[data-tab="${tab.dataset.tab}"]`), hue = petal ? petal.dataset.hue : 120
    tab.querySelectorAll('li[data-sub]').forEach((li, j) => {
      const g = document.createElementNS(ns, 'g'), u = document.createElementNS(ns, 'use')
      const col = `hsl(${hue} 60% ${Math.max(28, 62 - j * 11)}%)`
      g.setAttribute('class', 'leaf' + (li.classList.contains('on') ? ' lit' : '')); g.setAttribute('stroke', col); g.setAttribute('color', col)
      u.setAttribute('href', '#gfish'); g.appendChild(u); leaves.appendChild(g); li.leaf = g
      const L = at(target(li)); animate ? swim(g, L, j * 140) : pose(g, L, 1)
    })
  }
  const regrow = skip => side.querySelectorAll('details[open]').forEach(d => { if (d !== skip) grow(d, false) })
  side.querySelectorAll('details').forEach(d => { if (d.open) grow(d, true); d.addEventListener('toggle', () => { d.open ? grow(d, true) : clear(d); regrow(d) }) })
  addEventListener('resize', () => regrow())
  addEventListener('load', () => regrow())
  if (document.fonts) document.fonts.ready.then(() => regrow())
  side.querySelectorAll('li[data-tab]').forEach(li => {
    const p = svg.querySelector(`.petal[data-tab="${li.dataset.tab}"]`)
    li.addEventListener('mouseenter', () => p && p.classList.add('lit'))
    li.addEventListener('mouseleave', () => p && !li.classList.contains('on') && p.classList.remove('lit'))
  })
  side.addEventListener('mouseover', e => { const li = e.target.closest('li[data-sub]'); if (li && li.leaf && !li.contains(e.relatedTarget)) li.leaf.classList.add('lit') })
  side.addEventListener('mouseout', e => { const li = e.target.closest('li[data-sub]'); if (li && li.leaf && !li.classList.contains('on') && !li.contains(e.relatedTarget)) li.leaf.classList.remove('lit') })
}
