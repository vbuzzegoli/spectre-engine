const file = require('../../services/file')
const META = require('../../constants/meta')

const ICON = `${META.PUBLIC_PATH}${META.CONFIGURATION.ICON_PATH}`
const PREFERENCES = `${META.PUBLIC_PATH}${META.CONFIGURATION.PREFERENCES_PATH}`

module.exports = {
  get () {
    return {
      ...(file.pathExistsFromRoot(PREFERENCES) ? (file.readJSONAt(PREFERENCES) || {}) : {}),
      ...(file.pathExistsFromRoot(ICON) ? { icon: file.getPathFromRoot(ICON) } : {})
    }
  }
}