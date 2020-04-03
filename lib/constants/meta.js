const file = require('../services/file')

module.exports = {
  APP_NAME: 'Spectre',
  APP_SIZE: {
    HEIGHT: 1000,
    WIDTH: 1200
  },
  FULLSCREEN: false,
  GHOST_MODE: false,
  APP_ICON: file.getPathFromRoot('assets/icons/png/spectre-xlow-res.png'),
  REPOSITORY_URL: 'https://github.com/vbuzzegoli/spectre',
  PUBLIC_PATH: 'public/',
  CONFIGURATION: {
    ICON_PATH: 'icon.png',
    PREFERENCES_PATH: 'preferences.json'
  }
}