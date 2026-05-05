import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import 'dashboard_screen.dart';
import 'departments_screen.dart';
import 'tasks_screen.dart';
import 'add_task_screen.dart';
import 'project_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DepartmentsScreen(),
    TasksScreen(),
    ProjectInfoScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController,
          curve: Curves.elasticOut,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentCyan.withOpacity(0.45),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ChangeNotifierProvider.value(
                    value:
                        Provider.of<TaskProvider>(context, listen: false),
                    child: const AddTaskScreen(),
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 320),
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard.withOpacity(0.95),
          border: const Border(
            top: BorderSide(color: AppTheme.borderGlow, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          notchMargin: 10,
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'KONTROL',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTabTap(0),
                ),
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'DEPARTMAN',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTabTap(1),
                ),
                const SizedBox(width: 60),
                _NavItem(
                  icon: Icons.task_alt_rounded,
                  label: 'GÖREVLER',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTabTap(2),
                ),
                _NavItem(
                  icon: Icons.terminal_rounded,
                  label: 'VERİLER',
                  isSelected: _currentIndex == 3,
                  onTap: () => _onTabTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glow indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 18 : 0,
              height: isSelected ? 3 : 0,
              margin: EdgeInsets.only(bottom: isSelected ? 4 : 0),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.accentCyan.withOpacity(0.7),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            Icon(
              icon,
              color: isSelected ? AppTheme.accentCyan : AppTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color:
                    isSelected ? AppTheme.accentCyan : AppTheme.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
