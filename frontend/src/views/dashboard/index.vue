<template>
  <div class="dashboard-container">
    <!-- 欢迎标题 -->
    <div class="welcome-section">
      <h1 class="welcome-title">法学院名单上传系统</h1>
      <p class="welcome-subtitle">数据统计与管理</p>
    </div>

    <!-- 数据统计卡片 -->
    <div class="statistics-section">
      <el-row :gutter="20">
        <!-- 总学生数 -->
        <el-col :xs="24" :sm="12" :md="8" :lg="6">
          <el-card class="stat-card total-card" shadow="hover" @click.native="goToStudentList()">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-user"></i>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.totalCount }}</div>
                <div class="stat-label">总学生数</div>
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 有Aleph账号 -->
        <el-col :xs="24" :sm="12" :md="8" :lg="6">
          <el-card class="stat-card success-card" shadow="hover" @click.native="goToStudentList({ hasAleph: true })">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-success"></i>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.hasAlephCount }}</div>
                <div class="stat-label">有Aleph账号</div>
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 无Aleph账号 -->
        <el-col :xs="24" :sm="12" :md="8" :lg="6">
          <el-card class="stat-card info-card" shadow="hover" @click.native="goToStudentList({ hasAleph: false })">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-info"></i>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.noAlephCount }}</div>
                <div class="stat-label">无Aleph账号</div>
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 未同步 -->
        <el-col :xs="24" :sm="12" :md="8" :lg="6">
          <el-card class="stat-card warning-card" shadow="hover" @click.native="goToStudentList({ sync_z308_id: 0 })">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-warning"></i>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.notSyncedCount }}</div>
                <div class="stat-label">未同步</div>
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 已同步 -->
        <el-col :xs="24" :sm="12" :md="8" :lg="6">
          <el-card class="stat-card synced-card" shadow="hover" @click.native="goToStudentList({ sync_z308_id: 1 })">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-circle-check"></i>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.syncedCount }}</div>
                <div class="stat-label">同步成功</div>
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 同步失败 -->
        <el-col :xs="24" :sm="12" :md="8" :lg="6">
          <el-card class="stat-card danger-card" shadow="hover" @click.native="goToStudentList({ sync_z308_id: 2 })">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-circle-close"></i>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.syncFailedCount }}</div>
                <div class="stat-label">同步失败</div>
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 今日导入 -->
        <el-col :xs="24" :sm="12" :md="8" :lg="6">
          <el-card class="stat-card primary-card" shadow="hover" @click.native="goToStudentList({ today: true })">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-upload"></i>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.todayCount }}</div>
                <div class="stat-label">今日导入</div>
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 本年导入 -->
        <el-col :xs="24" :sm="12" :md="8" :lg="6">
          <el-card class="stat-card year-card" shadow="hover" @click.native="goToStudentList({ thisYear: true })">
            <div class="stat-content">
              <div class="stat-icon">
                <i class="el-icon-date"></i>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.thisYearCount }}</div>
                <div class="stat-label">本年导入</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 快速操作区域 -->
    <div class="quick-actions-section">
      <el-row :gutter="20">
        <el-col :xs="24" :sm="12" :md="8">
          <el-card class="action-card" shadow="hover">
            <div class="action-content">
              <i class="el-icon-upload2 action-icon"></i>
              <h3>上传名单</h3>
              <p>批量导入学生信息</p>
              <el-button type="primary" @click="goToUpload">立即上传</el-button>
            </div>
          </el-card>
        </el-col>

        <el-col :xs="24" :sm="12" :md="8">
          <el-card class="action-card" shadow="hover">
            <div class="action-content">
              <i class="el-icon-s-order action-icon"></i>
              <h3>学生管理</h3>
              <p>查看和管理学生信息</p>
              <el-button type="success" @click="goToStudentList()">进入管理</el-button>
            </div>
          </el-card>
        </el-col>

        <el-col :xs="24" :sm="12" :md="8">
          <el-card class="action-card" shadow="hover">
            <div class="action-content">
              <i class="el-icon-refresh-right action-icon"></i>
              <h3>同步账号</h3>
              <p>批量同步Aleph账号</p>
              <el-button type="warning" @click="triggerSync" :loading="syncLoading">开始同步</el-button>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script>
import request from '@/utils/request'

export default {
  name: 'Dashboard',
  data() {
    return {
      syncLoading: false,
      statistics: {
        totalCount: 0,
        hasAlephCount: 0,
        noAlephCount: 0,
        notSyncedCount: 0,
        syncedCount: 0,
        syncFailedCount: 0,
        todayCount: 0,
        thisYearCount: 0
      }
    }
  },
  mounted() {
    this.loadStatistics()
  },
  methods: {
    // 加载统计数据
    async loadStatistics() {
      try {
        const response = await request.get('/statistics')
        if (response.success) {
          this.statistics = response.data
        } else {
          this.$message.error('加载统计数据失败')
        }
      } catch (error) {
        this.$message.error('加载统计数据失败')
        console.error('加载统计数据失败:', error)
      }
    },
    
    // 跳转到学生列表页面
    goToStudentList(filter = {}) {
      // 构建查询参数
      const query = {}
      
      if (filter.hasAleph === true) {
        // 有Aleph账号：z308_id不为空
        query.hasAleph = '1'
      } else if (filter.hasAleph === false) {
        // 无Aleph账号：z308_id为空
        query.hasAleph = '0'
      }
      
      if (filter.sync_z308_id !== undefined) {
        query.sync_z308_id = filter.sync_z308_id
      }
      
      if (filter.today) {
        query.today = '1'
      }
      
      if (filter.thisYear) {
        query.thisYear = '1'
      }
      
      // 跳转到学生管理页面
      this.$router.push({
        path: '/students/index',
        query
      })
    },
    
    // 跳转到上传页面
    goToUpload() {
      this.$router.push('/upload/index')
    },
    
    // 手动触发同步
    async triggerSync() {
      try {
        // 确认对话框
        await this.$confirm(
          '此操作将对所有有z308_id的学生进行同步，可能需要较长时间，是否继续？',
          '确认同步',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          }
        )
        
        this.syncLoading = true
        
        // 同步所有有z308_id的学生
        const response = await request.post('/trigger/z308-update', {})
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
                <p style="margin: 8px 0;">同步成功：<strong style="color: #67C23A;">${data.syncedCount || data.updatedCount || 0}</strong> 个</p>
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
          
          await this.loadStatistics() // 更新后重新加载统计数据
        } else {
          this.$message.error(response.message)
        }
      } catch (error) {
        if (error !== 'cancel') {
          this.$message.error('同步失败')
          console.error('同步失败:', error)
        }
      } finally {
        this.syncLoading = false
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.dashboard-container {
  min-height: calc(100vh - 84px);
  padding: 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  
  // 欢迎区域
  .welcome-section {
    text-align: center;
    margin-bottom: 40px;
    padding: 40px 0;
    
    .welcome-title {
      font-size: 42px;
      font-weight: 700;
      color: #ffffff;
      margin: 0 0 10px 0;
      text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
    }
    
    .welcome-subtitle {
      font-size: 18px;
      color: rgba(255, 255, 255, 0.9);
      margin: 0;
    }
  }

  // 统计卡片区域
  .statistics-section {
    margin-bottom: 40px;
    
    .stat-card {
      cursor: pointer;
      transition: all 0.3s ease;
      border: none;
      border-radius: 12px;
      margin-bottom: 20px;
      
      &:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
      }
      
      .stat-content {
        display: flex;
        align-items: center;
        padding: 10px;
        
        .stat-icon {
          font-size: 48px;
          margin-right: 20px;
          width: 70px;
          height: 70px;
          display: flex;
          align-items: center;
          justify-content: center;
          border-radius: 12px;
        }
        
        .stat-info {
          flex: 1;
          
          .stat-value {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 5px;
          }
          
          .stat-label {
            font-size: 14px;
            color: #909399;
          }
        }
      }
      
      // 不同类型卡片的颜色
      &.total-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        
        .stat-icon {
          background: rgba(255, 255, 255, 0.2);
        }
        
        .stat-label {
          color: rgba(255, 255, 255, 0.9);
        }
      }
      
      &.success-card {
        background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
        color: #fff;
        
        .stat-icon {
          background: rgba(255, 255, 255, 0.3);
        }
        
        .stat-label {
          color: rgba(255, 255, 255, 0.9);
        }
      }
      
      &.info-card {
        background: linear-gradient(135deg, #a1c4fd 0%, #c2e9fb 100%);
        color: #606266;
        
        .stat-icon {
          background: rgba(255, 255, 255, 0.5);
        }
      }
      
      &.warning-card {
        background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
        color: #606266;
        
        .stat-icon {
          background: rgba(255, 255, 255, 0.5);
        }
      }
      
      &.synced-card {
        background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
        color: #606266;
        
        .stat-icon {
          background: rgba(255, 255, 255, 0.5);
        }
      }
      
      &.danger-card {
        background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%);
        color: #fff;
        
        .stat-icon {
          background: rgba(255, 255, 255, 0.3);
        }
        
        .stat-label {
          color: rgba(255, 255, 255, 0.9);
        }
      }
      
      &.primary-card {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        color: #fff;
        
        .stat-icon {
          background: rgba(255, 255, 255, 0.3);
        }
        
        .stat-label {
          color: rgba(255, 255, 255, 0.9);
        }
      }
      
      &.year-card {
        background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
        color: #fff;
        
        .stat-icon {
          background: rgba(255, 255, 255, 0.3);
        }
        
        .stat-label {
          color: rgba(255, 255, 255, 0.9);
        }
      }
    }
  }

  // 快速操作区域
  .quick-actions-section {
    .action-card {
      border-radius: 12px;
      transition: all 0.3s ease;
      background: white;
      
      &:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
      }
      
      .action-content {
        text-align: center;
        padding: 30px 20px;
        
        .action-icon {
          font-size: 64px;
          color: #409EFF;
          margin-bottom: 20px;
        }
        
        h3 {
          font-size: 20px;
          font-weight: 600;
          margin: 0 0 10px 0;
          color: #303133;
        }
        
        p {
          font-size: 14px;
          color: #909399;
          margin: 0 0 20px 0;
        }
      }
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .dashboard-container {
    padding: 15px;
    
    .welcome-section {
      padding: 20px 0;
      
      .welcome-title {
        font-size: 28px;
      }
      
      .welcome-subtitle {
        font-size: 14px;
      }
    }
    
    .stat-card {
      .stat-content {
        .stat-icon {
          font-size: 36px !important;
          width: 50px !important;
          height: 50px !important;
          margin-right: 15px !important;
        }
        
        .stat-info {
          .stat-value {
            font-size: 24px !important;
          }
          
          .stat-label {
            font-size: 12px !important;
          }
        }
      }
    }
    
    .action-card {
      .action-content {
        padding: 20px 15px !important;
        
        .action-icon {
          font-size: 48px !important;
        }
        
        h3 {
          font-size: 18px !important;
        }
        
        p {
          font-size: 13px !important;
        }
      }
    }
  }
}
</style>
