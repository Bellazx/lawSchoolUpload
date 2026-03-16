<template>
  <div ref="scrollContainer" class="scroll-container" @wheel.prevent="handleScroll">
    <div ref="scrollWrapper" class="scroll-wrapper" :style="{left: left + 'px'}">
      <slot/>
    </div>
  </div>
</template>

<script>
const padding = 15 // tag's padding

export default {
  name: 'ScrollPane',
  data() {
    return {
      left: 0
    }
  },
  computed: {
    scrollWrapper() {
      return this.$refs.scrollWrapper
    },
    scrollContainer() {
      return this.$refs.scrollContainer
    }
  },
  mounted() {
    this.updateScrollWrapper()
  },
  methods: {
    handleScroll(e) {
      const eventDelta = e.wheelDelta || -e.deltaY * 40
      const $scrollWrapper = this.scrollWrapper
      $scrollWrapper.scrollLeft = $scrollWrapper.scrollLeft + eventDelta / 4
    },
    moveToTarget(currentTag) {
      const $container = this.scrollContainer
      const $containerWidth = $container.offsetWidth
      const $scrollWrapper = this.scrollWrapper
      const tagList = this.$parent.$refs.tag

      let firstTag = null
      let lastTag = null

      // find first tag and last tag
      if (tagList.length > 0) {
        firstTag = tagList[0]
        lastTag = tagList[tagList.length - 1]
      }

      if (firstTag === currentTag) {
        $scrollWrapper.scrollLeft = 0
      } else if (lastTag === currentTag) {
        $scrollWrapper.scrollLeft = $scrollWrapper.scrollWidth - $containerWidth
      } else {
        // find preTag and nextTag
        const currentIndex = tagList.findIndex(item => item === currentTag)
        const prevTag = tagList[currentIndex - 1]
        const nextTag = tagList[currentIndex + 1]

        // the tag's offsetLeft after of nextTag
        const afterNextTagOffsetLeft = nextTag.$el.offsetLeft + nextTag.$el.offsetWidth + padding

        // the tag's offsetLeft before of prevTag
        const beforePrevTagOffsetLeft = prevTag.$el.offsetLeft - padding

        if (afterNextTagOffsetLeft > -this.left + $containerWidth) {
          $scrollWrapper.scrollLeft = afterNextTagOffsetLeft - $containerWidth
        } else if (beforePrevTagOffsetLeft < -this.left) {
          $scrollWrapper.scrollLeft = beforePrevTagOffsetLeft
        }
      }
    },
    updateScrollWrapper() {
      const $scrollWrapper = this.scrollWrapper
      const $scrollContainer = this.scrollContainer
      const $containerWidth = $scrollContainer.offsetWidth
      const $scrollWrapperWidth = $scrollWrapper.offsetWidth

      if ($scrollWrapperWidth < $containerWidth) {
        this.left = 0
      } else {
        this.left = $containerWidth - $scrollWrapperWidth
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.scroll-container {
  white-space: nowrap;
  position: relative;
  overflow: hidden;
  width: 100%;
  .scroll-wrapper {
    position: absolute;
    transition: left .3s ease-in-out;
  }
}
</style>
