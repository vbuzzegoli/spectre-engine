const environment = require('../../utils/environment')

const devTools = {
  open (w) {
    w.webContents.openDevTools()
  },
  disable (w) {
    w.webContents.on('devtools-opened', w.webContents.closeDevTools)
  }
}

module.exports = {
  initialize (w) {
    if (environment.isDev()) {
      devTools.open(w)
    } else {
      devTools.disable(w)
    }
  }
}