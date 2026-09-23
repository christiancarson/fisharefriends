document.addEventListener('submit', e => {
  if (!e.target.matches('.signup')) return
  e.preventDefault()
  const d = new FormData(e.target)
  const gear = d.get('gear') ? `yes, waders ${d.get('waders')}` : 'no'
  const body = `name: ${d.get('name')}\ngear: ${gear}`
  location.href = `mailto:${e.target.dataset.to}?subject=${encodeURIComponent(e.target.dataset.subject)}&body=${encodeURIComponent(body)}`
})
