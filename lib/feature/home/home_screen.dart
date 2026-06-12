import 'dart:async';
import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/core/theme/assets_resources.dart';
import 'package:odit_crm_mobile/core/utils/bottom_navigation.dart';
import 'package:sizer/sizer.dart';
import 'package:odit_crm_mobile/core/utils/app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: CommonAppBar(
        companyName: 'OXDO TECHNOLOGIES PVT LTD',
        role: 'COMPANY ADMIN',
        avatarImagePath: null,
        onAvatarTap: () {},
        onNotificationTap: () {},
        onMoreTap: () {},
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BannerCarousel(),
            SizedBox(height: 1.6.h),
            _FeatureGrid(),
          ],
        ),
      ),
    );
  }
}

// ─── Banner Carousel ─────────────────────────────────────────────────────────

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  static const List<String> _banners = [
    'assets/ad/ad1.png',
    'assets/ad/ad2.png',
  ];

  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_currentPage + 1) % _banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              3.5.w,
            ), // matches card radius in list screen
            child: PageView.builder(
              controller: _controller,
              itemCount: _banners.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) =>
                  Image.asset(_banners[i], fit: BoxFit.cover),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              width: _currentPage == i
                  ? 5.w
                  : 2.w, // matches list screen dot scale
              height: 0.8.h,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? const Color(0xFF2A7FFF)
                    : const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(0.4.h),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 2.5.h,
        ), // same gap rhythm as list screen SizedBox(height: 2.5.h)
      ],
    );
  }
}

// ─── Feature Grid ─────────────────────────────────────────────────────────────

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _FeatureItem(
        label: 'LEAD\nMANAGEMENT',
        assetsPath: AssetResources.stateMngmnt,
        iconBgColor: Color(0xFFE8F4FD),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomBottomNavScreen(index: 1),
            ),
          );
        },
      ),
      _FeatureItem(
        label: 'STAFF\nMANAGEMENT',
        assetsPath: AssetResources.staffMngmnt,
        iconBgColor: Color(0xFFF0EAFF),
        onTap: () {},
      ),
      _FeatureItem(
        label: 'REPORTS',
        assetsPath: AssetResources.report,
        iconBgColor: Color(0xFFFFF3E0),
        onTap: () {},
      ),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 1.5.w,
                ), // list screen uses 1.5.w gaps
                child: _FeatureCard(item: item),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  const _FeatureCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        2.5.w,
      ), // matches ActionButton radius in list screen
      child: GestureDetector(
        onTap: item.onTap,
        child: Container(
          height: 16.h,
          padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 2.5.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2.5.w),
            border: Border.all(
              // color: const Color(0xFF4CAF50),
              color: AppColors.bottomNavBlue.withOpacity(0.4),
              width: 1, // matches list screen border width
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.09,
                ), // same opacity as SectionHeader
                blurRadius: 1,
                offset: const Offset(5, 7),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.w, // matches status card icon container width
                // height: 4.8.h, // matches status card icon container height
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(item.assetsPath, fit: BoxFit.contain),
              ),
              SizedBox(height: 1.h), // same as StatusCard icon→label gap
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                  height: 1.4,
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _FeatureItem {
  final String label;
  final String assetsPath;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.label,
    required this.assetsPath,
    required this.iconBgColor,
    required this.onTap,
  });
}
