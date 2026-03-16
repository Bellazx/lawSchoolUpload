<template>
  <div :class="{'has-logo':showLogo}" class="sidebar-wrapper">
    <logo v-if="showLogo" :collapse="isCollapse" />
    <el-scrollbar wrap-class="scrollbar-wrapper">
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :background-color="variables.menuBg"
        :text-color="variables.menuText"
        :unique-opened="false"
        :active-text-color="variables.menuActiveText"
        :collapse-transition="false"
        mode="vertical"
        :popper-append-to-body="true"
      >
        <sidebar-item v-for="route in routes" :key="route.path" :item="route" :base-path="route.path" />
      </el-menu>
    </el-scrollbar>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import Logo from './Logo'
import SidebarItem from './SidebarItem'
import variables from '@/styles/variables.scss'
import { constantRoutes } from '@/router'

export default {
  components: { SidebarItem, Logo },
  computed: {
    ...mapGetters([
      'sidebar'
    ]),
    routes() {
      // 直接使用导入的constantRoutes，避免访问undefined的问题
      return constantRoutes
    },
    activeMenu() {
      const route = this.$route
      const { meta, path } = route
      // if set path, the sidebar will highlight the path you set
      if (meta.activeMenu) {
        return meta.activeMenu
      }
      return path
    },
    showLogo() {
      return this.$store.state.settings.sidebarLogo
    },
    variables() {
      return variables || {}
    },
    isCollapse() {
      return !this.sidebar.opened
    }
  }
}
</script>

<style lang="scss" scoped>
.sidebar-wrapper {
  height: 100%;
  
  ::v-deep {
    .scrollbar-wrapper {
      overflow-x: hidden !important;
    }
    
    .el-scrollbar__bar.is-vertical {
      right: 0px;
    }
    
    .el-scrollbar {
      height: 100%;
    }
    
    .el-menu {
      border: none;
      height: 100%;
      width: 100% !important;
    }
    
    // 菜单项默认样式 - 确保文字清晰可见
    .el-menu-item,
    .el-submenu__title {
      color: #ffffff !important;
      
      i {
        color: #ffffff !important;
      }
      
      span {
        color: #ffffff !important;
      }
    }
    
    // 菜单项悬停效果
    .el-menu-item:hover,
    .el-submenu__title:hover {
      background-color: rgba(0, 0, 0, 0.2) !important;
      color: #ffffff !important;
    }
    
    // 激活状态样式
    .el-menu-item.is-active {
      background-color: rgba(64, 158, 255, 0.3) !important;
      color: #409EFF !important;
      
      i {
        color: #409EFF !important;
      }
      
      span {
        color: #409EFF !important;
      }
    }
    
    // 折叠状态下的菜单项
    .el-menu--collapse {
      .el-menu-item,
      .el-submenu__title {
        text-align: center;
        padding: 0 !important;
        display: flex !important;
        align-items: center;
        justify-content: center;
        
        > div {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 100%;
        }
        
        span {
          display: none;
        }
        
        i {
          margin: 0 !important;
          color: #ffffff !important;
          font-size: 20px !important;
        }
      }
      
      .el-menu-item.is-active {
        i {
          color: #409EFF !important;
        }
      }
    }
  }
}
</style>
