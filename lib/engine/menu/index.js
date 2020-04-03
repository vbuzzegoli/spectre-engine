const template = require('./template')
const { Menu } = require('electron')

module.exports = {
  initialize (w, ghostMode = false) {
    if (ghostMode && w) {
      if (w.removeMenu) {
        w.removeMenu()
      } else if (w.setMenu) {
        w.setMenu(null)
      }
    } else {
      const menu = Menu.buildFromTemplate(template)
      Menu.setApplicationMenu(menu)
    }
  }
}