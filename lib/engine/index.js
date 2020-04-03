const app  = require('./app')
const lifecycle  = require('./lifecycle')

module.exports = {
  start () {
    lifecycle.start(app.launch)
  }
}