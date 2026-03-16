# 法学院名单上传系统

## 快速开始

### 1. 配置环境变量

复制环境变量示例文件并修改：

```bash
cp .env.example .env
vi .env
```

### 2. 生成 SECRET_KEY

```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

将生成的密钥填入 `.env` 文件中的 `SECRET_KEY`。

### 3. 构建和启动

```bash
# 构建镜像
sudo docker-compose build

# 启动服务
sudo docker-compose up -d

# 查看日志
sudo docker-compose logs -f
```

### 4. 访问系统

打开浏览器访问：`http://服务器IP/lawSchUpl/login`

## 常用命令

```bash
# 停止服务
sudo docker-compose down

# 重启服务
sudo docker-compose restart

# 查看日志
sudo docker-compose logs -f backend
sudo docker-compose logs -f frontend

# 查看容器状态
sudo docker-compose ps
```

## 目录结构

```
lawSchoolUpload/
├── backend/              # 后端代码
│   ├── uploads/         # 上传文件目录
│   ├── config.py        # 配置文件
│   ├── app.py           # Flask 应用主文件
│   ├── Dockerfile       # 后端 Dockerfile
│   └── requirements.txt # Python 依赖
├── frontend/            # 前端代码
│   ├── dist/           # 前端构建文件（需要复制到这里）
│   ├── Dockerfile      # 前端 Dockerfile
│   └── nginx.conf      # Nginx 配置
├── docker-compose.yml   # Docker Compose 配置
├── .env                # 环境变量（需要创建）
└── README.md          # 本文件
```

## 注意事项

1. 确保前端代码已构建并放在 `frontend/dist/` 目录中
2. 确保数据库服务器和外部 API 可以从部署服务器访问
3. 修改 `SECRET_KEY` 为随机字符串
4. 根据实际情况修改授权用户列表

## 详细部署文档

请参考部署指南文档获取完整的部署说明。

