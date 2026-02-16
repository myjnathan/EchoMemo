import 'package:flutter/material.dart';
import 'home_screen_new.dart';
import 'memos_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';
import 'recorder_screen_new.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenNew(),
    const MemosScreen(),
    const InsightsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecordingSheet(context),
        backgroundColor: const Color(0xFF0891B2),
        child: const Icon(Icons.mic, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white.withOpacity(0.9),
        elevation: 0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, '首页'),
              _buildNavItem(1, Icons.article_outlined, Icons.article, '笔记'),
              const SizedBox(width: 48),
              _buildNavItem(2, Icons.analytics_outlined, Icons.analytics, '洞察'),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings, '设置'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF0891B2) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF0891B2) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordingSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false, // 禁止点击外部关闭
      enableDrag: false, // 禁止拖动关闭
      builder: (context) => const RecorderScreenNew(),
    );

    // 如果成功上传录音，触发首页刷新
    if (result == true && mounted) {
      // 通过setState触发首页重建，从而刷新数据
      setState(() {});
    }
  }
}
