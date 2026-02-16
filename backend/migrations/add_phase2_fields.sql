-- Phase 2 Database Migration
-- 添加结构化摘要和关联功能字段
-- Date: 2026-02-16

-- 为 memos 表添加 Phase 2 新字段
ALTER TABLE memos ADD COLUMN structured_summary JSON;
ALTER TABLE memos ADD COLUMN embedding JSON;
ALTER TABLE memos ADD COLUMN related_memo_ids JSON;

-- 字段说明：
-- structured_summary: JSON格式的结构化摘要
--   {
--     "core_message": "一句话核心信息",
--     "key_points": ["关键点1", "关键点2"],
--     "action_items": ["行动项1", "行动项2"],
--     "topics": ["主题1", "主题2"]
--   }
--
-- embedding: 文本嵌入向量（用于语义搜索）
--   [0.123, -0.456, 0.789, ...]
--
-- related_memo_ids: 相关笔记ID列表
--   [1, 5, 12, 23, 45]
