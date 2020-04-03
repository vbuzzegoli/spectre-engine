const { BrowserWindow } = require('electron')
const path = require('path')
const store = require('../../store')
const menu = require('../menu')
const devTools = require('../devTools')
const frame = require('../frame')
const configuration = require('../configuration')

const { state, actions } = store

module.exports = {
  launch () {
    // Configure context
    actions.setConfiguration(configuration.get())

    // Create the browser window
    const {
      url,
      ghostMode,
      fullscreen,
      title,
      width,
      height,
      icon
    } = state

    const w = new BrowserWindow({
      title,
      icon,
      width,
      height,
      center: true,
      frame: !ghostMode,
      fullscreen, // must be last
      webPreferences: {
        preload: path.join(__dirname, '../../../','preload.js')
      }
    })

    // Initialize menu
    menu.initialize(w, ghostMode)

    // Initialize dev tools
    devTools.initialize(w)

    // Fix page title
    frame.preventTitleOverride(w)

    // Load URL
    w.loadURL(url)
  }
}