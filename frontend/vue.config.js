const path = require('path')

module.exports = {
  publicPath: process.env.NODE_ENV === 'production' ? '/lawSchUpl/' : '/',
  outputDir: 'dist',
  assetsDir: 'static',
  lintOnSave: false,
  productionSourceMap: false,
  devServer: {
    port: 8080,
    proxy: {
      '/lawSchUpl/api': {
        target: 'http://localhost:5000',
        changeOrigin: true
      }
    }
  },
  chainWebpack: config => {
    config.resolve.alias
      .set('@', path.resolve(__dirname, 'src'))
  }
}
