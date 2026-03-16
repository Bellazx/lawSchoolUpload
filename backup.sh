#!/bin/bash
# 备份脚本

set -e

BACKUP_DIR="/backup/lawschool"
SOURCE_DIR="/opt/lawSchoolUpload/backend/uploads"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 执行备份
echo "开始备份上传文件..."
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz -C $(dirname $SOURCE_DIR) $(basename $SOURCE_DIR)

# 保留最近 30 天的备份
echo "清理旧备份（保留最近30天）..."
find $BACKUP_DIR -name "uploads_*.tar.gz" -mtime +30 -delete

echo "备份完成: $BACKUP_DIR/uploads_$DATE.tar.gz"
echo "备份文件大小: $(du -h $BACKUP_DIR/uploads_$DATE.tar.gz | cut -f1)"

