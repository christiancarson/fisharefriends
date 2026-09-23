const sheet = () => SpreadsheetApp.getActiveSpreadsheet().getSheetByName('signups') || SpreadsheetApp.getActiveSpreadsheet().insertSheet('signups')
const names = trip => {
  const state = {}
  sheet().getDataRange().getValues().filter(r => r[1] === trip).forEach(r => { state[r[2]] = r[3] })
  return Object.keys(state).filter(n => state[n] === 'in')
}
function doGet(e) {
  return ContentService.createTextOutput(JSON.stringify(names(e.parameter.trip))).setMimeType(ContentService.MimeType.JSON)
}
function doPost(e) {
  const d = JSON.parse(e.postData.contents)
  sheet().appendRow([new Date(), d.trip, d.name.trim(), d.action, d.gear])
  MailApp.sendEmail('critty@fisharefriends.org', `fish are friends: ${d.name} is ${d.action} for ${d.trip}`, `gear: ${d.gear}\nnow in: ${names(d.trip).join(', ') || 'nobody'}`)
  return ContentService.createTextOutput('ok')
}
