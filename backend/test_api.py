#!/usr/bin/env python3
"""
测试API脚本 - 验证移除认证依赖后API是否正常工作
"""
import requests
import json

BASE_URL = "http://localhost:8000"

def test_health_check():
    """测试健康检查"""
    print("\n🔍 测试健康检查...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"✅ 健康检查: {response.status_code} - {response.json()}")

def test_get_memos():
    """测试获取日记列表（无需认证）"""
    print("\n🔍 测试获取日记列表...")
    response = requests.get(f"{BASE_URL}/memos")
    print(f"✅ 获取日记列表: {response.status_code}")
    if response.status_code == 200:
        memos = response.json()
        print(f"   📝 当前日记数量: {len(memos)}")
        if memos:
            print(f"   📄 最新日记: {memos[0].get('summary', 'N/A')}")
    else:
        print(f"   ❌ 错误: {response.text}")

def test_get_memo():
    """测试获取单个日记（无需认证）"""
    print("\n🔍 测试获取单个日记...")
    # 先获取日记列表
    response = requests.get(f"{BASE_URL}/memos")
    if response.status_code == 200:
        memos = response.json()
        if memos:
            memo_id = memos[0]['id']
            response = requests.get(f"{BASE_URL}/memos/{memo_id}")
            print(f"✅ 获取日记 #{memo_id}: {response.status_code}")
        else:
            print("   ℹ️  没有日记，跳过测试")
    else:
        print(f"   ❌ 无法获取日记列表")

def test_upload():
    """测试上传音频（需要实际文件）"""
    print("\n🔍 测试上传音频端点...")
    print("   ℹ️  需要实际音频文件，跳过测试")

def main():
    print("=" * 60)
    print("🧪 EchoMemo API 测试 - MVP模式（无认证）")
    print("=" * 60)

    try:
        test_health_check()
        test_get_memos()
        test_get_memo()
        # test_upload()  # 需要实际文件

        print("\n" + "=" * 60)
        print("✅ 所有测试完成！")
        print("=" * 60)

    except requests.exceptions.ConnectionError:
        print("\n❌ 无法连接到服务器，请确保后端正在运行")
        print("   启动命令: cd backend && uvicorn main:app --reload")
    except Exception as e:
        print(f"\n❌ 测试失败: {e}")

if __name__ == "__main__":
    main()
