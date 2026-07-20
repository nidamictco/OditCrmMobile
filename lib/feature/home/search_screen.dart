import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/core/utils/launch_phone_and_whatsapp.dart';
import 'package:odit_crm_mobile/core/utils/lead_name_resolver.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/presentation/lead_details_screen.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_card.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';
import 'package:sizer/sizer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _lastSearchQuery = ''; // Track the last executed search query
  List<ValueNotifier<bool>> _closeNotifiers = [];
  final Set<String> _expandedLeadIds = {};

  final ScrollController _scrollController = ScrollController();
  int _visibleCount = 0;
  static const int _pageSize = 10;
  bool _isLoadingMore = false;
  int _lastResultsLength = -1;
  String _paginationQueryKey = '';

  void _onToggleExpand(String id) {
    setState(() {
      if (_expandedLeadIds.contains(id)) {
        _expandedLeadIds.remove(id);
      } else {
        _expandedLeadIds.add(id);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // DO NOT fetch leads on screen init
    // DO NOT set up any search listeners
    // Wait for user to manually trigger search via button
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchTextChanged);

     final cubit = context.read<AddLeadCubit>();
  if (cubit.state.leads.isEmpty) {
    cubit.fetchLeads();
  }
  }

  void _onSearchTextChanged() {
  if (_searchController.text.trim().isEmpty && _lastSearchQuery.isNotEmpty) {
    setState(() {
      _lastSearchQuery = '';
      _expandedLeadIds.clear();
    });
  }
}

 @override
void dispose() {
  _searchController.removeListener(_onSearchTextChanged);
  _searchController.dispose();

  for (final n in _closeNotifiers) {
    n.dispose();
  }

  _scrollController.removeListener(_onScroll);
  _scrollController.dispose();
  super.dispose();
}

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final nearBottom = position.pixels >= (position.maxScrollExtent - 200);

    if (nearBottom) {
      _maybeLoadMore();
    }
  }

  Future<void> _maybeLoadMore() async {
    // final totalResults = context.read<AddLeadCubit>().state.leads.length;
// AFTER
final totalResults = _sourceList(context.read<AddLeadCubit>().state).length;

    // Nothing more to show, or already loading, or no search performed yet.
    if (_isLoadingMore || _visibleCount >= totalResults) {
      return;
    }

    setState(() => _isLoadingMore = true);

    // Simulate the async boundary so the CircularProgressIndicator has a
    // chance to render smoothly (also matches where a real Firestore
    // pagination call would await a network fetch).
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      final next = _visibleCount + _pageSize;
      _visibleCount = next > totalResults ? totalResults : next;
      _isLoadingMore = false;
    });
  }

  bool get _isSearchActive => _lastSearchQuery.trim().isNotEmpty;
  List<AddLeadModel> _sourceList(AddLeadState state) {
  return _isSearchActive ? state.searchResults : state.leads;
}

  void _resetPagination(int totalResults) {
    _visibleCount = totalResults < _pageSize ? totalResults : _pageSize;
    _isLoadingMore = false;
  }

  void _syncCloseNotifiers(int length) {
    if (_closeNotifiers.length != length) {
      for (final n in _closeNotifiers) {
        n.dispose();
      }
      _closeNotifiers = List.generate(length, (_) => ValueNotifier(false));
    }
  }

  void _onSwipeOpen(int index) {
    for (int i = 0; i < _closeNotifiers.length; i++) {
      if (i != index) {
        _closeNotifiers[i].value = true;
        Future.microtask(() => _closeNotifiers[i].value = false);
      }
    }
  }

  /// Execute search when user taps the Search button
  void _executeSearch(String query) {
    if (query.trim().isEmpty) {
      // Show error message if search text is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a name or phone number'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update the last search query
    setState(() {
      _lastSearchQuery = query;
    });

    // Trigger search in cubit
    context.read<AddLeadCubit>().searchLeads(query);

    log('Search executed for: $query');
  }

  String _getFollowUpText(AddLeadModel lead) {
    if (lead.followUp == null || lead.followUp!.isEmpty) return '--';
    DateTime? latestDate;
    for (final f in lead.followUp!) {
      if (latestDate == null || f.nextFollowUpDate.isAfter(latestDate)) {
        latestDate = f.nextFollowUpDate;
      }
    }
    if (latestDate == null) return '--';
    return DateFormat('dd-MM-yyyy').format(latestDate);
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '--';
    return DateFormat('dd-MM-yyyy').format(dt);
  }

  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        for (final n in _closeNotifiers) {
          n.value = true;
          Future.microtask(() => n.value = false);
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: AppColors.bottomNavBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocBuilder<AddLeadCubit, AddLeadState>(
          builder: (context, state) {
            // Show loading state
            if (state.listStatus == LeadListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show error state
            if (state.listStatus == LeadListStatus.failure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    state.listError ?? 'Failed to search leads',
                    style: TextStyle(color: Colors.red, fontSize: 16.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // final searchResults = state.searchResults;

            // if (_paginationQueryKey != _lastSearchQuery ||
            //     _lastResultsLength != searchResults.length) {
            //   _paginationQueryKey = _lastSearchQuery;
            //   _lastResultsLength = searchResults.length;
            //   _resetPagination(searchResults.length);
            // }
            // final safeVisibleCount = _visibleCount.clamp(
            //   0,
            //   searchResults.length,
            // );
            // final visibleResults = searchResults.sublist(0, safeVisibleCount);

            // _syncCloseNotifiers(visibleResults.length);
            // final hasMore = safeVisibleCount < searchResults.length;

// AFTER
final displayedLeads = _sourceList(state);

final categoryNameById = {for (final c in state.categories) c.id: c.name};
final stageNameById = {for (final s in state.stages) s.id: s.name};
final sourceNameById = {for (final s in state.sources) s.id: s.name};

if (_paginationQueryKey != _lastSearchQuery ||
    _lastResultsLength != displayedLeads.length) {
  _paginationQueryKey = _lastSearchQuery;
  _lastResultsLength = displayedLeads.length;
  _resetPagination(displayedLeads.length);
}
final safeVisibleCount = _visibleCount.clamp(0, displayedLeads.length);
final visibleResults = displayedLeads.sublist(0, safeVisibleCount);

_syncCloseNotifiers(visibleResults.length);
final hasMore = safeVisibleCount < displayedLeads.length;

            return SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar with manual search button
                  SearchBarWidget(
                    controller: _searchController,
                    onSearchPressed: () {
                      _executeSearch(_searchController.text);
                    },
                  ),
                  SizedBox(height: 2.h),

                  LeadHeaderCard(
                    title: 'Leads',
                    // subtitle: _lastSearchQuery.isEmpty
                    //     ? 'Search results will appear here'
                    //     : '${searchResults.length} records found',
                     subtitle: !_isSearchActive
      ? '${state.leads.length} total leads'
      : (displayedLeads.isEmpty
          ? 'No matching leads found'
          : '${displayedLeads.length} matching records found'),
                  ),
                  SizedBox(height: 2.h),

                  // if (_lastSearchQuery.isEmpty) ...[
                  //   // Initial empty state - no search performed yet
                  //   SizedBox(height: 8.h),
                  //   Center(
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(
                  //           Icons.search_rounded,
                  //           size: 18.w,
                  //           color: Colors.grey.shade400,
                  //         ),
                  //         SizedBox(height: 2.h),
                  //         Text(
                  //           'Search for leads',
                  //           style: TextStyle(
                  //             fontSize: 16.sp,
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.grey.shade700,
                  //           ),
                  //         ),
                  //         SizedBox(height: 1.h),
                  //         Padding(
                  //           padding: EdgeInsets.symmetric(horizontal: 8.w),
                  //           child: Text(
                  //             'Enter a customer name or phone number and tap Search',
                  //             style: TextStyle(
                  //               fontSize: 14.sp,
                  //               color: Colors.grey.shade500,
                  //             ),
                  //             textAlign: TextAlign.center,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ] else
                  
                   if (displayedLeads.isEmpty) ...[
                    // No results found after search
                    SizedBox(height: 8.h),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 18.w,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                             _isSearchActive ? 'No leads found' : 'No leads available',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              _isSearchActive
                ? 'Try searching with another name or phone number'
                : 'Leads you add will appear here',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Search results - display matching leads
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visibleResults.length,
                      separatorBuilder: (_, __) => SizedBox(height: 2.h),
                      itemBuilder: (_, index) {
                        final lead = visibleResults[index];

  final resolvedCategoryName = categoryNameById[lead.leadCategoryId] ??
      (lead.leadCategory.isEmpty ? 'Uncategorized' : lead.leadCategory);
  final resolvedStageRaw = stageNameById[lead.leadStageId] ?? lead.leadStage;
  final resolvedSourceName = sourceNameById[lead.leadSourceId] ??
      (lead.leadSource.isEmpty ? '' : lead.leadSource);

                        final leadData = LeadData(
                          id: lead.id ?? '',
                          name: lead.clientName,
                          phone: lead.contactNumber,
                          assignedTo: lead.assignedStaff,
                          category: resolvedCategoryName,
                          categoryId: lead.leadCategoryId,
                          subCategory: lead.leadSubCategory,
                          subCategoryId: lead.leadSubCategoryId,
                          status: lead.leadStage,
                           statusName: humanizeStageName(resolvedStageRaw),
                          statusId: lead.leadStageId,
                          notificationCount: 0,
                          source:resolvedSourceName,
                          sourceId: lead.leadSourceId,
                          priority: lead.priority,
                          createdAt: lead.createdAt,
                          isExpanded: _expandedLeadIds.contains(lead.id ?? ''),
                        );

                        return LeadCard(
                          key: ValueKey(lead.id ?? index),
                          data: leadData,
                          closeNotifier: _closeNotifiers[index],
                          onSwipeOpen: () => _onSwipeOpen(index),
                          onToggleExpand: () => _onToggleExpand(lead.id ?? ''),
                          onCall: () =>
                              launchPhoneCall(context, lead.contactNumber),
                          onMessage: () =>
                              launchWhatsApp(context, lead.contactNumber),
                        );
                      },
                    ),
                    if (_isLoadingMore)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (hasMore)
                      // Small invisible-ish spacer area so the scroll
                      // listener has a bit of room to trigger before the
                      // absolute bottom (keeps scrolling smooth per
                      // performance requirements).
                      SizedBox(height: 4.h),
                  ],
                  SizedBox(height: 2.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearchPressed;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 3.w),
          Icon(Icons.search, color: AppColors.bottomNavBlue, size: 5.5.w),
          SizedBox(width: 2.w),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 14.5.sp,
                color: const Color(0xFF333333),
              ),
              decoration: InputDecoration(
                hintText: 'Search leads or customer...',
                hintStyle: TextStyle(
                  fontSize: 14.5.sp,
                  color: const Color(0xFFAAAAAA),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              // Allow user to search by pressing Enter key
              onSubmitted: (_) {
                onSearchPressed();
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          SizedBox(width: 2.w),
          Padding(
            padding: EdgeInsets.only(right: 2.5.w),
            child: GestureDetector(
              onTap: onSearchPressed,
              child: Container(
                width: 10.w,
                height: 10.w,
                padding: const EdgeInsets.all(0.5),
                decoration: BoxDecoration(
                  color: AppColors.bottomNavBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.search, color: Colors.white, size: 5.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeadHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const LeadHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 11.w,
            height: 11.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              color: const Color(0xFF2ECC71),
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF222222),
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          // Icon(
          //   Icons.keyboard_arrow_up_rounded,
          //   color: const Color(0xFF666666),
          //   size: 6.w,
          // ),
        ],
      ),
    );
  }
}

double get _kSearchActionPanelWidth => 28.w;
const double _kSearchSnapThreshold = 0.35;

class SearchLeadCard extends StatefulWidget {
  final String id;
  final String name;
  final String phone;
  final String category;
  final String assignedTo;
  final String status;
  final String nextFollowUp;
  final String lastCall;
  final String leadSource;
  final String priority;
  final VoidCallback? onSwipeOpen;
  final ValueNotifier<bool>? closeNotifier;

  const SearchLeadCard({
    super.key,
    required this.id,
    required this.name,
    required this.phone,
    required this.category,
    required this.assignedTo,
    required this.status,
    required this.nextFollowUp,
    required this.lastCall,
    required this.leadSource,
    required this.priority,
    this.onSwipeOpen,
    this.closeNotifier,
  });

  @override
  State<SearchLeadCard> createState() => _SearchLeadCardState();
}

class _SearchLeadCardState extends State<SearchLeadCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnim;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    
    _slideAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    widget.closeNotifier?.addListener(_onCloseRequested);
  }

  @override
  void didUpdateWidget(SearchLeadCard old) {
    super.didUpdateWidget(old);
    if (old.closeNotifier != widget.closeNotifier) {
      old.closeNotifier?.removeListener(_onCloseRequested);
      widget.closeNotifier?.addListener(_onCloseRequested);
    }
  }

  void _onCloseRequested() {
    if (widget.closeNotifier?.value == true && _isOpen) {
      _close();
    }
  }

  void _open() {
    setState(() => _isOpen = true);
    _controller.animateTo(1.0);
    widget.onSwipeOpen?.call();
  }

  void _close() {
    _controller.animateTo(0.0).then((_) {
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    if (d.primaryDelta == null) return;
    final delta = -d.primaryDelta! / _kSearchActionPanelWidth;
    _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    if (velocity < -300) {
      _open();
    } else if (velocity > 300) {
      _close();
    } else if (_controller.value >= _kSearchSnapThreshold) {
      _open();
    } else {
      _close();
    }
  }

  @override
  void dispose() {
    widget.closeNotifier?.removeListener(_onCloseRequested);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isOpen ? _close : null,
      behavior: HitTestBehavior.translucent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: _slideAnim,
          builder: (context, _) {
            final slideOffset = _slideAnim.value * _kSearchActionPanelWidth;

            return Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: _kSearchActionPanelWidth,
                      child: GestureDetector(
                        onTap: () {
                          _close();
                          LeadDetailsScreen.show(
                            context,
                            lead: AddLeadModel(
                              id: widget.id,
                              clientName: widget.name,
                              leadStage: widget.status,
                              leadCategory: widget.category,
                              contactNumber: widget.phone,
                              assignedStaff: widget.assignedTo,
                              createdAt: DateTime.now(),
                              leadSource: widget.leadSource,
                              priority: widget.priority,
                              contactDialCode: '',
                              assignedStaffId: '',
                              createdBy: '',
                              createdById: '',
                            ),
                            showFollowupForm: true,
                          );
                        },
                        child: Container(
                          color: const Color(0xFF2196F3),
                          child: Center(
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 6.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-slideOffset, 0),
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    onTap: () {
                      if (_isOpen) {
                        _close();
                      }
                    },
                    child: _SearchLeadCardBody(
                      name: widget.name,
                      phone: widget.phone,
                      category: widget.category,
                      assignedTo: widget.assignedTo,
                      status: widget.status,
                      nextFollowUp: widget.nextFollowUp,
                      lastCall: widget.lastCall,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchLeadCardBody extends StatelessWidget {
  final String name;
  final String phone;
  final String category;
  final String assignedTo;
  final String status;
  final String nextFollowUp;
  final String lastCall;

  const _SearchLeadCardBody({
    required this.name,
    required this.phone,
    required this.category,
    required this.assignedTo,
    required this.status,
    required this.nextFollowUp,
    required this.lastCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.5.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 6.5.w,
                      backgroundColor: const Color(0xFFDDDDDD),
                      child: Icon(Icons.person, size: 7.w, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 2.8.w,
                        height: 2.8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 4.w,
                            color: const Color(0xFF888888),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 15.5.sp,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: category,
                  textColor: const Color(0xFFDC2626),
                  backgroundColor: const Color(0xFFFEE2E2),
                  borderColor: Colors.transparent,
                  showDot: false,
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: const Color(0xFFF0F0F0)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 5.w,
                        color: const Color(0xFF666666),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        assignedTo,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                StatusChip(
                  label: status,
                  textColor: const Color(0xFFE6A817),
                  backgroundColor: const Color(0xFFFFF8E6),
                  borderColor: const Color(0xFFE6A817),
                  showDot: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: InfoBox(nextFollowUp: nextFollowUp, lastCall: lastCall),
          ),
          SizedBox(height: 1.5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: GestureDetector(
              onTap: () {
                launchPhoneCall(context, phone);
              },
              child: SizedBox(
                height: 5.5.h,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3DAA5C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 5.w,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Contact Now',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String nextFollowUp;
  final String lastCall;

  const InfoBox({
    super.key,
    required this.nextFollowUp,
    required this.lastCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT FOLLOW-UP',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAAAAA),
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      nextFollowUp,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2F80ED),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            VerticalDivider(
              thickness: 1,
              color: const Color(0xFFDDDDDD),
              width: 1,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LAST CALL',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAAAAA),
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      lastCall,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool showDot;

  const StatusChip({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 1.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
