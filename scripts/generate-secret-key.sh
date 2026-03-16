#!/bin/bash
# 生成 SECRET_KEY 脚本

echo "生成 SECRET_KEY..."
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
echo ""
echo "生成的 SECRET_KEY:"
echo "$SECRET_KEY"
echo ""
echo "请将此密钥复制到以下位置："
echo "1. backend/config.py 中的 SECRET_KEY"
echo "2. .env 文件中的 SECRET_KEY（如果使用环境变量）"
echo ""

