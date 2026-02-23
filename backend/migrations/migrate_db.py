#!/usr/bin/env python3
"""
Phase 2 Database Migration Script
为PostgreSQL数据库添加Phase 2新字段
"""

import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError, ProgrammingError

def migrate():
    # 从环境变量获取数据库URL
    database_url = os.environ.get('DATABASE_URL')

    if not database_url:
        print("❌ 错误: DATABASE_URL环境变量未设置")
        print("当前环境变量:")
        for key, value in os.environ.items():
            if 'DATABASE' in key or 'DB' in key:
                print(f"  {key}={value}")
        sys.exit(1)

    print(f"📡 连接数据库...")
    print(f"   URL: {database_url.split('@')[1] if '@' in database_url else database_url}")

    try:
        # 创建数据库连接
        engine = create_engine(database_url)

        with engine.connect() as conn:
            print("✅ 数据库连接成功！")

            # 检查表是否存在
            result = conn.execute(text("""
                SELECT table_name FROM information_schema.tables
                WHERE table_schema='public' AND table_name='memos';
            """))

            if result.rowcount == 0:
                print("❌ 错误: memos表不存在")
                sys.exit(1)

            print("📋 执行迁移...")

            # 1. 添加 structured_summary 字段
            print("\n1️⃣ 添加 structured_summary 字段...")
            try:
                conn.execute(text("""
                    ALTER TABLE memos
                    ADD COLUMN IF NOT EXISTS structured_summary JSONB;
                """))
                conn.commit()
                print("   ✅ structured_summary 字段添加成功")
            except Exception as e:
                print(f"   ⚠️  {str(e)}")

            # 2. 添加 embedding 字段
            print("\n2️⃣ 添加 embedding 字段...")
            try:
                conn.execute(text("""
                    ALTER TABLE memos
                    ADD COLUMN IF NOT EXISTS embedding JSONB;
                """))
                conn.commit()
                print("   ✅ embedding 字段添加成功")
            except Exception as e:
                print(f"   ⚠️  {str(e)}")

            # 3. 添加 related_memo_ids 字段
            print("\n3️⃣ 添加 related_memo_ids 字段...")
            try:
                conn.execute(text("""
                    ALTER TABLE memos
                    ADD COLUMN IF NOT EXISTS related_memo_ids JSONB DEFAULT '[]'::jsonb;
                """))
                conn.commit()
                print("   ✅ related_memo_ids 字段添加成功")
            except Exception as e:
                print(f"   ⚠️  {str(e)}")

            # 4. 验证表结构
            print("\n🔍 验证表结构...")
            result = conn.execute(text("""
                SELECT column_name, data_type, column_default
                FROM information_schema.columns
                WHERE table_name='memos'
                AND column_name IN ('structured_summary', 'embedding', 'related_memo_ids')
                ORDER BY column_name;
            """))

            columns = result.fetchall()
            if columns:
                print("\n✅ 迁移成功！新增字段如下:")
                for col in columns:
                    default = col[2] if col[2] else "NULL"
                    print(f"   - {col[0]}: {col[1]} (默认值: {default})")
            else:
                print("\n⚠️  警告: 未找到新添加的字段")

            # 5. 显示完整表结构
            print("\n📊 完整的 memos 表结构:")
            result = conn.execute(text("""
                SELECT column_name, data_type, is_nullable
                FROM information_schema.columns
                WHERE table_name='memos'
                ORDER BY ordinal_position;
            """))

            for col in result.fetchall():
                nullable = "可空" if col[2] == "YES" else "非空"
                print(f"   {col[0]:<25} {col[1]:<15} {nullable}")

    except OperationalError as e:
        print(f"❌ 数据库连接失败: {e}")
        print("\n请检查:")
        print("1. DATABASE_URL 是否正确")
        print("2. 数据库是否运行")
        print("3. 网络连接是否正常")
        sys.exit(1)
    except ProgrammingError as e:
        print(f"❌ SQL执行错误: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 未知错误: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

    print("\n🎉 数据库迁移完成！")

if __name__ == "__main__":
    migrate()
