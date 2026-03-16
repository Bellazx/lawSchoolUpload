#!/bin/bash
# 启动脚本

set -e

echo "=========================================="
echo "法学院名单上传系统 - 启动脚本"
echo "=========================================="

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "错误: Docker 未运行，请先启动 Docker"
    exit 1
fi

# 检查 docker-compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "错误: docker-compose 未安装"
    exit 1
fi

# 检查配置文件
if [ ! -f "backend/config.py" ]; then
    echo "错误: 未找到 backend/config.py 配置文件"
    exit 1
fi

# 检查上传目录
if [ ! -d "backend/uploads" ]; then
    echo "创建上传目录..."
    mkdir -p backend/uploads
    chmod 755 backend/uploads
fi

# 构建镜像
echo "构建 Docker 镜像..."
sudo docker-compose build

# 启动服务
echo "启动服务..."
sudo docker-compose up -d

# 等待服务启动
echo "等待服务启动..."
sleep 10

# 检查服务状态
echo "检查服务状态..."
sudo docker-compose ps

echo ""
echo "=========================================="
echo "启动完成！"
echo "=========================================="
echo "访问地址: http://$(hostname -I | awk '{print $1}')/lawSchUpl/login"
echo ""
echo "查看日志: sudo docker-compose logs -f"
echo "停止服务: sudo docker-compose down"
echo "=========================================="

