# 后端 Dockerfile
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    unixodbc \
    unixodbc-dev \
    tdsodbc \
    freetds-bin \
    freetds-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装 SQL Server ODBC 驱动（使用新的 GPG 密钥添加方式）
# 注意：如果网络无法访问 Microsoft 源，可以暂时注释掉这部分，使用 pyodbc 的默认驱动
RUN mkdir -p /usr/share/keyrings \
    && (curl -fsSL --max-time 30 https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg || echo "跳过 Microsoft GPG 密钥下载") \
    && if [ -f /usr/share/keyrings/microsoft-prod.gpg ]; then \
        echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list \
        && apt-get update \
        && ACCEPT_EULA=Y apt-get install -y msodbcsql17 || echo "ODBC 驱动安装失败，将使用系统默认驱动"; \
    else \
        echo "警告: 无法下载 Microsoft GPG 密钥，跳过 ODBC 驱动安装"; \
    fi \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 创建上传目录
RUN mkdir -p uploads && chmod 755 uploads

# 暴露端口
EXPOSE 5000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/lawSchUpl/api/health || exit 1

# 启动应用
CMD ["python", "app.py"]

