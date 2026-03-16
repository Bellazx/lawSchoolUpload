<template>
  <component :is="linkProps(to).is" v-bind="linkProps(to).props">
    <slot />
  </component>
</template>

<script>
import { isExternal } from '@/utils/validate'

export default {
  props: {
    to: {
      type: String,
      required: true
    }
  },
  methods: {
    linkProps(url) {
      if (isExternal(url)) {
        return {
          is: 'a',
          props: {
            href: url,
            target: '_blank',
            rel: 'noopener'
          }
        }
      }
      return {
        is: 'router-link',
        props: {
          to: url
        }
      }
    }
  }
}
</script>
