const sheet = () => SpreadsheetApp.getActiveSpreadsheet().getSheetByName('signups') || SpreadsheetApp.getActiveSpreadsheet().insertSheet('signups')
const names = trip => {
  const state = {}
  sheet().getDataRange().getValues().filter(r => r[1] === trip).forEach(r => { state[r[2]] = r[3] })
  return Object.keys(state).filter(n => state[n] === 'in')
}
function doGet(e) {
  return ContentService.createTextOutput(JSON.stringify(names(e.parameter.trip))).setMimeType(ContentService.MimeType.JSON)
}
const spots = { raft: 3, wade: 4 }
function doPost(e) {
  const d = JSON.parse(e.postData.contents)
  const name = String(d.name || '').trim().slice(0, 60), trip = String(d.trip || '').slice(0, 80)
  if (!name || !trip) return ContentService.createTextOutput('bad')
  const recent = sheet().getDataRange().getValues().filter(r => r[0] instanceof Date && Date.now() - r[0].getTime() < 60000).length
  if (recent >= 5) return ContentService.createTextOutput('slow down')
  d.name = name; d.trip = trip; d.gear = String(d.gear || '').slice(0, 40)
  if (d.action === 'in' && names(d.trip).length >= (spots[d.kind] || 4)) return ContentService.createTextOutput('full')
  sheet().appendRow([new Date(), d.trip, d.name.trim(), d.action, d.gear])
  MailApp.sendEmail('critty@fisharefriends.org', `fish are friends: ${d.name} is ${d.action} for ${d.trip}`, `gear: ${d.gear}\nnow in: ${names(d.trip).join(', ') || 'nobody'}`)
  return ContentService.createTextOutput('ok')
}
