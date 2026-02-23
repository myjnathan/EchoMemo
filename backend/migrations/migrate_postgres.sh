#!/bin/bash
# Phase 2 Database Migration for PostgreSQL
# 为PostgreSQL数据库添加Phase 2新字段

echo "开始数据库迁移..."

# 检查是否设置了数据库URL
if [ -z "$DATABASE_URL" ]; then
    echo "错误: DATABASE_URL环境变量未设置"
    exit 1
fi

# 执行迁移
echo "添加 structured_summary 字段..."
psql $DATABASE_URL << 'EOF'
ALTER TABLE memos ADD COLUMN IF NOT EXISTS structured_summary JSONB;
EOF

echo "添加 embedding 字段..."
psql $DATABASE_URL << 'EOF'
ALTER TABLE memos ADD COLUMN IF NOT EXISTS embedding JSONB;
EOF

echo "添加 related_memo_ids 字段..."
psql $DATABASE_URL << 'EOF'
ALTER TABLE memos ADD COLUMN IF NOT EXISTS related_memo_ids JSONB DEFAULT '[]'::jsonb;
EOF

echo "验证表结构..."
psql $DATABASE_URL << 'EOF'
\d memos
EOF

echo "✅ 数据库迁移完成！"
