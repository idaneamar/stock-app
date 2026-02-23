import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/dashboard/dashboard_screen.dart';
import 'package:stock_app/src/features/excel/all_excel_screen.dart';
import 'package:stock_app/src/features/home/home_screen.dart';
import 'package:stock_app/src/features/main_container/main_container_controller.dart';
import 'package:stock_app/src/features/programs/programs_screen.dart';
import 'package:stock_app/src/features/settings/settings_screen.dart';
import 'package:stock_app/src/features/strategies/strategies_screen.dart';
import 'package:stock_app/src/features/trades/closed_trades_screen.dart';
import 'package:stock_app/src/features/trades/full_active_trades_screen.dart';
import 'package:stock_app/src/features/trades/open_trades_screen.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/controllers/trading_mode_controller.dart';
import 'package:stock_app/src/utils/widget/drawer/reset_all_action.dart';

// ---------------------------------------------------------------------------
// Nav item descriptor
// ---------------------------------------------------------------------------

class _NavItem {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const List<_NavItem> _stocksNavItems = [
  _NavItem(
    index: ScreenIndex.dashboard,
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    label: 'Dashboard',
  ),
  _NavItem(
    index: ScreenIndex.scans,
    icon: Icons.search_outlined,
    activeIcon: Icons.search_rounded,
    label: 'Scans',
  ),
  _NavItem(
    index: ScreenIndex.programs,
    icon: Icons.layers_outlined,
    activeIcon: Icons.layers_rounded,
    label: 'Programs',
  ),
  _NavItem(
    index: ScreenIndex.strategies,
    icon: Icons.category_outlined,
    activeIcon: Icons.category_rounded,
    label: 'Strategies',
  ),
  _NavItem(
    index: ScreenIndex.openTrades,
    icon: Icons.trending_up_outlined,
    activeIcon: Icons.trending_up,
    label: 'Open Trades',
  ),
  _NavItem(
    index: ScreenIndex.closedTrades,
    icon: Icons.trending_down_outlined,
    activeIcon: Icons.trending_down,
    label: 'Closed Trades',
  ),
  _NavItem(
    index: ScreenIndex.excel,
    icon: Icons.table_chart_outlined,
    activeIcon: Icons.table_chart,
    label: 'Excel Files',
  ),
  _NavItem(
    index: ScreenIndex.recommendations,
    icon: Icons.analytics_outlined,
    activeIcon: Icons.analytics,
    label: 'Recommendations',
  ),
];

const List<_NavItem> _optionsNavItems = [
  _NavItem(
    index: ScreenIndex.dashboard,
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    label: 'Dashboard',
  ),
];

const _NavItem _settingsNavItem = _NavItem(
  index: ScreenIndex.settings,
  icon: Icons.settings_outlined,
  activeIcon: Icons.settings,
  label: 'Settings',
);

// Breakpoint below which the sidebar becomes a Drawer
const double _mobileBreakpoint = 600.0;
// Sidebar width
const double _sidebarWidth = 220.0;
// Dark sidebar background
const Color _sidebarBg = Color(0xFF1A1F36);
const Color _sidebarActiveBg = Color(0xFF2D3458);
const Color _sidebarTextColor = Color(0xFFB0B7D3);
const Color _sidebarActiveText = Colors.white;
const Color _sidebarAccent = Color(0xFF4F78FF);

// ---------------------------------------------------------------------------
// MainContainerScreen
// ---------------------------------------------------------------------------

class MainContainerScreen extends StatefulWidget {
  final int initialIndex;

  const MainContainerScreen({super.key, this.initialIndex = 0});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  late final MainContainerController controller;
  late final List<Widget?> _screens;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      MainContainerController(),
      tag: 'main_container',
      permanent: true,
    );

    // Also register without tag for backward-compat
    if (!Get.isRegistered<MainContainerController>()) {
      Get.put(controller, permanent: true);
    }

    // Pre-build all screen slots (null = not yet loaded → SizedBox.shrink)
    _screens = List.filled(ScreenIndex.total, null);

    // Seed the screens that are loaded on init
    _loadScreen(ScreenIndex.dashboard);

    if (widget.initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.changeScreen(widget.initialIndex);
      });
    }
  }

  void _loadScreen(int index) {
    if (_screens[index] != null) return;
    _screens[index] = _buildScreen(index);
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case ScreenIndex.dashboard:
        return const DashboardScreen();
      case ScreenIndex.scans:
        return const HomeScreen();
      case ScreenIndex.programs:
        return const ProgramsScreen();
      case ScreenIndex.strategies:
        return const StrategiesScreen();
      case ScreenIndex.openTrades:
        return const OpenTradesScreen();
      case ScreenIndex.closedTrades:
        return const ClosedTradesScreen();
      case ScreenIndex.excel:
        return AllExcelScreen();
      case ScreenIndex.recommendations:
        return FullActiveTradesScreen();
      case ScreenIndex.settings:
        return SettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  void _onNavTap(int index) {
    if (_screens[index] == null) {
      setState(() => _loadScreen(index));
    }
    controller.changeScreen(index);
  }

  void _onMobileNavTap(int index) {
    _onNavTap(index);
    _scaffoldKey.currentState?.closeDrawer();
  }

  Widget _buildIndexedStack() {
    return Obx(() {
      final idx = controller.currentIndex.value;
      return IndexedStack(
        index: idx,
        children: _screens.map((s) => s ?? const SizedBox.shrink()).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _mobileBreakpoint;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (controller.currentIndex.value != 0) {
          controller.changeScreen(0);
        }
      },
      child:
          isMobile
              ? _buildMobileScaffold(context)
              : _buildDesktopScaffold(context),
    );
  }

  // ── Mobile: AppBar + Drawer ───────────────────────────────────────────────

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.grey50,
      appBar: _MobileAppBar(controller: controller, scaffoldKey: _scaffoldKey),
      drawer: Drawer(
        width: _sidebarWidth,
        backgroundColor: _sidebarBg,
        child: _AppSidebar(controller: controller, onNavTap: _onMobileNavTap),
      ),
      body: _buildIndexedStack(),
    );
  }

  // ── Desktop/tablet: permanent sidebar ────────────────────────────────────

  Widget _buildDesktopScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Row(
        children: [
          _AppSidebar(controller: controller, onNavTap: _onNavTap),
          Expanded(child: _buildIndexedStack()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile AppBar
// ---------------------------------------------------------------------------

class _MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final MainContainerController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _MobileAppBar({required this.controller, required this.scaffoldKey});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String _labelForIndex(int idx) {
    const all = [..._stocksNavItems, _settingsNavItem];
    for (final item in all) {
      if (item.index == idx) return item.label;
    }
    return 'StockApp';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = controller.currentIndex.value;
      return AppBar(
        backgroundColor: _sidebarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _labelForIndex(idx),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: UIConstants.fontXXL,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Sidebar widget
// ---------------------------------------------------------------------------

class _AppSidebar extends StatelessWidget {
  final MainContainerController controller;
  final void Function(int) onNavTap;

  const _AppSidebar({required this.controller, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _sidebarWidth,
      color: _sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App logo / name
          _buildLogo(),
          // Trading mode toggle
          _buildModeToggle(),
          const SizedBox(height: UIConstants.spacingL),
          // Nav items
          Expanded(child: _buildNavList(context)),
          // Divider + bottom items
          const Divider(color: Colors.white12, height: 1),
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingXXL),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _sidebarAccent,
              borderRadius: BorderRadius.circular(UIConstants.radiusS),
            ),
            child: const Icon(
              Icons.candlestick_chart_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: UIConstants.spacingL),
          const Text(
            'StockApp',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: UIConstants.fontXL,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    final modeCtrl = Get.find<TradingModeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingL,
        vertical: UIConstants.paddingS,
      ),
      child: Obx(() {
        final isStocks = modeCtrl.isStocks;
        return Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
          ),
          child: Row(
            children: [
              _ModeToggleBtn(
                label: 'Stocks',
                isActive: isStocks,
                onTap: () {
                  modeCtrl.setMode(TradingMode.stocks);
                  onNavTap(ScreenIndex.dashboard);
                },
              ),
              _ModeToggleBtn(
                label: 'Options',
                isActive: !isStocks,
                onTap: () {
                  modeCtrl.setMode(TradingMode.options);
                  onNavTap(ScreenIndex.dashboard);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNavList(BuildContext context) {
    final modeCtrl = Get.find<TradingModeController>();
    return Obx(() {
      final items = modeCtrl.isStocks ? _stocksNavItems : _optionsNavItems;
      return ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingS,
          vertical: UIConstants.paddingS,
        ),
        children: [
          ...items.map(
            (item) => _NavItemTile(
              item: item,
              controller: controller,
              onTap: () => onNavTap(item.index),
            ),
          ),
          if (modeCtrl.isOptions)
            Padding(
              padding: const EdgeInsets.all(UIConstants.paddingXXL),
              child: Column(
                children: [
                  const Icon(
                    Icons.construction_rounded,
                    color: _sidebarTextColor,
                    size: 32,
                  ),
                  const SizedBox(height: UIConstants.spacingL),
                  const Text(
                    'Options trading\ncoming soon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _sidebarTextColor,
                      fontSize: UIConstants.fontL,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingS,
        vertical: UIConstants.paddingS,
      ),
      child: Column(
        children: [
          // Reset all data
          _SidebarActionTile(
            icon: Icons.delete_sweep_outlined,
            label: 'Reset All Data',
            color: AppColors.error.withValues(alpha: 0.8),
            onTap: () => ResetAllAction.show(context),
          ),
          const SizedBox(height: UIConstants.spacingS),
          // Settings
          _NavItemTile(
            item: _settingsNavItem,
            controller: controller,
            onTap: () => onNavTap(_settingsNavItem.index),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mode toggle button
// ---------------------------------------------------------------------------

class _ModeToggleBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeToggleBtn({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: UIConstants.animationFast,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? _sidebarAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : _sidebarTextColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: UIConstants.fontM,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nav item tile
// ---------------------------------------------------------------------------

class _NavItemTile extends StatelessWidget {
  final _NavItem item;
  final MainContainerController controller;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.item,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.currentIndex.value == item.index;
      return AnimatedContainer(
        duration: UIConstants.animationFast,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? _sidebarActiveBg : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          border:
              isActive
                  ? Border(left: BorderSide(color: _sidebarAccent, width: 3))
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
            onTap: onTap,
            hoverColor: Colors.white.withValues(alpha: 0.06),
            splashColor: Colors.white.withValues(alpha: 0.1),
            child: Padding(
              padding: EdgeInsets.only(
                left:
                    isActive ? UIConstants.paddingL - 3 : UIConstants.paddingL,
                right: UIConstants.paddingL,
                top: UIConstants.paddingM,
                bottom: UIConstants.paddingM,
              ),
              child: Row(
                children: [
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: UIConstants.iconL,
                    color: isActive ? _sidebarAccent : _sidebarTextColor,
                  ),
                  const SizedBox(width: UIConstants.spacingL),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color:
                            isActive ? _sidebarActiveText : _sidebarTextColor,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                        fontSize: UIConstants.fontL,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Sidebar action tile (non-nav, e.g. Reset all data)
// ---------------------------------------------------------------------------

class _SidebarActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SidebarActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        onTap: onTap,
        hoverColor: Colors.white.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingL,
            vertical: UIConstants.paddingM,
          ),
          child: Row(
            children: [
              Icon(icon, size: UIConstants.iconL, color: color),
              const SizedBox(width: UIConstants.spacingL),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: color, fontSize: UIConstants.fontL),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
