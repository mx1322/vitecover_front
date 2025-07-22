#!/bin/bash

# Saleor 数据库备份脚本
# 用于备份和恢复PostgreSQL数据库

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="saleor_backup_${TIMESTAMP}.sql"
CONTAINER_NAME="vitecover_saleor-db-1"

echo -e "${BLUE}🗄️ Saleor 数据库备份工具${NC}"
echo "================================"
echo ""

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份函数
backup_database() {
    echo -e "${BLUE}📦 开始备份数据库...${NC}"
    
    if docker exec "$CONTAINER_NAME" pg_isready -U saleor > /dev/null 2>&1; then
        docker exec "$CONTAINER_NAME" pg_dump -U saleor saleor > "$BACKUP_DIR/$BACKUP_FILE"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ 数据库备份成功！${NC}"
            echo -e "📁 备份文件: $BACKUP_DIR/$BACKUP_FILE"
            echo -e "📊 文件大小: $(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)"
        else
            echo -e "${RED}❌ 数据库备份失败！${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ 数据库连接失败！请确保数据库容器正在运行。${NC}"
        exit 1
    fi
}

# 恢复函数
restore_database() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        echo -e "${YELLOW}请指定要恢复的备份文件：${NC}"
        echo "可用的备份文件："
        ls -la "$BACKUP_DIR"/*.sql 2>/dev/null || echo "没有找到备份文件"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        echo -e "${RED}❌ 备份文件不存在: $backup_file${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}⚠️  警告：这将覆盖当前数据库！${NC}"
    read -p "确定要继续吗？(y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🔄 开始恢复数据库...${NC}"
        
        if docker exec "$CONTAINER_NAME" pg_isready -U saleor > /dev/null 2>&1; then
            docker exec -i "$CONTAINER_NAME" psql -U saleor saleor < "$backup_file"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ 数据库恢复成功！${NC}"
            else
                echo -e "${RED}❌ 数据库恢复失败！${NC}"
                exit 1
            fi
        else
            echo -e "${RED}❌ 数据库连接失败！请确保数据库容器正在运行。${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}取消恢复操作。${NC}"
    fi
}

# 列出备份文件
list_backups() {
    echo -e "${BLUE}📋 可用的备份文件：${NC}"
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR"/*.sql 2>/dev/null)" ]; then
        ls -lah "$BACKUP_DIR"/*.sql
    else
        echo "没有找到备份文件"
    fi
}

# 主菜单
show_menu() {
    echo -e "${BLUE}请选择操作：${NC}"
    echo "1) 备份数据库"
    echo "2) 恢复数据库"
    echo "3) 列出备份文件"
    echo "4) 退出"
    echo ""
    read -p "请输入选项 (1-4): " choice
}

# 主程序
case "${1:-}" in
    "backup")
        backup_database
        ;;
    "restore")
        restore_database "$2"
        ;;
    "list")
        list_backups
        ;;
    "")
        while true; do
            show_menu
            case $choice in
                1)
                    backup_database
                    echo ""
                    ;;
                2)
                    echo -e "${YELLOW}请输入备份文件路径：${NC}"
                    read -p "备份文件: " backup_file
                    restore_database "$backup_file"
                    echo ""
                    ;;
                3)
                    list_backups
                    echo ""
                    ;;
                4)
                    echo -e "${GREEN}再见！${NC}"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}无效选项，请重新选择。${NC}"
                    echo ""
                    ;;
            esac
        done
        ;;
    *)
        echo "用法: $0 [backup|restore <file>|list]"
        echo ""
        echo "选项:"
        echo "  backup             备份数据库"
        echo "  restore <file>     恢复数据库"
        echo "  list               列出备份文件"
        echo "  (无参数)           显示交互式菜单"
        exit 1
        ;;
esac 