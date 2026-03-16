<template>
  <div class="login-callback-container">
    <div class="loading-content">
      <div class="loading-spinner">
        <i class="el-icon-loading"></i>
      </div>
      <div class="loading-text">正在处理登录信息，请稍候...</div>
    </div>
  </div>
</template>

<script>
import request from '@/utils/request'

export default {
  name: 'LoginCallback',
  async mounted() {
    await this.handleLoginCallback()
  },
  methods: {
    async handleLoginCallback() {
      try {
        // 获取URL中的token参数
        const token = this.$route.query.token
        console.log('收到登录回调token:', token)
        
        if (!token) {
          this.$message.error('登录token缺失，请重新登录')
          this.$router.push('/login')
          return
        }
        
        // 调用后端登录回调接口
        const response = await request.get('/login/callback', {
          params: { token: token }
        })
        
        if (response.success) {
          // 登录成功，保存用户信息
          await this.$store.dispatch('user/login', {
            user_id: response.user_id,
            user_name: response.user_name
          })
          
          this.$message.success('登录成功')
          
          // 跳转到首页或重定向页面
          const redirect = this.$route.query.redirect || '/dashboard'
          this.$router.push(redirect)
        } else {
          this.$message.error(response.message || '登录失败')
          this.$router.push('/login')
        }
      } catch (error) {
        console.error('登录回调处理失败:', error)
        this.$message.error('登录处理失败，请重新登录')
        this.$router.push('/login')
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.login-callback-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #2d3a4b;
  
  .loading-content {
    text-align: center;
    color: #fff;
    
    .loading-spinner {
      font-size: 48px;
      margin-bottom: 20px;
      
      i {
        animation: rotating 2s linear infinite;
      }
    }
    
    .loading-text {
      font-size: 16px;
      color: #eee;
    }
  }
}

@keyframes rotating {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}
</style>
