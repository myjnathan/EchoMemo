import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '设置',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF164E63),
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingItem(
                    Icons.text_fields,
                    '自动转译',
                    '录音时实时转换为文字',
                    true,
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    Icons.security,
                    '本地存储',
                    '数据仅保存在设备本地',
                    true,
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    Icons.notifications_outlined,
                    '每日提醒',
                    '固定时间提醒记录',
                    false,
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    Icons.history,
                    '每日回响',
                    '推送过去的记录',
                    true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingItem(
                    Icons.color_lens_outlined,
                    '主题',
                    '浅色模式',
                    false,
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF164E63)),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    Icons.language,
                    '语言',
                    '简体中文',
                    false,
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF164E63)),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    Icons.backup_outlined,
                    '导出数据',
                    '备份您的记录',
                    false,
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF164E63)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'EchoMemo v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF164E63).withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    bool value, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF164E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF164E63), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF164E63),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF164E63).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          trailing ??
              Switch(
                value: value,
                onChanged: (v) {},
                activeColor: const Color(0xFF0891B2),
              ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 68,
      color: const Color(0xFF164E63).withOpacity(0.1),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withOpacity(0.1),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
