const META = require('../../../constants/meta')
const { shell } = require('electron')

module.exports = {
  role: 'help',
  submenu: [
    {
      label: 'Learn More',
      async click () {
        await shell.openExternal(META.REPOSITORY_URL)
      }
    }
  ]
}