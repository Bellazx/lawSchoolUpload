# 前端 Dockerfile
FROM nginx:alpine

# 复制前端构建文件到 Nginx 默认目录
# 注意：这里假设前端代码已经构建好，放在 dist 目录中
# 如果前端代码需要构建，请在构建阶段处理
COPY dist/ /usr/share/nginx/html/

# 复制 Nginx 配置文件
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/lawSchUpl/ || exit 1

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]

