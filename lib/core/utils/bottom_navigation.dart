import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/core/theme/assets_resources.dart';
import 'package:odit_crm_mobile/feature/home/home_screen.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/lead_management.dart';
import 'package:odit_crm_mobile/feature/menu/menu_drawer.dart';

class CustomBottomNavScreen extends StatefulWidget {
  final int index;
  const CustomBottomNavScreen({super.key, this.index = 0});

  @override
  State<CustomBottomNavScreen> createState() => _CustomBottomNavScreenState();
}

class _CustomBottomNavScreenState extends State<CustomBottomNavScreen> {
  late int selectedIndex;

  // 👇 Add this key — it lets us open the drawer programmatically
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const int _homeIndex = 0;
  static const int _dashboardIndex = 1;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.index;
  }

  // Only 2 real pages now — menu tap opens the drawer instead
  final List<Widget> pages = const [HomeScreen(), LeadManagmentScreen()];

  void onTap(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 👈 attach the key
      endDrawer: const OxdoDrawer(), // 👈 opens from the RIGHT side
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // ── Page area ──────────────────────────────────────────────────
          IndexedStack(index: selectedIndex, children: pages),

          // ── Bottom Navigation Bar ──────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              decoration: const BoxDecoration(
                color: AppColors.bottomNavBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Home tab
                  _navItem(Icons.home, _homeIndex),

                  // Gap for the floating center button
                  const SizedBox(width: 70),

                  // Menu icon → opens the drawer
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.menu, size: 28, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Center Floating Dashboard Button ──────────────────────────
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: () => onTap(_dashboardIndex),
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: AppColors.bottomNavBlue,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Image.asset(
                  AssetResources.dashboard,
                  fit: BoxFit.cover,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
