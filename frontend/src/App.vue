<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style lang="scss">
#app {
  height: 100%;
}

// 全局样式重置
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  height: 100%;
  font-family: "Helvetica Neue", Helvetica, "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", "微软雅黑", Arial, sans-serif;
}

// Element UI 样式覆盖
.el-menu {
  border-right: none;
}

.el-menu-item {
  height: 50px;
  line-height: 50px;
}

.el-submenu__title {
  height: 50px;
  line-height: 50px;
}

// 侧边栏样式
.sidebar-container {
  background-color: #304156;
}

// 主内容区域样式
.main-container {
  background-color: #f0f2f5;
  min-height: 100vh;
}

// 导航栏样式
.navbar {
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0,21,41,.08);
}
</style>