<template>
  <div class="app-container">
    <el-card class="box-card">
      <div slot="header" class="clearfix">
        <span>学生管理</span>
      </div>
      
      <!-- 搜索筛选 -->
      <div class="filter-container">
        <el-form :inline="true" :model="listQuery" class="demo-form-inline">
          <el-form-item label="上传人学工号">
            <el-input
              v-model="listQuery.uploader_id"
              placeholder="请输入上传人学工号"
              clearable
              style="width: 200px;"
            />
          </el-form-item>
          
          <el-form-item label="学号">
            <el-input
              v-model="listQuery.student_id"
              placeholder="请输入学号"
              clearable
              style="width: 200px;"
            />
          </el-form-item>
          
          <el-form-item label="姓名">
            <el-input
              v-model="listQuery.name"
              placeholder="请输入姓名"
              clearable
              style="width: 200px;"
            />
          </el-form-item>
          
          <el-form-item label="同步状态">
            <el-select v-model="listQuery.sync_z308_id" placeholder="请选择" clearable style="width: 150px;">
              <el-option label="未同步" value="0" />
              <el-option label="已同步" value="1" />
              <el-option label="同步失败" value="2" />
            </el-select>
          </el-form-item>
          
          <el-form-item>
            <el-button type="primary" icon="el-icon-search" @click="handleFilter">搜索</el-button>
            <el-button icon="el-icon-refresh" @click="handleReset">重置</el-button>
            <el-button type="success" icon="el-icon-download" @click="handleExport">导出Excel</el-button>
            <el-button 
              type="warning" 
              icon="el-icon-refresh"
              @click="handleTriggerUpdate" 
              :loading="triggerLoading"
              :disabled="triggerLoading"
            >
              {{ triggerLoading ? '同步中...' : '手动同步账号' }}
            </el-button>
          </el-form-item>
        </el-form>
      </div>
      
      <!-- Aleph账号查询进度条 -->
      <div v-if="showProgress" class="progress-section">
        <el-card shadow="hover">
          <div class="progress-header">
            <span class="progress-title">
              <i class="el-icon-loading" v-if="progressData.status === 'processing'"></i>
              <i class="el-icon-success" style="color: #67C23A;" v-else-if="progressData.status === 'completed'"></i>
              {{ progressData.status === 'processing' ? 'Aleph账号查询进行中...' : 'Aleph账号查询完成！' }}
            </span>
            <el-button type="text" icon="el-icon-close" @click="closeProgress" v-if="progressData.status === 'completed'">关闭</el-button>
          </div>
          <el-progress 
            :percentage="progressPercentage" 
            :status="progressData.status === 'completed' ? (progressData.failed > 0 ? 'warning' : 'success') : null"
            :stroke-width="20"
          ></el-progress>
          <div class="progress-detail">
            <span>已处理：{{ progressData.processed }} / {{ progressData.total }}</span>
            <span>成功：{{ progressData.success }}</span>
            <span>失败：{{ progressData.failed }}</span>
          </div>
          <div v-if="progressData.status === 'completed' && progressData.failed > 0" class="progress-failed">
            <el-alert
              title="部分学生未查询到Aleph账号"
              type="warning"
              :closable="false"
              show-icon>
              <div slot="default">
                共有 {{ progressData.failed }} 名学生未查询到Aleph账号，请检查学号是否正确。
              </div>
            </el-alert>
          </div>
        </el-card>
      </div>
      
      <!-- 数据表格 -->
      <el-table
        :data="list"
        v-loading="listLoading"
        border
        stripe
        style="width: 100%"
        @sort-change="sortChange"
      >
        <el-table-column prop="student_id" label="学号" width="120" fixed="left" sortable="custom" />
        <el-table-column prop="name" label="姓名" width="100" fixed="left" sortable="custom" />
        <el-table-column prop="gender" label="性别" width="80" />
        <el-table-column prop="campus_email" label="校内电子邮箱" width="200" show-overflow-tooltip />
        <el-table-column prop="personal_email" label="电子邮箱" width="200" show-overflow-tooltip />
        <el-table-column prop="phone" label="手机号码" width="130" />
        <el-table-column prop="major" label="专业" width="150" show-overflow-tooltip />
        <el-table-column prop="grade" label="年级" width="100" />
        <el-table-column prop="enrollment_date" label="入学年月" width="120">
          <template slot-scope="scope">
            {{ scope.row.enrollment_date ? scope.row.enrollment_date.substring(0, 7) : '' }}
          </template>
        </el-table-column>
        <el-table-column prop="degree_level" label="培养层次" width="120" />
        <el-table-column prop="expected_graduation_date" label="预计毕业时间" width="120">
          <template slot-scope="scope">
            {{ scope.row.expected_graduation_date ? scope.row.expected_graduation_date.substring(0, 7) : '' }}
          </template>
        </el-table-column>
        <el-table-column prop="z308_id" label="Aleph账号" width="140" show-overflow-tooltip>
          <template slot-scope="scope">
            {{ scope.row.z308_id || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="z308_id" label="是否有Aleph账号" width="140">
          <template slot-scope="scope">
            <el-tag :type="scope.row.z308_id ? 'success' : 'info'">
              {{ scope.row.z308_id ? '有账号' : '无账号' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sync_z308_id" label="同步状态" width="140">
          <template slot-scope="scope">
            <el-tag :type="getSyncStatusType(scope.row.sync_z308_id)">
              {{ getSyncStatusText(scope.row.sync_z308_id) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template slot-scope="scope">
            <el-button type="primary" size="mini" @click="showDetail(scope.row)">
              详情
            </el-button>
            <el-button type="success" size="mini" @click="editStudent(scope.row)" v-if="canEdit(scope.row)">
              编辑
            </el-button>
            <el-button 
              :type="scope.row.sync_z308_id === 1 ? 'info' : 'warning'" 
              size="mini" 
              @click="syncSingleStudent(scope.row)"
              :loading="scope.row.syncing"
              :disabled="scope.row.syncing || scope.row.sync_z308_id === 1"
            >
              {{ scope.row.syncing ? '同步中...' : (scope.row.sync_z308_id === 1 ? '已同步' : '同步账号') }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 分页 -->
      <pagination 
        v-show="total>0" 
        :total="total" 
        :page.sync="listQuery.page" 
        :limit.sync="listQuery.per_page" 
        @pagination="getList" 
      />
    </el-card>
    
    <!-- 学生详情弹窗 -->
    <el-dialog
      title="学生详细信息"
      :visible.sync="detailDialogVisible"
      width="800px"
      :close-on-click-modal="false"
    >
      <div v-if="currentStudent" class="student-detail">
        <el-row :gutter="20">
          <el-col :span="12">
            <div class="detail-section">
              <h4>基本信息</h4>
              <el-descriptions :column="1" border>
                <el-descriptions-item label="学号">{{ currentStudent.student_id }}</el-descriptions-item>
                <el-descriptions-item label="姓名">{{ currentStudent.name }}</el-descriptions-item>
                <el-descriptions-item label="性别">{{ currentStudent.gender }}</el-descriptions-item>
                <el-descriptions-item label="民族">{{ currentStudent.nationality }}</el-descriptions-item>
                <el-descriptions-item label="政治面貌">{{ currentStudent.political_status }}</el-descriptions-item>
                <el-descriptions-item label="证件类型">{{ currentStudent.id_type }}</el-descriptions-item>
                <el-descriptions-item label="证件号码">{{ currentStudent.id_number }}</el-descriptions-item>
                <el-descriptions-item label="国家地区">{{ currentStudent.country }}</el-descriptions-item>
                <el-descriptions-item label="港澳台">{{ currentStudent.hong_kong_macao_taiwan }}</el-descriptions-item>
              </el-descriptions>
            </div>
          </el-col>
          
          <el-col :span="12">
            <div class="detail-section">
              <h4>联系方式</h4>
              <el-descriptions :column="1" border>
                <el-descriptions-item label="校内邮箱">{{ currentStudent.campus_email }}</el-descriptions-item>
                <el-descriptions-item label="个人邮箱">{{ currentStudent.personal_email }}</el-descriptions-item>
                <el-descriptions-item label="手机号码">{{ currentStudent.phone }}</el-descriptions-item>
              </el-descriptions>
            </div>
          </el-col>
        </el-row>
        
        <el-row :gutter="20" style="margin-top: 20px;">
          <el-col :span="12">
            <div class="detail-section">
              <h4>学习信息</h4>
              <el-descriptions :column="1" border>
                <el-descriptions-item label="专业">{{ currentStudent.major }}</el-descriptions-item>
                <el-descriptions-item label="院系">{{ currentStudent.department }}</el-descriptions-item>
                <el-descriptions-item label="学习方式">{{ currentStudent.study_mode }}</el-descriptions-item>
                <el-descriptions-item label="年级">{{ currentStudent.grade }}</el-descriptions-item>
                <el-descriptions-item label="入学日期">{{ currentStudent.enrollment_date }}</el-descriptions-item>
                <el-descriptions-item label="学生类型">{{ currentStudent.student_type }}</el-descriptions-item>
                <el-descriptions-item label="学位类型">{{ currentStudent.degree_type }}</el-descriptions-item>
                <el-descriptions-item label="专项计划">{{ currentStudent.special_plan }}</el-descriptions-item>
                <el-descriptions-item label="学位层次">{{ currentStudent.degree_level }}</el-descriptions-item>
                <el-descriptions-item label="预计毕业时间">{{ currentStudent.expected_graduation_date }}</el-descriptions-item>
                <el-descriptions-item label="入学方式">{{ currentStudent.enrollment_mode }}</el-descriptions-item>
                <el-descriptions-item label="学生类别">{{ currentStudent.student_category }}</el-descriptions-item>
                <el-descriptions-item label="导师姓名">{{ currentStudent.supervisor }}</el-descriptions-item>
                <el-descriptions-item label="班级">{{ currentStudent.class_name }}</el-descriptions-item>
                <el-descriptions-item label="注册状态">{{ currentStudent.registration_status }}</el-descriptions-item>
              </el-descriptions>
            </div>
          </el-col>
          
          <el-col :span="12">
            <div class="detail-section">
              <h4>系统信息</h4>
              <el-descriptions :column="1" border>
                <el-descriptions-item label="z308_id">
                  <span v-if="currentStudent.z308_id">{{ currentStudent.z308_id }}</span>
                  <span v-else style="color: #999;">无</span>
                </el-descriptions-item>
                <el-descriptions-item label="Aleph账号状态">
                  <el-tag :type="currentStudent.z308_id ? 'success' : 'danger'">
                    {{ currentStudent.z308_id ? '有账号' : '无账号' }}
                  </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="同步状态">
                  <el-tag :type="getSyncStatusType(currentStudent.sync_z308_id)">
                    {{ getSyncStatusText(currentStudent.sync_z308_id) }}
                  </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="上传人">{{ currentStudent.uploader_id }}</el-descriptions-item>
                <el-descriptions-item label="上传时间">{{ currentStudent.create_time }}</el-descriptions-item>
                <el-descriptions-item label="更新时间">{{ currentStudent.update_time }}</el-descriptions-item>
              </el-descriptions>
            </div>
          </el-col>
        </el-row>
      </div>
      
      <div slot="footer" class="dialog-footer">
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </div>
    </el-dialog>
    
    <!-- 编辑学生信息弹窗 -->
    <el-dialog
      title="编辑学生信息"
      :visible.sync="editDialogVisible"
      width="800px"
      :close-on-click-modal="false"
    >
      <el-form :model="editForm" :rules="editRules" ref="editForm" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="学号" prop="student_id">
              <el-input v-model="editForm.student_id" placeholder="请输入学号" />
            </el-form-item>
            <el-form-item label="姓名" prop="name">
              <el-input v-model="editForm.name" placeholder="请输入姓名" />
            </el-form-item>
            <el-form-item label="性别">
              <el-select v-model="editForm.gender" placeholder="请选择性别" clearable>
                <el-option label="男" value="男" />
                <el-option label="女" value="女" />
              </el-select>
            </el-form-item>
            <el-form-item label="民族">
              <el-input v-model="editForm.nationality" placeholder="请输入民族" />
            </el-form-item>
            <el-form-item label="政治面貌">
              <el-input v-model="editForm.political_status" placeholder="请输入政治面貌" />
            </el-form-item>
            <el-form-item label="证件类型">
              <el-input v-model="editForm.id_type" placeholder="请输入证件类型" />
            </el-form-item>
            <el-form-item label="证件号码" prop="id_number">
              <el-input v-model="editForm.id_number" placeholder="请输入证件号码" />
            </el-form-item>
            <el-form-item label="国家地区">
              <el-input v-model="editForm.country" placeholder="请输入国家地区" />
            </el-form-item>
            <el-form-item label="港澳台">
              <el-input v-model="editForm.hong_kong_macao_taiwan" placeholder="请输入港澳台标识" />
            </el-form-item>
          </el-col>
          
          <el-col :span="12">
            <el-form-item label="校内邮箱">
              <el-input v-model="editForm.campus_email" placeholder="请输入校内邮箱" />
            </el-form-item>
            <el-form-item label="个人邮箱">
              <el-input v-model="editForm.personal_email" placeholder="请输入个人邮箱" />
            </el-form-item>
            <el-form-item label="手机号码" prop="phone">
              <el-input v-model="editForm.phone" placeholder="请输入手机号码" />
            </el-form-item>
            <el-form-item label="专业">
              <el-input v-model="editForm.major" placeholder="请输入专业" />
            </el-form-item>
            <el-form-item label="院系">
              <el-input v-model="editForm.department" placeholder="请输入院系" />
            </el-form-item>
            <el-form-item label="学习方式">
              <el-input v-model="editForm.study_mode" placeholder="请输入学习方式" />
            </el-form-item>
            <el-form-item label="年级">
              <el-input v-model="editForm.grade" placeholder="请输入年级" />
            </el-form-item>
            <el-form-item label="入学日期">
              <el-date-picker
                v-model="editForm.enrollment_date"
                type="date"
                placeholder="选择入学日期"
                format="yyyy-MM-dd"
                value-format="yyyy-MM-dd"
                style="width: 100%">
              </el-date-picker>
            </el-form-item>
            <el-form-item label="学生类型">
              <el-input v-model="editForm.student_type" placeholder="请输入学生类型" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20" style="margin-top: 20px;">
          <el-col :span="12">
            <el-form-item label="学位类型">
              <el-input v-model="editForm.degree_type" placeholder="请输入学位类型" />
            </el-form-item>
            <el-form-item label="专项计划">
              <el-input v-model="editForm.special_plan" placeholder="请输入专项计划" />
            </el-form-item>
            <el-form-item label="学位层次">
              <el-input v-model="editForm.degree_level" placeholder="请输入学位层次" />
            </el-form-item>
            <el-form-item label="预计毕业时间">
              <el-date-picker
                v-model="editForm.expected_graduation_date"
                type="date"
                placeholder="选择预计毕业时间"
                format="yyyy-MM-dd"
                value-format="yyyy-MM-dd"
                style="width: 100%">
              </el-date-picker>
            </el-form-item>
            <el-form-item label="入学方式">
              <el-input v-model="editForm.enrollment_mode" placeholder="请输入入学方式" />
            </el-form-item>
          </el-col>
          
          <el-col :span="12">
            <el-form-item label="学生类别">
              <el-input v-model="editForm.student_category" placeholder="请输入学生类别" />
            </el-form-item>
            <el-form-item label="导师姓名">
              <el-input v-model="editForm.supervisor" placeholder="请输入导师姓名" />
            </el-form-item>
            <el-form-item label="班级">
              <el-input v-model="editForm.class_name" placeholder="请输入班级" />
            </el-form-item>
            <el-form-item label="注册状态">
              <el-input v-model="editForm.registration_status" placeholder="请输入注册状态" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      
      <div slot="footer" class="dialog-footer">
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveStudent" :loading="editLoading">保存</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { getStudents, updateStudent, exportStudents, triggerZ308Update, syncSingleStudentAleph } from '@/api/students'
import Pagination from '@/components/Pagination'
import request from '@/utils/request'

export default {
  name: 'Students',
  components: { Pagination },
  data() {
    return {
      list: null,
      total: 0,
      listLoading: true,
      triggerLoading: false,
      detailDialogVisible: false,
      editDialogVisible: false,
      editLoading: false,
      currentStudent: null,
      editForm: {},
      editRules: {
        student_id: [
          { required: true, message: '请输入学号', trigger: 'blur' }
        ],
        name: [
          { required: true, message: '请输入姓名', trigger: 'blur' }
        ],
        phone: [
          { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
        ]
      },
      listQuery: {
        page: 1,
        per_page: 20,
        uploader_id: '',
        student_id: '',
        name: '',
        sync_z308_id: ''
      },
      // 进度条相关
      showProgress: false,
      currentTaskId: '',
      progressData: {
        status: 'processing',
        total: 0,
        processed: 0,
        success: 0,
        failed: 0,
        failed_students: []
      },
      pollingTimer: null
    }
  },
  computed: {
    progressPercentage() {
      if (this.progressData.total === 0) return 0
      return Math.round((this.progressData.processed / this.progressData.total) * 100)
    }
  },
  created() {
    this.getList()
    // 检查是否有 taskId 参数
    if (this.$route.query.taskId) {
      this.currentTaskId = this.$route.query.taskId
      this.showProgress = true
      this.startPolling()
    }
  },
  beforeDestroy() {
    this.stopPolling()
  },
  methods: {
    getList() {
      this.listLoading = true
      getStudents(this.listQuery).then(response => {
        this.list = response.data
        this.total = response.pagination.total
        this.listLoading = false
      }).catch(error => {
        console.error('获取学生列表失败:', error)
        this.$message.error('获取学生列表失败')
        this.listLoading = false
      })
    },
    handleFilter() {
      this.listQuery.page = 1
      this.getList()
    },
    handleReset() {
      this.listQuery = {
        page: 1,
        per_page: 20,
        uploader_id: '',
        student_id: '',
        name: '',
        sync_z308_id: ''
      }
      this.getList()
    },
    sortChange(data) {
      const { prop, order } = data
      if (prop === 'student_id') {
        this.sortBy('student_id', order)
      } else if (prop === 'name') {
        this.sortBy('name', order)
      }
    },
    sortBy(prop, order) {
      if (order === 'ascending') {
        this.listQuery.sort = `+${prop}`
      } else if (order === 'descending') {
        this.listQuery.sort = `-${prop}`
      } else {
        this.listQuery.sort = null
      }
      this.handleFilter()
    },
    async handleExport() {
      try {
        this.$message.info('正在导出，请稍候...')
        
        const params = { ...this.listQuery }
        delete params.page
        delete params.per_page
        
        // 构建查询字符串
        const queryString = Object.keys(params)
          .filter(key => params[key] !== '' && params[key] !== null && params[key] !== undefined)
          .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
          .join('&')
        
        // 使用原生fetch下载文件
        const response = await fetch(`/lawSchUpl/api/students/export?${queryString}`, {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${this.$store.getters.token}`,
            'Content-Type': 'application/json'
          }
        })
        
        if (!response.ok) {
          throw new Error('导出失败')
        }
        
        // 检查响应类型
        const contentType = response.headers.get('content-type')
        
        if (contentType && contentType.includes('application/json')) {
          // 如果是JSON响应，说明后端返回的是下载URL
          const data = await response.json()
          if (data.success && data.downloadUrl) {
            // 创建下载链接
            const link = document.createElement('a')
            link.href = `/lawSchUpl${data.downloadUrl}`
            link.download = '学生名单导出.xlsx'
            document.body.appendChild(link)
            link.click()
            document.body.removeChild(link)
            this.$message.success('导出成功')
          } else {
            this.$message.error(data.message || '导出失败')
          }
        } else {
          // 如果是文件流，直接下载
          const blob = await response.blob()
          const url = window.URL.createObjectURL(blob)
          const link = document.createElement('a')
          link.href = url
          link.download = `学生名单_${new Date().getTime()}.xlsx`
          document.body.appendChild(link)
          link.click()
          document.body.removeChild(link)
          window.URL.revokeObjectURL(url)
          this.$message.success('导出成功')
        }
      } catch (error) {
        console.error('导出失败:', error)
        this.$message.error('导出失败，请重试')
      }
    },
    async handleTriggerUpdate() {
      try {
        // 确认对话框
        await this.$confirm(
          '此操作将对当前筛选条件下所有未同步的学生进行同步，是否继续？',
          '确认同步',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          }
        )
        
        this.triggerLoading = true
        
        // 传递当前的筛选条件，但不传递分页参数
        const params = {
          uploader_id: this.listQuery.uploader_id,
          student_id: this.listQuery.student_id,
          name: this.listQuery.name,
          sync_z308_id: this.listQuery.sync_z308_id
        }
        
        const response = await triggerZ308Update(params)
        
        if (response.success) {
          const data = response.data
          
          if (data.totalCount === 0) {
            this.$message.info('没有需要同步的学生数据')
          } else {
            this.$message.success(response.message)
            
            // 显示详细结果
            this.$alert(
              `<div style="line-height: 1.8;">
                <p style="margin-bottom: 15px; font-weight: bold; font-size: 16px;">同步完成！</p>
                <p style="margin: 8px 0;">总数量：<strong>${data.totalCount}</strong> 个学生</p>
                <p style="margin: 8px 0;">同步成功：<strong style="color: #67C23A;">${data.syncedCount || 0}</strong> 个</p>
                <p style="margin: 8px 0;">同步失败：<strong style="color: ${data.failedCount > 0 ? '#F56C6C' : '#909399'};">${data.failedCount || 0}</strong> 个</p>
                <p style="margin: 8px 0;">无Aleph账号：<strong style="color: #909399;">${data.noAlephCount || 0}</strong> 个</p>
                <p style="margin-top: 15px; color: ${data.failedCount > 0 ? '#E6A23C' : '#67C23A'};">
                  ${data.failedCount > 0 ? '⚠️ 部分学生同步失败，请检查详细列表。' : '✅ 所有学生都已成功同步！'}
                </p>
              </div>`,
              '同步结果',
              {
                confirmButtonText: '确定',
                dangerouslyUseHTMLString: true,
                type: data.failedCount > 0 ? 'warning' : 'success'
              }
            )
          }
          
          // 刷新数据
          this.getList()
        } else {
          this.$message.error(response.message || '同步失败')
        }
      } catch (error) {
        if (error !== 'cancel') {
          console.error('手动触发同步失败:', error)
          this.$message.error('同步失败，请稍后重试')
        }
      } finally {
        this.triggerLoading = false
      }
    },
    showDetail(student) {
      this.currentStudent = student
      this.detailDialogVisible = true
    },
    // 获取同步状态标签类型
    getSyncStatusType(status) {
      switch (status) {
        case 0:
          return 'info'  // 未查询z308_id - 蓝色
        case 1:
          return 'success'  // 已查询到z308_id并同步成功 - 绿色
        case 2:
          return 'danger'  // 查询失败或同步失败 - 红色
        default:
          return 'info'
      }
    },
    // 获取同步状态文本
    getSyncStatusText(status) {
      switch (status) {
        case 0:
          return '未同步'
        case 1:
          return '已同步'
        case 2:
          return '同步失败'
        default:
          return '未知'
      }
    },
    // 判断是否可以编辑
    canEdit(student) {
      // 只有当前用户上传的数据才能编辑
      return student.uploader_id === this.$store.getters.user_id
    },
    // 编辑学生信息
    editStudent(student) {
      this.editForm = { ...student }
      this.editDialogVisible = true
    },
    // 保存学生信息
    async saveStudent() {
      try {
        // 表单验证
        await this.$refs.editForm.validate()
        
        this.editLoading = true
        
        const response = await updateStudent(this.editForm.id, this.editForm)
        
        if (response.success) {
          this.$message.success(response.message)
          this.editDialogVisible = false
          
          // 刷新数据
          this.getList()
        } else {
          this.$message.error(response.message || '保存失败')
        }
      } catch (error) {
        if (error !== false) { // 表单验证失败时error为false
          console.error('保存学生信息失败:', error)
          this.$message.error('保存失败，请重试')
        }
      } finally {
        this.editLoading = false
      }
    },
    // 同步单条学生的Aleph账号
    async syncSingleStudent(student) {
      try {
        // 确认操作
        await this.$confirm(
          `确定要同步学生 ${student.name}（学号：${student.student_id}）的Aleph账号吗？`,
          '确认同步',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          }
        )
        
        // 设置loading状态
        this.$set(student, 'syncing', true)
        
        // 调用API
        const response = await syncSingleStudentAleph(student.id)
        
        if (response.success) {
          this.$message.success(response.message)
          // 刷新列表
          this.getList()
        } else {
          this.$message.error(response.message || '同步失败')
        }
      } catch (error) {
        if (error !== 'cancel') {
          console.error('同步Aleph账号失败:', error)
          this.$message.error(error.message || '同步失败，请重试')
        }
      } finally {
        this.$set(student, 'syncing', false)
      }
    },
    // 进度条相关方法
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
        const response = await request.get(`/task/progress/${this.currentTaskId}`)
        if (response.success) {
          const data = response.data
          this.progressData = {
            status: data.status,
            total: data.total,
            processed: data.processed,
            success: data.success,
            failed: data.failed,
            failed_students: data.failed_students || []
          }
          
          // 如果任务完成，停止轮询并刷新列表
          if (this.progressData.status === 'completed') {
            this.stopPolling()
            this.getList() // 刷新学生列表
          }
        }
      } catch (error) {
        console.error('获取进度失败:', error)
        // 如果任务不存在或发生网络错误，停止轮询
        if (
          (error.response && error.response.status === 404) ||
          error.code === 'ERR_NETWORK' ||
          error.code === 'ECONNREFUSED' ||
          error.message === 'Network Error'
        ) {
          const wasPolling = this.pollingTimer !== null
          this.stopPolling()
          if (wasPolling) {
            // 任务已完成或过期，刷新列表
            this.getList()
          }
        }
      }
    },
    closeProgress() {
      this.showProgress = false
      this.stopPolling()
      this.currentTaskId = ''
      // 清除 URL 中的 taskId 参数
      this.$router.replace({ query: {} })
    }
  }
}
</script>

<style lang="scss" scoped>
.filter-container {
  padding: 10px;
  margin-bottom: 20px;
  background-color: #f5f5f5;
  border-radius: 4px;
}

.progress-section {
  margin-bottom: 20px;
  
  .progress-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    
    .progress-title {
      font-size: 16px;
      font-weight: 600;
      color: #303133;
      
      i {
        margin-right: 8px;
      }
    }
  }
  
  .progress-detail {
    display: flex;
    justify-content: space-around;
    margin-top: 15px;
    padding: 10px;
    background-color: #f5f7fa;
    border-radius: 4px;
    
    span {
      font-size: 14px;
      color: #606266;
    }
  }
  
  .progress-failed {
    margin-top: 15px;
  }
}

.student-detail {
  max-height: 600px;
  overflow-y: auto;
}

.detail-section {
  margin-bottom: 20px;
}

.detail-section h4 {
  margin-bottom: 15px;
  color: #303133;
  font-weight: 600;
  border-bottom: 2px solid #409EFF;
  padding-bottom: 8px;
}

.dialog-footer {
  text-align: right;
}

.dialog-footer .el-button {
  margin-left: 10px;
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
