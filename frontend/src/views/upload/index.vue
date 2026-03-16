<template>
  <div class="app-container">
    <el-card class="box-card">
      <div slot="header" class="clearfix">
        <span>文件上传</span>
      </div>
      
      <div class="upload-section">
        <el-row :gutter="20">
          <el-col :span="12">
            <div class="upload-area">
              <el-upload
                ref="upload"
                :limit="1"
                :on-exceed="handleExceed"
                :before-upload="beforeUpload"
                :on-success="handleUploadSuccess"
                :on-error="handleUploadError"
                :on-change="handleFileChange"
                :file-list="fileList"
                :auto-upload="false"
                action="#"
                drag
              >
                <i class="el-icon-upload"></i>
                <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
                <div class="el-upload__tip" slot="tip">只能上传xlsx/xls文件，且不超过16MB</div>
              </el-upload>
              
              <div class="upload-actions">
                <el-button type="primary" @click="submitUpload" :loading="uploading">开始上传</el-button>
                <el-button @click="downloadTemplate">下载模板</el-button>
                <el-button @click="clearFiles">清空文件</el-button>
              </div>
            </div>
          </el-col>
          
          <el-col :span="12">
            <div class="upload-info">
              <h4>上传说明</h4>
              <ul>
                <li>请使用系统提供的Excel模板</li>
                <li>确保学号、姓名等必填字段完整</li>
                <li>文件大小不超过16MB</li>
                <li>支持.xlsx和.xls格式</li>
                <li>系统会自动验证数据格式</li>
                <li>上传后会自动查询学生Aleph账号信息</li>
              </ul>
              
              <h4>模板字段说明</h4>
              <div class="field-list">
                <el-tag size="small" type="danger">学号</el-tag>
                <el-tag size="small" type="danger">姓名</el-tag>
                <el-tag size="small">证件号码</el-tag>
                <el-tag size="small">手机号码</el-tag>
                <el-tag size="small">性别</el-tag>
                <el-tag size="small">民族</el-tag>
                <el-tag size="small">政治面貌</el-tag>
                <el-tag size="small">校内邮箱</el-tag>
                <el-tag size="small">个人邮箱</el-tag>
                <el-tag size="small">专业</el-tag>
                <el-tag size="small">院系</el-tag>
                <el-tag size="small">年级</el-tag>
                <el-tag size="small">入学日期</el-tag>
                <el-tag size="small">学位层次</el-tag>
                <el-tag size="small">预计毕业时间</el-tag>
                <el-tag size="small">导师姓名</el-tag>
                <el-tag size="small">班级</el-tag>
                <el-tag size="small">注册状态</el-tag>
              </div>
              <p class="field-note">红色标签为必填字段</p>
            </div>
          </el-col>
        </el-row>
      </div>
    </el-card>
    
    <!-- 上传结果弹窗 -->
    <el-dialog
      title="上传结果"
      :visible.sync="resultDialogVisible"
      width="800px"
      :close-on-click-modal="false"
      @close="handleResultDialogClose"
    >
      <div v-if="uploadResult">
        <el-alert
          :title="uploadResult.message"
          :type="uploadResult.success ? 'success' : 'error'"
          :description="uploadResult.description"
          show-icon
          :closable="false">
        </el-alert>
        
        <!-- 成功上传的统计信息 -->
        <div v-if="uploadResult.success" class="result-details">
          <el-row :gutter="20" style="margin-top: 20px;">
            <el-col :span="8">
              <div class="stat-item">
                <div class="stat-number">{{ uploadResult.successCount }}</div>
                <div class="stat-label">成功处理</div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="stat-item">
                <div class="stat-number">{{ uploadResult.failedCount }}</div>
                <div class="stat-label">处理失败</div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="stat-item">
                <div class="stat-number">{{ uploadResult.isProcessing ? '是' : '否' }}</div>
                <div class="stat-label">后台处理中</div>
              </div>
            </el-col>
          </el-row>
          
          <div v-if="uploadResult.failedStudents && uploadResult.failedStudents.length > 0" class="failed-list">
            <h4>失败记录：</h4>
            <ul>
              <li v-for="(student, index) in uploadResult.failedStudents" :key="index">{{ student }}</li>
            </ul>
          </div>
        </div>
        
        <!-- 验证错误信息 -->
        <div v-if="!uploadResult.success && uploadResult.errors && uploadResult.errors.length > 0" class="error-details">
          <el-divider></el-divider>
          
          <!-- 第一个错误高亮显示 -->
          <div v-if="uploadResult.firstError" class="first-error-highlight">
            <el-alert
              :title="'请优先修改：' + uploadResult.firstError"
              type="error"
              :closable="false"
              show-icon>
              <template slot="default">
                <p style="margin: 5px 0 0 0; font-size: 13px; color: #606266;">
                  修改此错误后，可能还有其他错误需要处理。建议逐个修改并重新上传验证。
                </p>
              </template>
            </el-alert>
          </div>
          
          <div class="error-header">
            <h4>全部错误列表</h4>
            <el-tag type="danger" size="small">共 {{ uploadResult.errorCount || uploadResult.errors.length }} 个错误</el-tag>
          </div>
          <div class="error-list-container">
            <el-scrollbar style="height: 350px;">
              <ul class="error-list">
                <li v-for="(error, index) in uploadResult.errors" :key="index" 
                    :class="['error-item', { 'first-error': index === 0 }]">
                  <i :class="index === 0 ? 'el-icon-warning-outline' : 'el-icon-warning'"></i>
                  <span>{{ error }}</span>
                  <el-tag v-if="index === 0" type="danger" size="mini" effect="dark" style="margin-left: 10px;">首个错误</el-tag>
                </li>
              </ul>
            </el-scrollbar>
          </div>
          <div class="error-tip">
            <el-alert
              title="温馨提示"
              type="info"
              :closable="false"
              show-icon>
              <template slot="default">
                <p>请根据上述错误信息修改Excel文件后重新上传</p>
                <p>• 学号：只能包含字母和数字（必填）</p>
                <p>• 姓名：必填</p>
                <p>• 证件号码：5-30位，支持身份证、护照等（选填）</p>
                <p>• 手机号：11位数字，以1开头（选填）</p>
                <p>• 邮箱：符合标准邮箱格式（选填）</p>
              </template>
            </el-alert>
          </div>
        </div>
      </div>
      
      <div slot="footer" class="dialog-footer">
        <el-button @click="resultDialogVisible = false">关闭</el-button>
        <el-button v-if="uploadResult && uploadResult.success" type="primary" @click="goToStudents">查看学生列表</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { downloadTemplate, uploadExcel } from '@/api/upload'

export default {
  name: 'Upload',
  data() {
    return {
      fileList: [],
      uploading: false,
      resultDialogVisible: false,
      uploadResult: null,
      currentTaskId: ''
    }
  },
  methods: {
    beforeUpload(file) {
      const isExcel = file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || 
                     file.type === 'application/vnd.ms-excel'
      const isLt16M = file.size / 1024 / 1024 < 16

      if (!isExcel) {
        this.$message.error('只能上传Excel文件!')
        return false
      }
      if (!isLt16M) {
        this.$message.error('文件大小不能超过16MB!')
        return false
      }
      return true
    },
    
    handleExceed(files, fileList) {
      this.$message.warning(`当前限制选择1个文件，本次选择了${files.length}个文件，共选择了${files.length + fileList.length}个文件`)
    },
    
    handleFileChange(file, fileList) {
      // 更新fileList，确保数据同步
      this.fileList = fileList
    },
    
    async submitUpload() {
      if (this.fileList.length === 0) {
        this.$message.warning('请先选择文件')
        return
      }
      
      this.uploading = true
      
      try {
        const formData = new FormData()
        formData.append('file', this.fileList[0].raw)
        
        const response = await uploadExcel(formData)
        
        this.uploadResult = {
          success: response.success,
          message: response.message,
          successCount: response.successCount || 0,
          failedCount: response.failedCount || 0,
          isProcessing: response.isProcessing || false,
          failedStudents: response.failedStudents || [],
          errors: response.errors || [],
          errorCount: response.errorCount || 0,
          firstError: response.firstError || null  // 新增：第一个错误
        }
        
        if (response.success) {
          this.uploadResult.description = `共处理${response.successCount}条记录，${response.failedCount}条失败。`
          
          // 如果有任务ID，保存起来，等上传结果弹窗关闭后再显示进度弹窗
          if (response.taskId) {
            this.currentTaskId = response.taskId
          }
        } else {
          // 验证失败时的描述
          if (response.errors && response.errors.length > 0) {
            this.uploadResult.description = '请查看下方详细错误信息并修改后重新上传'
          }
        }
        
        this.resultDialogVisible = true
        
        // 清空文件列表
        this.clearFiles()
        
      } catch (error) {
        console.error('上传失败:', error)
        
        // 尝试从错误对象中提取详细信息
        let errorResponse = null
        
        if (error.errorData) {
          // 使用 request.js 拦截器附加的错误数据
          errorResponse = error.errorData
        } else if (error.response && error.response.data) {
          // 直接从响应中获取
          errorResponse = error.response.data
        }
        
        if (errorResponse && errorResponse.message) {
          // 后端返回了结构化的错误信息
          this.uploadResult = {
            success: false,
            message: errorResponse.message,
            successCount: 0,
            failedCount: 0,
            isProcessing: false,
            failedStudents: [],
            errors: errorResponse.errors || [],
            errorCount: errorResponse.errorCount || 0,
            firstError: errorResponse.firstError || null
          }
          
          if (errorResponse.errors && errorResponse.errors.length > 0) {
            this.uploadResult.description = '请查看下方详细错误信息并修改后重新上传'
          }
          
          this.resultDialogVisible = true
        } else {
          // 未知错误，显示通用提示
          this.$message.error('上传失败：' + (error.message || '未知错误'))
        }
        
        // 清空文件列表
        this.clearFiles()
      } finally {
        this.uploading = false
      }
    },
    
    handleUploadSuccess(response, file, fileList) {
      // 这里不会被调用，因为我们设置了auto-upload为false
    },
    
    handleUploadError(error, file, fileList) {
      console.error('上传错误:', error)
      this.$message.error('上传失败')
    },
    
    async downloadTemplate() {
      try {
        const response = await downloadTemplate()
        
        // 创建下载链接
        const blob = new Blob([response], { 
          type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
        })
        const url = window.URL.createObjectURL(blob)
        const link = document.createElement('a')
        link.href = url
        link.download = '学生名单模板.xlsx'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
        window.URL.revokeObjectURL(url)
        
        this.$message.success('模板下载成功')
      } catch (error) {
        console.error('模板下载失败:', error)
        this.$message.error('模板下载失败')
      }
    },
    
    clearFiles() {
      this.fileList = []
      this.$refs.upload.clearFiles()
    },
    
    goToStudents() {
      // 如果有 taskId，传递给学生管理页面
      if (this.currentTaskId) {
        this.$router.push({
          path: '/students/index',
          query: { taskId: this.currentTaskId }
        })
      } else {
        this.$router.push('/students/index')
      }
    },
    
    handleResultDialogClose() {
      // 上传结果弹窗关闭时，如果有任务ID且上传成功，跳转到学生管理页面
      if (this.currentTaskId && this.uploadResult && this.uploadResult.success) {
        // 跳转到学生管理页面，并传递 taskId
        this.$router.push({
          path: '/students/index',
          query: { taskId: this.currentTaskId }
        })
      }
      // 清空任务ID（如果不是成功的情况）
      if (!this.uploadResult || !this.uploadResult.success) {
        this.currentTaskId = ''
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.upload-section {
  padding: 20px 0;
}

.upload-area {
  .upload-actions {
    margin-top: 20px;
    text-align: center;
    
    .el-button {
      margin: 0 10px;
    }
  }
}

.upload-info {
  h4 {
    color: #409EFF;
    margin-bottom: 15px;
  }
  
  ul {
    margin-bottom: 20px;
    padding-left: 20px;
    
    li {
      margin-bottom: 8px;
      line-height: 1.5;
    }
  }
  
  .field-list {
    margin-bottom: 10px;
    
    .el-tag {
      margin: 2px;
    }
  }
  
  .field-note {
    font-size: 12px;
    color: #999;
    margin: 0;
  }
}

.result-details {
  .stat-item {
    text-align: center;
    padding: 20px;
    background: #f5f7fa;
    border-radius: 4px;
    
    .stat-number {
      font-size: 24px;
      font-weight: bold;
      color: #409EFF;
      margin-bottom: 5px;
    }
    
    .stat-label {
      font-size: 14px;
      color: #666;
    }
  }
  
  .failed-list {
    margin-top: 20px;
    
    h4 {
      color: #F56C6C;
      margin-bottom: 10px;
    }
    
    ul {
      max-height: 200px;
      overflow-y: auto;
      background: #fef0f0;
      padding: 10px;
      border-radius: 4px;
      
      li {
        margin-bottom: 5px;
        font-size: 12px;
        color: #F56C6C;
      }
    }
  }
}

.error-details {
  margin-top: 20px;
  
  // 第一个错误高亮区域
  .first-error-highlight {
    margin-bottom: 20px;
    animation: shake 0.5s;
    
    @keyframes shake {
      0%, 100% { transform: translateX(0); }
      10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
      20%, 40%, 60%, 80% { transform: translateX(5px); }
    }
  }
  
  .error-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    
    h4 {
      color: #F56C6C;
      margin: 0;
    }
  }
  
  .error-list-container {
    background: #fef0f0;
    border-radius: 4px;
    padding: 10px;
    margin-bottom: 15px;
    
    .error-list {
      list-style: none;
      padding: 0;
      margin: 0;
      
      .error-item {
        padding: 8px 12px;
        margin-bottom: 6px;
        background: white;
        border-left: 3px solid #F56C6C;
        border-radius: 4px;
        display: flex;
        align-items: center;
        transition: all 0.3s;
        
        i {
          color: #F56C6C;
          margin-right: 10px;
          font-size: 16px;
        }
        
        span {
          flex: 1;
          color: #606266;
          line-height: 1.5;
          word-break: break-all;
        }
        
        &:hover {
          background: #f5f7fa;
          transform: translateX(3px);
        }
        
        // 第一个错误特殊样式
        &.first-error {
          background: #fff5f5;
          border-left: 4px solid #F56C6C;
          box-shadow: 0 2px 8px rgba(245, 108, 108, 0.2);
          
          i {
            font-size: 18px;
            animation: pulse 1.5s infinite;
          }
          
          span {
            font-weight: 600;
            color: #303133;
          }
          
          @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.6; }
          }
        }
      }
    }
  }
  
  .error-tip {
    p {
      margin: 5px 0;
      font-size: 13px;
    }
  }
}

.clearfix:before,
.clearfix:after {
  display: table;
  content: "";
}
.clearfix:after {
  clear: both
}
</style>
