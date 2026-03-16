<template>
  <div class="menu-item-wrapper">
    <i v-if="icon" :class="icon" class="menu-icon"></i>
    <span slot="title" class="menu-title">{{ title }}</span>
  </div>
</template>

<script>
export default {
  name: 'MenuItem',
  props: {
    icon: {
      type: String,
      default: ''
    },
    title: {
      type: String,
      default: ''
    }
  }
}
</script>

<style lang="scss" scoped>
.menu-item-wrapper {
  display: flex;
  align-items: center;
  width: 100%;
  
  .menu-icon {
    margin-right: 8px;
    font-size: 18px;
    width: 24px;
    text-align: center;
    vertical-align: middle;
    flex-shrink: 0;
  }
  
  .menu-title {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
}
</style>
