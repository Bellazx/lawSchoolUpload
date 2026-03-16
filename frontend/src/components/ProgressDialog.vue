<template>
  <el-dialog
    title="Aleph账号查询进度"
    :visible.sync="visible"
    width="600px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
    :show-close="true"
    @close="handleClose"
  >
    <div class="progress-container">
      <!-- 进度信息 -->
      <div class="progress-info">
        <div class="status-icon">
          <i v-if="isProcessing" class="el-icon-loading"></i>
          <i v-else-if="isCompleted" class="el-icon-success" style="color: #67C23A;"></i>
          <i v-else class="el-icon-error" style="color: #F56C6C;"></i>
        </div>
        <div class="status-text">
          <h3>{{ statusText }}</h3>
          <p>{{ statusDescription }}</p>
        </div>
      </div>

      <!-- 进度条 -->
      <div class="progress-bar-container">
        <el-progress
          :percentage="percentage"
          :status="progressStatus"
          :stroke-width="20"
        ></el-progress>
        <div class="progress-detail">
          <span>已处理：{{ processed }} / {{ total }}</span>
          <span v-if="isProcessing">预计剩余：{{ estimatedTime }}</span>
        </div>
      </div>

      <!-- 统计信息 -->
      <div v-if="processed > 0" class="statistics">
        <el-row :gutter="20">
          <el-col :span="12">
            <div class="stat-item success">
              <div class="stat-icon">
                <i class="el-icon-success"></i>
              </div>
              <div class="stat-content">
                <div class="stat-number">{{ success }}</div>
                <div class="stat-label">成功</div>
              </div>
            </div>
          </el-col>
          <el-col :span="12">
            <div class="stat-item failed">
              <div class="stat-icon">
                <i class="el-icon-error"></i>
              </div>
              <div class="stat-content">
                <div class="stat-number">{{ failed }}</div>
                <div class="stat-label">失败</div>
              </div>
            </div>
          </el-col>
        </el-row>
      </div>

      <!-- 失败列表 -->
      <div v-if="isCompleted && failedStudents.length > 0" class="failed-list">
        <el-divider></el-divider>
        <h4>未找到Aleph账号的学生（{{ failedStudents.length }}人）：</h4>
        <el-scrollbar style="height: 200px;">
          <ul>
            <li v-for="(student, index) in failedStudents" :key="index">
              学号：{{ student.student_id }}，姓名：{{ student.name }}
            </li>
          </ul>
        </el-scrollbar>
      </div>
    </div>

    <div slot="footer" class="dialog-footer">
      <el-button v-if="isCompleted" @click="handleClose">关闭</el-button>
      <el-button v-if="isCompleted" type="primary" @click="goToStudentList">查看学生列表</el-button>
    </div>
  </el-dialog>
</template>

<script>
import request from '@/utils/request'

export default {
  name: 'ProgressDialog',
  props: {
    taskId: {
      type: String,
      default: ''
    },
    visible: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      total: 0,
      processed: 0,
      success: 0,
      failed: 0,
      status: 'processing',
      failedStudents: [],
      startTime: null,
      pollingTimer: null
    }
  },
  computed: {
    isProcessing() {
      return this.status === 'processing'
    },
    isCompleted() {
      return this.status === 'completed'
    },
    percentage() {
      if (this.total === 0) return 0
      return Math.round((this.processed / this.total) * 100)
    },
    progressStatus() {
      if (this.isCompleted) {
        return this.failed > 0 ? 'warning' : 'success'
      }
      return null
    },
    statusText() {
      if (this.isProcessing) {
        return '正在查询Aleph账号...'
      } else if (this.isCompleted) {
        return '查询完成！'
      }
      return '查询失败'
    },
    statusDescription() {
      if (this.isProcessing) {
        return '请稍候，系统正在为每位学生查询Aleph账号信息'
      } else if (this.isCompleted) {
        if (this.failed === 0) {
          return `所有学生都已成功查询到Aleph账号`
        } else {
          return `${this.success}名学生查询成功，${this.failed}名学生未找到账号`
        }
      }
      return ''
    },
    estimatedTime() {
      if (!this.startTime || this.processed === 0) {
        return '计算中...'
      }
      const elapsed = (Date.now() - this.startTime) / 1000 // 秒
      const avgTime = elapsed / this.processed
      const remaining = (this.total - this.processed) * avgTime
      
      if (remaining < 60) {
        return `${Math.round(remaining)}秒`
      } else {
        return `${Math.round(remaining / 60)}分钟`
      }
    }
  },
  watch: {
    visible(val) {
      if (val && this.taskId) {
        this.startPolling()
      } else {
        this.stopPolling()
      }
    },
    taskId(val) {
      if (val && this.visible) {
        this.startPolling()
      }
    }
  },
  methods: {
    startPolling() {
      this.fetchProgress()
      this.pollingTimer = setInterval(() => {
        this.fetchProgress()
      }, 2000) // 每2秒轮询一次
    },
    stopPolling() {
      if (this.pollingTimer) {
        clearInterval(this.pollingTimer)
        this.pollingTimer = null
      }
    },
    async fetchProgress() {
      try {
        const response = await request.get(`/task/progress/${this.taskId}`)
        if (response.success) {
          const data = response.data
          this.total = data.total
          this.processed = data.processed
          this.success = data.success
          this.failed = data.failed
          this.status = data.status
          this.failedStudents = data.failed_students || []
          
          if (!this.startTime && data.start_time) {
            this.startTime = new Date(data.start_time).getTime()
          }
          
          // 如果任务完成，停止轮询
          if (this.status === 'completed') {
            this.stopPolling()
          }
        }
      } catch (error) {
        console.error('获取进度失败:', error)
        // 如果任务不存在或发生网络错误，停止轮询
        // 检查是否是404错误或网络错误
        if (
          (error.response && error.response.status === 404) ||
          error.code === 'ERR_NETWORK' ||
          error.code === 'ECONNREFUSED' ||
          error.message === 'Network Error'
        ) {
          // 检查是否正在轮询，避免重复提示
          const wasPolling = this.pollingTimer !== null
          this.stopPolling()
          
          // 只在第一次遇到错误时显示提示
          if (wasPolling) {
            this.$message.warning('任务已完成或已过期')
          }
        }
      }
    },
    handleClose() {
      this.stopPolling()
      this.$emit('update:visible', false)
      this.$emit('close')
    },
    goToStudentList() {
      this.handleClose()
      this.$router.push('/students/index')
    }
  },
  beforeDestroy() {
    this.stopPolling()
  }
}
</script>

<style lang="scss" scoped>
.progress-container {
  padding: 20px 0;
  
  .progress-info {
    display: flex;
    align-items: center;
    margin-bottom: 30px;
    
    .status-icon {
      font-size: 48px;
      margin-right: 20px;
      
      i {
        &.el-icon-loading {
          color: #409EFF;
        }
      }
    }
    
    .status-text {
      flex: 1;
      
      h3 {
        margin: 0 0 10px 0;
        font-size: 20px;
        color: #303133;
      }
      
      p {
        margin: 0;
        font-size: 14px;
        color: #909399;
      }
    }
  }
  
  .progress-bar-container {
    margin-bottom: 30px;
    
    .progress-detail {
      display: flex;
      justify-content: space-between;
      margin-top: 10px;
      font-size: 14px;
      color: #606266;
    }
  }
  
  .statistics {
    margin-bottom: 20px;
    
    .stat-item {
      display: flex;
      align-items: center;
      padding: 15px;
      border-radius: 8px;
      
      &.success {
        background: #f0f9ff;
        border: 1px solid #67C23A;
      }
      
      &.failed {
        background: #fef0f0;
        border: 1px solid #F56C6C;
      }
      
      .stat-icon {
        font-size: 32px;
        margin-right: 15px;
        
        i {
          &.el-icon-success {
            color: #67C23A;
          }
          
          &.el-icon-error {
            color: #F56C6C;
          }
        }
      }
      
      .stat-content {
        flex: 1;
        
        .stat-number {
          font-size: 24px;
          font-weight: bold;
          color: #303133;
        }
        
        .stat-label {
          font-size: 14px;
          color: #909399;
          margin-top: 5px;
        }
      }
    }
  }
  
  .failed-list {
    h4 {
      color: #F56C6C;
      margin: 10px 0;
    }
    
    ul {
      list-style: none;
      padding: 0;
      margin: 0;
      
      li {
        padding: 8px 12px;
        margin-bottom: 5px;
        background: #fef0f0;
        border-left: 3px solid #F56C6C;
        border-radius: 4px;
        font-size: 14px;
        color: #606266;
      }
    }
  }
}
</style>

