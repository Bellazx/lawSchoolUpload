const state = {
  title: '法学院名单上传系统',
  fixedHeader: false,
  sidebarLogo: true,
  tagsView: true,
  showSettings: false,
  theme: '#409EFF'
}

const mutations = {
  CHANGE_SETTING: (state, { key, value }) => {
    // eslint-disable-next-line no-prototype-builtins
    if (state.hasOwnProperty(key)) {
      state[key] = value
    }
  }
}

const actions = {
  changeSetting({ commit }, data) {
    commit('CHANGE_SETTING', data)
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
