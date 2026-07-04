import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odit_crm_mobile/core/utils/launch_phone_and_whatsapp.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/filtering.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/filter_button.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/lead_report_card.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/report_appbar.dart';
import 'package:sizer/sizer.dart';

class TransferReportScreen extends StatelessWidget {
  const TransferReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddLeadCubit()
        ..initialize()
        ..fetchStaff()
        ..fetchLeads(),
      child: const TransferReportContent(),
    );
  }
}

class TransferReportContent extends StatefulWidget {
  const TransferReportContent({super.key});

  @override
  State<TransferReportContent> createState() => _TransferReportContentState();
}

class _TransferReportContentState extends State<TransferReportContent> {
  bool _sortByNewest = true;
  FilterResult? _appliedFilters;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  // ===================== PAGINATION ADDITIONS START =====================
  // Controller attached directly to the ListView.separated below (there is
  // no outer SingleChildScrollView on this screen — the ListView itself is
  // the scrollable), so scroll-to-bottom detection is accurate here.
  final ScrollController _scrollController = ScrollController();

  // Number of items from the final filtered/sorted/searched
  // `transferLeads` list currently rendered. UI-side windowing only.
  int _visibleCount = 0;

  // Batch size per requirements.
  static const int _pageSize = 10;

  // Prevents duplicate concurrent load-more calls.
  bool _isLoadingMore = false;

  // Signature of everything that affects the final `transferLeads` list.
  // When this changes between builds, we know the matching set changed
  // (new filter, new sort direction, new search text, or a data refresh)
  // and pagination must reset to page 1 (requirement #11).
  String _lastFilterSignature = '';
  // ====================== PAGINATION ADDITIONS END =======================

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    // ---- PAGINATION: listen for scroll-to-bottom ----
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    // ---- PAGINATION: clean up listener + controller ----
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ===================== PAGINATION METHODS START =====================

  /// Fires on every scroll event of the transfer-leads ListView.
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final nearBottom = position.pixels >= (position.maxScrollExtent - 200);

    if (nearBottom) {
      _maybeLoadMore();
    }
  }

  /// Reveals the next `_pageSize` items out of the already-computed,
  /// already-filtered/sorted `total` count (passed in from build via the
  /// closure over `transferLeads.length` at call time — see usage below).
  ///
  /// NOTE: seam for future Firestore-side pagination — swap the body for
  /// something like `context.read<AddLeadCubit>().fetchNextLeadsPage()`
  /// and await the real result instead of widening the local window.
  Future<void> _maybeLoadMore() async {
    final total = context
        .read<AddLeadCubit>()
        .state
        .leads
        .where((lead) => lead.leadStage.toUpperCase() == 'TRANSFERRED')
        .length;

    if (_isLoadingMore || _visibleCount >= total) {
      return;
    }

    setState(() => _isLoadingMore = true);

    // Simulated async boundary — mirrors where a real paginated fetch
    // would await network I/O.
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      final next = _visibleCount + _pageSize;
      _visibleCount = next > total ? total : next;
      _isLoadingMore = false;
    });
  }

  /// Resets the visible window back to the first page of `total` items.
  void _resetPagination(int total) {
    _visibleCount = total < _pageSize ? total : _pageSize;
    _isLoadingMore = false;
  }

  // ====================== PAGINATION METHODS END =======================

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }

  List<AddLeadModel> _applyFilters(List<AddLeadModel> leads) {
    if (_appliedFilters == null) {
      debugPrint(
        '[Filter Debug] No filters applied. Total leads count: ${leads.length}',
      );
      return leads;
    }

    final String fromStr = _appliedFilters!.fromDate;
    final String toStr = _appliedFilters!.toDate;
    debugPrint('[Filter Debug] Selected From Date: $fromStr');
    debugPrint('[Filter Debug] Selected To Date: $toStr');

    final start = _parseDate(fromStr);
    final end = _parseDate(toStr);

    final startOfDay = start != null
        ? DateTime(start.year, start.month, start.day, 0, 0, 0)
        : null;
    final endOfDay = end != null
        ? DateTime(end.year, end.month, end.day, 23, 59, 59)
        : null;

    final filteredList = leads.where((lead) {
      // 1. Date Filter (createdAt)
      DateTime? createdAt;
      final dynamic raw = lead.createdAt;
      if (raw != null) {
        if (raw is DateTime) {
          createdAt = raw;
        } else if (raw is Timestamp) {
          createdAt = raw.toDate();
        } else {
          try {
            createdAt = DateTime.parse(raw.toString());
          } catch (_) {}
        }
      }

      debugPrint(
        '[Filter Debug] Lead clientName: ${lead.clientName}, Lead Created Date: $createdAt',
      );

      if (startOfDay != null && endOfDay != null) {
        if (createdAt == null) return false;
        if (createdAt.isBefore(startOfDay) || createdAt.isAfter(endOfDay)) {
          return false;
        }
      }

      // 2. Assigned Staff Filter
      final selectedStaff = _appliedFilters!.selectedItems['Assigned Staff'];
      if (selectedStaff != null && selectedStaff.isNotEmpty) {
        if (!selectedStaff.any(
          (staff) => lead.assignedStaff.toLowerCase() == staff.toLowerCase(),
        )) {
          return false;
        }
      }

      // 3. Category Filter
      final selectedCategory = _appliedFilters!.selectedItems['Category'];
      if (selectedCategory != null && selectedCategory.isNotEmpty) {
        if (!selectedCategory.any(
          (cat) => lead.leadCategory.toLowerCase() == cat.toLowerCase(),
        )) {
          return false;
        }
      }

      // 4. Priority Filter
      final selectedPriority = _appliedFilters!.selectedItems['Priority'];
      if (selectedPriority != null && selectedPriority.isNotEmpty) {
        if (!selectedPriority.any(
          (prio) => lead.priority.toLowerCase() == prio.toLowerCase(),
        )) {
          return false;
        }
      }

      return true;
    }).toList();

    debugPrint('[Filter Debug] Filtered Result Count: ${filteredList.length}');
    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: ReportAppBar(
        title: 'transferLeads',
        actions: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sort_rounded, color: Colors.white, size: 17.sp),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () {
              setState(() {
                _sortByNewest = !_sortByNewest;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    _sortByNewest ? 'Newest' : 'Oldest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Icon(
                    _sortByNewest
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 17.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AddLeadCubit, AddLeadState>(
        builder: (context, state) {
          if (state.listStatus == LeadListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.listStatus == LeadListStatus.failure) {
            return Center(
              child: Text(
                state.listError ?? 'Failed to load leads',
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            );
          }

          // ---- Existing pipeline: stage filter -> custom filters -> search
          // -> sort. UNTOUCHED. `transferLeads` is the final processed
          // list — this defines "total" for pagination and is what the
          // "Total Leads" summary must reflect (requirement #9). ----
          final List<AddLeadModel> rawTransferLeads = state.leads
              .where((lead) => lead.leadStage.toUpperCase() == 'TRANSFERRED')
              .toList();

          List<AddLeadModel> transferLeads = _applyFilters(rawTransferLeads);

          if (_showSearchBar && _searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            transferLeads = transferLeads.where((lead) {
              return lead.clientName.toLowerCase().contains(query) ||
                  lead.contactNumber.contains(query) ||
                  lead.assignedStaff.toLowerCase().contains(query) ||
                  lead.leadCategory.toLowerCase().contains(query);
            }).toList();
          }

          if (_sortByNewest) {
            transferLeads.sort((a, b) {
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return b.createdAt!.compareTo(a.createdAt!);
            });
          } else {
            transferLeads.sort((a, b) {
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return a.createdAt!.compareTo(b.createdAt!);
            });
          }

          // ===================== PAGINATION WINDOWING =====================
          // Signature combines everything that can change the composition
          // of `transferLeads`. Any change resets to page 1 (requirement
          // #11). Length alone isn't reliable enough (two different filter
          // combos could coincidentally match the same count), so we also
          // fold in first/last id.
          final String currentSignature =
              '${_sortByNewest}_${_appliedFilters?.fromDate}_${_appliedFilters?.toDate}_${_searchController.text}_${transferLeads.length}_${transferLeads.isNotEmpty ? transferLeads.first.id : ''}_${transferLeads.isNotEmpty ? transferLeads.last.id : ''}';

          if (_lastFilterSignature != currentSignature) {
            _lastFilterSignature = currentSignature;
            _resetPagination(transferLeads.length);
          }

          // Defensive clamp — guarantees no index-out-of-range regardless
          // of how transferLeads.length shifts between rebuilds.
          final int safeVisibleCount = _visibleCount.clamp(
            0,
            transferLeads.length,
          );

          // Only this sub-list is ever rendered.
          final List<AddLeadModel> visibleTransferLeads = transferLeads.sublist(
            0,
            safeVisibleCount,
          );

          final bool hasMore = safeVisibleCount < transferLeads.length;
          // ==================== END PAGINATION WINDOWING ===================

          return Column(
            children: [
              // Summary Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.swap_horiz_rounded,
                              color: const Color(0xFF2F80ED),
                              size: 17.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              // ---- PAGINATION: unchanged — still the TOTAL
                              // filtered count, not the visible window
                              // (requirement #9). ----
                              'Total Leads : ${transferLeads.length}',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D2433),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    FilterButton(
                      icon: Icons.filter_alt_outlined,
                      onTap: () async {
                        final result = await showFilterBottomSheet(
                          context,
                          initialFilters: _appliedFilters,
                        );
                        if (result != null) {
                          setState(() {
                            if (result.isCleared) {
                              _appliedFilters = null;
                            } else {
                              _appliedFilters = result;
                            }
                          });
                        }
                      },
                    ),
                    SizedBox(width: 2.w),
                    FilterButton(
                      icon: _showSearchBar
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      onTap: () {
                        setState(() {
                          _showSearchBar = !_showSearchBar;
                          if (!_showSearchBar) {
                            _searchController.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _showSearchBar
                    ? Container(
                        height: 6.h,
                        margin: EdgeInsets.only(
                          left: 4.w,
                          right: 4.w,
                          bottom: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search leads...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 1.5.h,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Transferred Lead List
              Expanded(
                child: transferLeads.isEmpty
                    ? Center(
                        child: Text(
                          'No transferred leads found',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      )
                    // ---- PAGINATION: controller attached here since this
                    // ListView is this screen's actual scrollable. ----
                    : ListView.separated(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 4.w,
                          right: 4.w,
                          bottom: MediaQuery.of(context).padding.bottom + 2.h,
                        ),
                        // ---- PAGINATION: +1 extra slot for the trailing
                        // loading indicator, shown only while relevant.
                        // Keeps the exact same widget structure otherwise. ----
                        itemCount:
                            visibleTransferLeads.length +
                            (hasMore || _isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 2.h),
                        itemBuilder: (context, index) {
                          // Trailing indicator slot.
                          if (index >= visibleTransferLeads.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Center(
                                child: _isLoadingMore
                                    ? const CircularProgressIndicator()
                                    : const SizedBox.shrink(),
                              ),
                            );
                          }

                          final lead = visibleTransferLeads[index];
                          return LeadReportCard(
                            key: ValueKey(lead.id ?? index),
                            lead: lead,
                            isTransferReport: true,
                            onCall: () {
                              launchPhoneCall(context, lead.contactNumber);
                            },
                            onWhatsApp: () {
                              launchWhatsApp(
                                context,
                                lead.whatsappNumber.isEmpty
                                    ? lead.contactNumber
                                    : lead.whatsappNumber,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
