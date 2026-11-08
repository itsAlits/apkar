import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'ar_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentTabIndex = 0; // 0: Beranda, 1: Eksplorasi, 2: Pengaturan

  void _onTabSelected(int index) {
    if (index == 2) {
      // Pindai AR: Buka layar AR secara terisolasi agar kamera & suara hanya aktif saat di layar AR
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ARScreen()),
      );
    } else {
      setState(() {
        _currentTabIndex = index > 2 ? index - 1 : index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        onNavigateToExplore: () => setState(() => _currentTabIndex = 1),
        onNavigateToScan: () => _onTabSelected(2),
      ),
      const ExploreScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(index: _currentTabIndex, children: pages),
      bottomNavigationBar: _buildFlatNavigationBar(),
    );
  }

  Widget _buildFlatNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // 1. Beranda (Tab 0)
              Expanded(
                child: _buildNavItem(
                  targetIndex: 0,
                  isSelected: _currentTabIndex == 0,
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                ),
              ),

              // 2. Eksplorasi (Tab 1)
              Expanded(
                child: _buildNavItem(
                  targetIndex: 1,
                  isSelected: _currentTabIndex == 1,
                  icon: Icons.theater_comedy_rounded,
                  label: 'Eksplorasi',
                ),
              ),

              // 3. Pindai AR (Membuka Kamera AR)
              Expanded(
                child: _buildNavItem(
                  targetIndex: 2,
                  isSelected: false,
                  icon: Icons.view_in_ar_rounded,
                  label: 'Pindai AR',
                ),
              ),

              // 4. Pengaturan (Tab 2)
              Expanded(
                child: _buildNavItem(
                  targetIndex: 3,
                  isSelected: _currentTabIndex == 2,
                  icon: Icons.tune_rounded,
                  label: 'Pengaturan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int targetIndex,
    required bool isSelected,
    required IconData icon,
    required String label,
  }) {
    final color = isSelected ? AppTheme.primaryColor : Colors.white38;

    return InkWell(
      onTap: () => _onTabSelected(targetIndex),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 16,
            height: 2,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
