# 查看应用日志指南

## 📋 基本命令

### 查看所有服务日志
```bash
cd /opt/lawSchoolUpload
sudo docker compose logs
```

### 查看后端日志
```bash
sudo docker compose logs backend
```

### 查看前端日志
```bash
sudo docker compose logs frontend
```

## 🔍 常用选项

### 实时查看日志（跟随模式）
```bash
# 所有服务
sudo docker compose logs -f

# 只查看后端
sudo docker compose logs -f backend

# 只查看前端
sudo docker compose logs -f frontend
```

### 查看最近的日志
```bash
# 查看最后 50 行
sudo docker compose logs --tail=50 backend

# 查看最后 100 行
sudo docker compose logs --tail=100 backend
```

### 查看特定时间段的日志
```bash
# 最近 10 分钟
sudo docker compose logs --since 10m backend

# 最近 1 小时
sudo docker compose logs --since 1h backend

# 从指定时间开始
sudo docker compose logs --since 2025-12-02T09:00:00 backend

# 指定时间范围
sudo docker compose logs --since 2025-12-02T09:00:00 --until 2025-12-02T10:00:00 backend
```

## 🔎 过滤和搜索日志

### 搜索特定关键词
```bash
# 搜索错误
sudo docker compose logs backend | grep -i "error"

# 搜索特定用户
sudo docker compose logs backend | grep -i "08212"

# 搜索登录相关
sudo docker compose logs backend | grep -i "登录\|login"

# 搜索权限相关
sudo docker compose logs backend | grep -i "权限\|permission"

# 搜索加解密相关
sudo docker compose logs backend | grep -i "加解密\|encrypt"
```

### 组合使用
```bash
# 实时查看并过滤错误
sudo docker compose logs -f backend | grep -i "error"

# 查看最近的错误日志
sudo docker compose logs --tail=100 backend | grep -i "error"
```

## 📊 日志文件位置

### Docker 容器日志
Docker Compose 的日志存储在 Docker 的日志驱动中，可以通过以下方式查看：

```bash
# 查看容器的日志文件位置
sudo docker inspect law_school_backend | grep -i logpath

# 直接查看日志文件（如果使用 json-file 驱动）
sudo cat $(sudo docker inspect --format='{{.LogPath}}' law_school_backend)
```

## 🛠️ 实用技巧

### 1. 查看启动日志
```bash
sudo docker compose logs backend | head -50
```

### 2. 查看最近的错误
```bash
sudo docker compose logs backend --tail=200 | grep -i "error\|exception\|failed"
```

### 3. 查看特定 API 请求
```bash
sudo docker compose logs backend | grep "/lawSchUpl/api/"
```

### 4. 查看定时任务执行日志
```bash
sudo docker compose logs backend | grep -i "定时任务\|scheduler"
```

### 5. 导出日志到文件
```bash
# 导出后端日志
sudo docker compose logs backend > backend_logs_$(date +%Y%m%d_%H%M%S).txt

# 导出所有日志
sudo docker compose logs > all_logs_$(date +%Y%m%d_%H%M%S).txt
```

## 📝 日志级别

应用使用 Python 的 logging 模块，日志级别包括：
- `INFO`: 一般信息
- `WARNING`: 警告信息
- `ERROR`: 错误信息
- `DEBUG`: 调试信息（生产环境通常关闭）

## 🔧 故障排查示例

### 查看登录问题
```bash
sudo docker compose logs backend | grep -A 5 -B 5 "登录\|login\|callback"
```

### 查看数据库连接问题
```bash
sudo docker compose logs backend | grep -i "database\|db\|sql"
```

### 查看 API 调用问题
```bash
sudo docker compose logs backend | grep -i "api\|request\|response"
```

## ⚙️ 配置日志轮转

Docker 默认会限制日志大小，可以在 `/etc/docker/daemon.json` 中配置：

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

配置后需要重启 Docker 服务：
```bash
sudo systemctl restart docker
```

