const clipboardy = require('clipboardy')

module.exports = {
  copy (str) {
    if (!typeof str === 'string') { return }
    return clipboardy.writeSync(str)
  },
  paste () {
    return clipboardy.readSync()
  }
}