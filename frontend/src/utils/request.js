import axios from 'axios'
import { MessageBox, Message } from 'element-ui'
import store from '@/store'
import { getToken } from '@/utils/auth'

// create an axios instance
const service = axios.create({
  baseURL: process.env.VUE_APP_BASE_API || '/lawSchUpl/api', // url = base url + request url
  withCredentials: true, // send cookies when cross-domain requests
  timeout: 5000 // request timeout
})

// request interceptor
service.interceptors.request.use(
  config => {
    // do something before request is sent

    if (store.getters.token) {
      // let each request carry token
      // ['X-Token'] is a custom headers key
      // please modify it according to the actual situation
      config.headers['X-Token'] = getToken()
    }
    return config
  },
  error => {
    // do something with request error
    console.log(error) // for debug
    return Promise.reject(error)
  }
)

// response interceptor
service.interceptors.response.use(
  /**
   * If you want to get http information such as headers or status
   * Please return  response => response
  */

  /**
   * Determine the request status by custom code
   * Here is just an example
   * You can also judge the status by HTTP Status Code
   */
  response => {
    // 如果是blob响应（文件下载），直接返回
    if (response.config.responseType === 'blob') {
      return response.data
    }

    const res = response.data

    // if the custom code is not 20000, it is judged as an error.
    if (!res.success) {
      // 上传接口的错误由组件自己处理，不在这里显示通用提示
      if (!response.config.url.includes('/upload/excel')) {
        Message({
          message: res.message || 'Error',
          type: 'error',
          duration: 5 * 1000
        })
      }

      // 50008: Illegal token; 50012: Other clients logged in; 50014: Token expired;
      if (res.code === 50008 || res.code === 50012 || res.code === 50014) {
        // to re-login
        MessageBox.confirm('您已注销，可以取消以留在此页面，或重新登录', '确认注销', {
          confirmButtonText: '重新登录',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          store.dispatch('user/resetToken').then(() => {
            location.reload()
          })
        })
      }
      
      // 对于上传接口，即使 success 为 false，也返回数据而不是 reject
      // 让组件自己处理错误显示
      if (response.config.url.includes('/upload/excel')) {
        return res
      }
      
      return Promise.reject(new Error(res.message || 'Error'))
    } else {
      return res
    }
  },
  error => {
    console.log('err' + error) // for debug
    
    // 尝试从响应中获取详细错误信息
    let errorMessage = error.message
    let errorData = null
    
    if (error.response && error.response.data) {
      const responseData = error.response.data
      
      // 如果后端返回了结构化的错误信息
      if (responseData.message) {
        errorMessage = responseData.message
        errorData = responseData
      }
    }
    
    // 只在非上传接口显示通用错误提示
    // 上传接口的错误由组件自己处理
    if (!error.config.url.includes('/upload/excel')) {
      Message({
        message: errorMessage,
        type: 'error',
        duration: 5 * 1000
      })
    }
    
    // 将详细错误信息附加到 error 对象上，供组件使用
    if (errorData) {
      error.errorData = errorData
    }
    
    return Promise.reject(error)
  }
)

export default service
