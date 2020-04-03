
// Simple store solution until heeavier solution required
const META = require('../constants/meta')

const defaultState = () => ({
  url: META.REPOSITORY_URL,
  ghostMode: META.GHOST_MODE,
  fullscreen: META.FULLSCREEN,
  title: META.APP_NAME,
  width: META.APP_SIZE.WIDTH,
  height: META.APP_SIZE.HEIGHT,
  icon: META.APP_ICON
})

const state = defaultState()

const getters = {}

const actions = {
  setConfiguration (configuration) {
    mutations['SET_CONFIGURATION'](configuration)
  }
}

const mutations = {
  ['SET_CONFIGURATION'] (payload) {
    if (typeof payload !== 'object' || !payload) { return }

    // set if valid, else reset
    state.url = typeof payload.url === 'string' ? payload.url : defaultState().url
    state.ghostMode = typeof payload.ghostMode === 'boolean' ? payload.ghostMode : defaultState().ghostMode
    state.fullscreen = typeof payload.fullscreen === 'boolean' ? payload.fullscreen : defaultState().fullscreen
    state.title = typeof payload.title === 'string' ? payload.title : defaultState().title
    state.width = typeof payload.width === 'number' ? payload.width : defaultState().width
    state.height = typeof payload.height === 'number' ? payload.height : defaultState().height
    state.icon = typeof payload.icon === 'string' ? payload.icon : defaultState().icon
  }
}

module.exports = {
  state, 
  getters,
  actions,
  mutations
}