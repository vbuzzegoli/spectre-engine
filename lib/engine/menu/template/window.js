const platform = require('../../../utils/platform')

module.exports = {
  label: 'Window',
  submenu: [
    { role: 'minimize' },
    { role: 'zoom' },
    ...(platform.isMac() ? [
      { type: 'separator' },
      { role: 'front' },
      { type: 'separator' },
      { role: 'window' }
    ] : [
      { role: 'close' }
    ])
  ]
}