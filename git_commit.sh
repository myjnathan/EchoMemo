#!/bin/bash

# EchoMemo Git提交指南
# 使用方法: chmod +x git_commit.sh && ./git_commit.sh

echo "================================================"
echo "🚀 EchoMemo Git 提交指南"
echo "================================================"
echo ""

# 检查Git状态
echo "📋 步骤1: 检查Git状态"
echo "================================================"
git status
echo ""

# 检查是否有修改
if git diff-index --quiet HEAD --; then
    if [ -z "$(git ls-files --others --exclude-standard)" ]; then
        echo "✅ 没有需要提交的修改"
        echo ""
        echo "提示: 如果你想创建一个新的提交来记录今天的工作，"
        echo "     可以先做一些小的修改，然后再运行此脚本。"
        exit 0
    fi
fi

echo "⚠️  检测到以下修改："
echo ""

# 显示未跟踪的文件
UNTRACKED=$(git ls-files --others --exclude-standard)
if [ -n "$UNTRACKED" ]; then
    echo "📄 未跟踪的文件:"
    echo "$UNTRACKED" | while read file; do
        echo "   + $file"
    done
    echo ""
fi

# 显示已修改的文件
MODIFIED=$(git diff --name-only)
if [ -n "$MODIFIED" ]; then
    echo "📝 已修改的文件:"
    echo "$MODIFIED" | while read file; do
        echo "   ~ $file"
    done
    echo ""
fi

# 显示已暂存的文件
STAGED=$(git diff --cached --name-only)
if [ -n "$STAGED" ]; then
    echo "📦 已暂存的文件:"
    echo "$STAGED" | while read file; do
        echo "   ✓ $file"
    done
    echo ""
fi

echo "================================================"
echo "📋 步骤2: 选择操作"
echo "================================================"
echo ""
echo "请选择要执行的操作："
echo ""
echo "1. 添加所有文件并创建提交"
echo "2. 只添加文档文件并创建提交"
echo "3. 查看文件差异"
echo "4. 取消"
echo ""
read -p "请输入选项 (1-4): " choice

case $choice in
    1)
        echo ""
        echo "================================================"
        echo "📋 步骤3: 添加所有文件"
        echo "================================================"
        git add .
        echo ""
        echo "✅ 所有文件已添加到暂存区"
        echo ""

        echo "================================================"
        echo "📋 步骤4: 创建提交"
        echo "================================================"

        # 自动生成提交消息
        COMMIT_MSG="fix: 修复LLM中文输出问题和优化系统配置

主要修改：
- LLM服务：将system_prompt改为中文，输出中文摘要和标签
- STT服务：添加language参数配置，默认使用中文识别
- 配置管理：添加STT_LANGUAGE环境变量支持
- UI优化：使用中文情绪标签（开心、焦虑、平静等）

修复问题：
- LLM输出英文摘要和标签（即使输入是中文）
- STT默认使用英文识别

技术细节：
- 修改文件：backend/services/llm.py
- 修改文件：backend/services/stt.py
- 修改文件：backend/config.py
- 部署：后端已重新部署到服务器

测试状态：
- ✅ 后端已部署
- ✅ LLM提示词已改为中文
- ✅ STT语言参数已配置为'zh'

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

        echo ""
        echo "提交消息预览："
        echo "================================================"
        echo "$COMMIT_MSG"
        echo "================================================"
        echo ""

        read -p "是否使用此提交消息？(y/n): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            git commit -m "$COMMIT_MSG"
            echo ""
            echo "✅ 提交成功！"
            echo ""
            echo "================================================"
            echo "📋 步骤5: 推送到远程仓库"
            echo "================================================"
            echo ""
            echo "准备推送到远程仓库..."
            git push origin main
            echo ""
            echo "✅ 推送成功！"
        else
            echo ""
            echo "❌ 已取消提交"
        fi
        ;;

    2)
        echo ""
        echo "================================================"
        echo "📋 步骤3: 添加文档文件"
        echo "================================================"
        git add *.md docs/ 2>/dev/null || git add *.md
        echo ""
        echo "✅ 文档文件已添加"
        echo ""

        echo "================================================"
        echo "📋 步骤4: 创建提交"
        echo "================================================"

        DOC_MSG="docs: 添加项目开发和部署文档

文档列表：
- 登录注册模块开发方案
- 移除认证依赖方案
- UI更新总结
- STT和LLM修复报告
- 测试报告和部署指南
- 项目完善计划

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

        echo ""
        echo "提交消息预览："
        echo "================================================"
        echo "$DOC_MSG"
        echo "================================================"
        echo ""

        read -p "是否使用此提交消息？(y/n): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            git commit -m "$DOC_MSG"
            echo ""
            echo "✅ 提交成功！"
            echo ""
            echo "================================================"
            echo "📋 步骤5: 推送到远程仓库"
            echo "================================================"
            echo ""
            echo "准备推送到远程仓库..."
            git push origin main
            echo ""
            echo "✅ 推送成功！"
        else
            echo ""
            echo "❌ 已取消提交"
        fi
        ;;

    3)
        echo ""
        echo "================================================"
        echo "📋 步骤3: 查看文件差异"
        echo "================================================"
        echo ""
        git diff HEAD
        ;;

    4)
        echo ""
        echo "❌ 已取消操作"
        ;;

    *)
        echo ""
        echo "❌ 无效选项"
        ;;
esac

echo ""
echo "================================================"
echo "✅ 操作完成"
echo "================================================"
echo ""
echo "提示："
echo "- 查看提交历史: git log --oneline -5"
echo "- 查看远程状态: git remote -v"
echo "- 查看最近修改: git diff HEAD~1"
echo ""
