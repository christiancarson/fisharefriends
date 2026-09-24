const roster = async f => {
  const r = await fetch(`${f.dataset.signup}?trip=${f.dataset.trip}`)
  if (!r.ok) throw new Error(r.status)
  const names = await r.json()
  f.closest('.post').querySelector('.spots').textContent = `${names.length} of ${f.dataset.spots} taken${names.length ? ': ' + names.join(', ') : ''}`
  const full = names.length >= Number(f.dataset.spots)
  f.querySelector('button').disabled = full
  if (full) f.querySelector('.note').textContent = 'this one is full, watch for the next trip'
  return names
}
document.querySelectorAll('.signup[data-signup]:not([data-signup=""])').forEach(f => roster(f).catch(() => {}))
document.addEventListener('submit', async e => {
  if (!e.target.matches('.signup')) return
  e.preventDefault()
  const f = e.target
  const d = new FormData(f)
  const name = d.get('name').trim()
  const gear = d.get('gear') ? `yes, waders ${d.get('waders')}` : 'no'
  const note = f.querySelector('.note')
  const subject = f.dataset.subject
  const body = `name: ${name}\ngear: ${gear}`
  const byMail = () => {
    note.textContent = `if no mail app opens, email ${f.dataset.to} with "${subject}" and "${body.replace('\n', ', ')}"`
    location.href = `mailto:${f.dataset.to}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`
  }
  if (!f.dataset.signup) return byMail()
  note.textContent = 'one sec'
  try {
    const r = await fetch(f.dataset.signup, { method: 'POST', body: JSON.stringify({ trip: f.dataset.trip, kind: f.dataset.kind, name, action: 'in', gear }) })
    if (!r.ok) throw new Error(r.status)
    const names = await roster(f)
    note.textContent = names.includes(name) ? `ok ${name}, you are in` : 'sorry, that one just filled up'
  } catch (err) {
    note.textContent = 'that did not go through, sending by email instead'
    byMail()
  }
})
