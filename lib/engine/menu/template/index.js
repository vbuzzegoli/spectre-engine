const appSection = require('./app')
const fileSection = require('./file')
const editSection = require('./edit')
const viewSection = require('./view')
const historySection = require('./history')
const windowSection = require('./window')
const helpSection = require('./help')
const platform = require('../../../utils/platform')

module.exports = w => [
  ...(platform.isMac() ? [ appSection ] : []),
  fileSection,
  editSection,
  viewSection,
  historySection(w), 
  windowSection,
  helpSection
]