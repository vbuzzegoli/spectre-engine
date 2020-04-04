const clipboard = require('../../../services/clipboard')

module.exports = w => ({
  label: 'History',
  submenu: [
    {
      label: 'Go Back',
      accelerator: 'Cmd+Shift+B',
      async click () {
        await w.webContents.goBack()
      }
    },
    {
      label: 'Go Forward',
      accelerator: 'Cmd+Shift+F',
      async click () {
        await w.webContents.goForward()
      }
    },
    {
      label: 'Copy Current URL',
      async click () {
        const url = w.webContents.getURL()
        await clipboard.copy(url)
      }
    },
    {
      label: 'Clear History',
      async click () {
        await w.webContents.clearHistory()
      }
    }
  ]
})