<template>
  <div class="login-container">
    <el-form ref="loginForm" :model="loginForm" :rules="loginRules" class="login-form" auto-complete="on" label-position="left">

      <div class="title-container">
        <h3 class="title">法学院名单上传系统</h3>
        <p class="subtitle">请使用统一身份认证登录</p>
      </div>

      <el-button 
        :loading="loading" 
        type="primary" 
        class="login-button"
        @click.native.prevent="handleLogin">
        统一身份认证登录
      </el-button>

      <div class="tips">
        <div class="tips-title">系统说明：</div>
        <div class="tips-content">
          <div>• 支持Excel文件上传学生名单</div>
          <div>• 自动查询学生Aleph系统ID</div>
          <div>• 提供数据查询和导出功能</div>
        </div>
      </div>

    </el-form>
  </div>
</template>

<script>
import { validUsername } from '@/utils/validate'
import { login } from '@/api/user'
import request from '@/utils/request'

export default {
  name: 'Login',
  data() {
    const validateUsername = (rule, value, callback) => {
      if (!validUsername(value)) {
        callback(new Error('请输入正确的学工号'))
      } else {
        callback()
      }
    }
    return {
      loginForm: {
        username: 'admin'
      },
      loginRules: {
        username: [{ required: true, trigger: 'blur', validator: validateUsername }]
      },
      loading: false,
      passwordType: 'password',
      redirect: undefined
    }
  },
  watch: {
    $route: {
      handler: function(route) {
        this.redirect = route.query && route.query.redirect
      },
      immediate: true
    }
  },
  async mounted() {
    // 检查URL中是否有token参数
    const token = this.$route.query.token
    if (token) {
      await this.handleTokenLogin(token)
    }
  },
  methods: {
    showPwd() {
      if (this.passwordType === 'password') {
        this.passwordType = ''
      } else {
        this.passwordType = 'password'
      }
      this.$nextTick(() => {
        this.$refs.password.focus()
      })
    },
    async handleLogin() {
      this.loading = true
      
      try {
        // 获取当前页面URL（登录页面的URL）
        const currentUrl = `${window.location.protocol}//${window.location.host}${window.location.pathname}`
        console.log('前端发送的当前URL:', currentUrl)
        
        // 调用加密接口，通过请求体传递当前URL
        const encryptResponse = await request.post('/login/encrypt', {
          current_url: currentUrl
        })
        
        if (encryptResponse.success) {
          // 跳转到统一身份认证页面
          window.location.href = encryptResponse.loginUrl
        } else {
          this.$message.error(encryptResponse.message || '登录失败')
        }
      } catch (error) {
        console.error('登录失败:', error)
        this.$message.error('登录失败，请重试')
      } finally {
        this.loading = false
      }
    },
    async handleTokenLogin(token) {
      this.loading = true
      
      try {
        // 调用登录回调接口
        const decryptResponse = await request.get('/login/callback', {
          params: { token: token }
        })
        
        if (decryptResponse.success) {
          // 登录成功，保存用户信息
          await this.$store.dispatch('user/login', {
            user_id: decryptResponse.user_id,
            user_name: decryptResponse.user_name
          })
          
          this.$message.success('登录成功')
          
          // 确保状态保存后再跳转
          await this.$nextTick()
          
          // 使用Vue Router跳转，而不是window.location
          this.$router.push({ path: this.redirect || '/dashboard' })
        } else {
          this.$message.error(decryptResponse.message || '登录失败')
        }
      } catch (error) {
        console.error('登录验证失败:', error)
        this.$message.error('登录验证失败，请重试')
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style lang="scss">
/* 修复input 背景不协调 和光标变色 */
/* Detail see https://github.com/PanJiaChen/vue-element-admin/pull/927 */

$bg:#283443;
$light_gray:#fff;
$cursor: #fff;

@supports (-webkit-mask: none) and (not (cater-color: $cursor)) {
  .login-container .el-input input {
    color: $cursor;
  }
}

/* reset element-ui css */
.login-container {
  .el-input {
    display: inline-block;
    height: 47px;
    width: 85%;

    input {
      background: transparent;
      border: 0px;
      -webkit-appearance: none;
      border-radius: 0px;
      padding: 12px 5px 12px 15px;
      color: $light_gray;
      height: 47px;
      caret-color: $cursor;

      &:-webkit-autofill {
        box-shadow: 0 0 0px 1000px $bg inset !important;
        -webkit-text-fill-color: $cursor !important;
      }
    }
  }

  .el-form-item {
    border: 1px solid rgba(255, 255, 255, 0.1);
    background: rgba(0, 0, 0, 0.1);
    border-radius: 5px;
    color: #454545;
  }
}
</style>

<style lang="scss" scoped>
$bg:#2d3a4b;
$dark_gray:#889aa4;
$light_gray:#eee;

.login-container {
  min-height: 100vh;
  width: 100%;
  background-color: $bg;
  overflow: hidden;

  .login-form {
    position: relative;
    width: 520px;
    max-width: 100%;
    padding: 0 35px;
    margin: 0 auto;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
  }

  .login-button {
    width: 100%;
    height: 50px;
    font-size: 18px;
    font-weight: 500;
    margin-bottom: 50px;
    border-radius: 8px;
    letter-spacing: 1px;
    transition: all 0.3s ease;
    
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(64, 158, 255, 0.3);
    }
  }

  .tips {
    font-size: 14px;
    color: #fff;
    margin-bottom: 10px;
    text-align: left;
    max-width: 400px;

    .tips-title {
      font-weight: bold;
      margin-bottom: 15px;
      color: #409EFF;
      font-size: 16px;
    }

    .tips-content {
      div {
        margin-bottom: 8px;
        line-height: 1.6;
        font-size: 15px;
      }
    }
  }

  .svg-container {
    padding: 6px 5px 6px 15px;
    color: $dark_gray;
    vertical-align: middle;
    width: 30px;
    display: inline-block;
  }

  .title-container {
    position: relative;
    margin-bottom: 60px;

    .title {
      font-size: 36px;
      color: $light_gray;
      margin: 0px auto 20px auto;
      text-align: center;
      font-weight: bold;
      letter-spacing: 2px;
    }
    
    .subtitle {
      font-size: 18px;
      color: $dark_gray;
      margin: 0px auto 0px auto;
      text-align: center;
      font-weight: 300;
    }
  }

  .show-pwd {
    position: absolute;
    right: 10px;
    top: 7px;
    font-size: 16px;
    color: $dark_gray;
    cursor: pointer;
    user-select: none;
  }

  .thirdparty-button {
    position: absolute;
    right: 0;
    bottom: 6px;
  }

  @media only screen and (max-width: 470px) {
    .thirdparty-button {
      display: none;
    }
  }
}
</style>
