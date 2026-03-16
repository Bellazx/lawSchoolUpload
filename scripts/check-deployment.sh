#!/bin/bash
# 部署检查脚本

echo "=========================================="
echo "法学院名单上传系统 - 部署检查"
echo "=========================================="
echo ""

# 检查 Docker
echo "1. 检查 Docker..."
if command -v docker &> /dev/null; then
    docker_version=$(docker --version)
    echo "   ✓ Docker 已安装: $docker_version"
else
    echo "   ✗ Docker 未安装"
    exit 1
fi

# 检查 Docker 服务
if docker info > /dev/null 2>&1; then
    echo "   ✓ Docker 服务正在运行"
else
    echo "   ✗ Docker 服务未运行，请执行: sudo systemctl start docker"
    exit 1
fi

# 检查 docker-compose
echo ""
echo "2. 检查 Docker Compose..."
if command -v docker-compose &> /dev/null; then
    compose_version=$(docker-compose --version)
    echo "   ✓ Docker Compose 已安装: $compose_version"
else
    echo "   ✗ Docker Compose 未安装"
    exit 1
fi

# 检查目录结构
echo ""
echo "3. 检查目录结构..."
required_dirs=("backend" "frontend" "backend/uploads")
for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "   ✓ $dir 目录存在"
    else
        echo "   ✗ $dir 目录不存在"
        exit 1
    fi
done

# 检查配置文件
echo ""
echo "4. 检查配置文件..."
required_files=("docker-compose.yml" "backend/config.py" "backend/Dockerfile" "frontend/Dockerfile")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✓ $file 存在"
    else
        echo "   ✗ $file 不存在"
        exit 1
    fi
done

# 检查端口占用
echo ""
echo "5. 检查端口占用..."
if netstat -tlnp 2>/dev/null | grep -q ":80 "; then
    echo "   ⚠ 端口 80 已被占用"
    netstat -tlnp | grep ":80 "
else
    echo "   ✓ 端口 80 可用"
fi

if netstat -tlnp 2>/dev/null | grep -q ":5000 "; then
    echo "   ⚠ 端口 5000 已被占用"
    netstat -tlnp | grep ":5000 "
else
    echo "   ✓ 端口 5000 可用"
fi

# 检查容器状态
echo ""
echo "6. 检查容器状态..."
if [ "$(sudo docker-compose ps -q 2>/dev/null | wc -l)" -gt 0 ]; then
    echo "   当前运行的容器:"
    sudo docker-compose ps
else
    echo "   ℹ 没有运行中的容器"
fi

# 检查网络连通性
echo ""
echo "7. 检查网络连通性..."
echo "   测试数据库服务器 (10.119.13.123)..."
if ping -c 1 -W 2 10.119.13.123 > /dev/null 2>&1; then
    echo "   ✓ 数据库服务器可达"
else
    echo "   ✗ 无法连接到数据库服务器"
fi

echo "   测试外部 API (10.119.4.239)..."
if ping -c 1 -W 2 10.119.4.239 > /dev/null 2>&1; then
    echo "   ✓ 外部 API 服务器可达"
else
    echo "   ✗ 无法连接到外部 API 服务器"
fi

echo ""
echo "=========================================="
echo "检查完成！"
echo "=========================================="

