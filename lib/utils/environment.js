module.exports = {
  isDev () {
    return process.env.NODE_ENVIRONMENT === 'development'
  }
}