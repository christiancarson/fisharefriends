const roster = async f => {
  const names = await fetch(`${f.dataset.signup}?trip=${f.dataset.trip}`).then(r => r.json())
  f.closest('.post').querySelector('.spots').textContent = `${names.length} of ${f.dataset.spots} taken${names.length ? ': ' + names.join(', ') : ''}`
}
document.querySelectorAll('.signup[data-signup]:not([data-signup=""])').forEach(roster)
document.addEventListener('submit', async e => {
  if (!e.target.matches('.signup')) return
  e.preventDefault()
  const f = e.target
  const d = new FormData(f)
  const name = d.get('name').trim()
  const gear = d.get('gear') ? `yes, waders ${d.get('waders')}` : 'no'
  const note = f.querySelector('.note')
  if (!f.dataset.signup) {
    const subject = f.dataset.subject
    const body = `name: ${name}\ngear: ${gear}`
    note.textContent = `if no mail app opens, email ${f.dataset.to} with "${subject}" and "${body.replace('\n', ', ')}"`
    location.href = `mailto:${f.dataset.to}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`
    return
  }
  note.textContent = 'one sec'
  await fetch(f.dataset.signup, { method: 'POST', body: JSON.stringify({ trip: f.dataset.trip, name, action: 'in', gear }) })
  await roster(f)
  note.textContent = `ok ${name}, you are in`
})
