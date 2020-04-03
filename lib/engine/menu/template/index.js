const appSection = require('./app')
const fileSection = require('./file')
const editSection = require('./edit')
const viewSection = require('./view')
const windowSection = require('./window')
const helpSection = require('./help')
const platform = require('../../../utils/platform')

module.exports = [
  ...(platform.isMac() ? [ appSection ] : []),
  fileSection,
  editSection,
  viewSection,
  windowSection,
  helpSection
]