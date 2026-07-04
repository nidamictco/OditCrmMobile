import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odit_crm_mobile/core/utils/launch_phone_and_whatsapp.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/filtering.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_card.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/filter_button.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/lead_report_card.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/report_appbar.dart';
import 'package:sizer/sizer.dart';

enum LeadReportType { all, newLead, followup, closed, rejected, transferred }

class LeadReportScreen extends StatelessWidget {
  final LeadReportType reportType;

  const LeadReportScreen({super.key, this.reportType = LeadReportType.all});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddLeadCubit()
        ..initialize()
        ..fetchStaff()
        ..fetchLeads(),
      child: LeadReportContent(reportType: reportType),
    );
  }
}

class LeadReportContent extends StatefulWidget {
  final LeadReportType reportType;
  const LeadReportContent({super.key, required this.reportType});

  @override
  State<LeadReportContent> createState() => _LeadReportContentState();
}

class _LeadReportContentState extends State<LeadReportContent> {
  bool _sortByNewest = true;
  FilterResult? _appliedFilters;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  int _visibleCount = 0;
  static const int _pageSize = 10;
  bool _isLoadingMore = false;

  String _lastFilterSignature = '';

  String get reportTitle {
    switch (widget.reportType) {
      case LeadReportType.newLead:
        return 'New Leads';
      case LeadReportType.followup:
        return 'Followup Leads';
      case LeadReportType.closed:
        return 'Closed Leads';
      case LeadReportType.rejected:
        return 'Rejected Leads';
      case LeadReportType.transferred:
        return 'Transferred Leads';
      default:
        return 'All Leads';
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    final totalResults = context.read<AddLeadCubit>().state.leads.length;

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

  void _resetPagination(int totalResults) {
    _visibleCount = totalResults < _pageSize ? totalResults : _pageSize;
    _isLoadingMore = false;
  }

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
        title: reportTitle,
        actions: [
          // Sort Button
          // Container(
          //   padding: const EdgeInsets.all(8),
          //   decoration: BoxDecoration(
          //     color: Colors.white.withValues(alpha: 0.2),
          //     shape: BoxShape.circle,
          //   ),
          //   child: Icon(Icons.sort_rounded, color: Colors.white, size: 17.sp),
          // ),
          // SizedBox(width: 2.w),
          // Newest Dropdown Button
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

          List<AddLeadModel> leads = [...state.leads];

          switch (widget.reportType) {
            case LeadReportType.newLead:
              leads = leads
                  .where((e) => e.leadStage.toUpperCase() == 'NEW')
                  .toList();
              break;
            case LeadReportType.followup:
              leads = leads
                  .where((e) => e.leadStage.toUpperCase() == 'FOLLOWUP')
                  .toList();
              break;
            case LeadReportType.closed:
              leads = leads
                  .where((e) => e.leadStage.toUpperCase() == 'CLOSED')
                  .toList();
              break;
            case LeadReportType.rejected:
              leads = leads
                  .where((e) => e.leadStage.toUpperCase() == 'REJECTED')
                  .toList();
              break;
            case LeadReportType.transferred:
              leads = leads
                  .where((e) => e.leadStage.toUpperCase() == 'TRANSFERRED')
                  .toList();
              break;
            case LeadReportType.all:
              break;
          }

          leads = _applyFilters(leads);

          if (_showSearchBar && _searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            leads = leads.where((lead) {
              return lead.clientName.toLowerCase().contains(query) ||
                  lead.contactNumber.contains(query) ||
                  lead.assignedStaff.toLowerCase().contains(query) ||
                  lead.leadCategory.toLowerCase().contains(query);
            }).toList();
          }

          if (_sortByNewest) {
            leads.sort((a, b) {
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return b.createdAt!.compareTo(a.createdAt!);
            });
          } else {
            leads.sort((a, b) {
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return a.createdAt!.compareTo(b.createdAt!);
            });
          }

          final String currentSignature =
              '${widget.reportType}_${_sortByNewest}_${_appliedFilters?.fromDate}_${_appliedFilters?.toDate}_${_searchController.text}_${leads.length}_${leads.isNotEmpty ? leads.first.id : ''}_${leads.isNotEmpty ? leads.last.id : ''}';

          if (_lastFilterSignature != currentSignature) {
            _lastFilterSignature = currentSignature;
            _resetPagination(leads.length);
          }

          // Defensive clamp — guarantees no index-out-of-range regardless
          // of how `leads.length` shifts between rebuilds.
          final int safeVisibleCount = _visibleCount.clamp(0, leads.length);

          // Only this sub-list is ever rendered by the ListView below.
          final List<AddLeadModel> visibleLeads = leads.sublist(
            0,
            safeVisibleCount,
          );

          final bool hasMore = safeVisibleCount < leads.length;

          return Column(
            children: [
              // Top Summary Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    // Total Leads Card
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
                              Icons.people_outline_rounded,
                              color: const Color(0xFF2F80ED),
                              size: 17.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Total Leads : ${leads.length}',
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

              // Lead List
              Expanded(
                child: leads.isEmpty
                    ? Center(
                        child: Text(
                          'No leads found',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 4.w,
                          right: 4.w,
                          bottom: MediaQuery.of(context).padding.bottom + 2.h,
                        ),
                        itemCount:
                            visibleLeads.length +
                            (hasMore || _isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 2.h),
                        itemBuilder: (context, index) {
                          if (index >= visibleLeads.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Center(
                                child: _isLoadingMore
                                    ? const CircularProgressIndicator()
                                    // hasMore but not yet loading (just
                                    // scrolled into range) — reserve space,
                                    // no spinner needed here since
                                    // _onScroll will flip _isLoadingMore
                                    // almost immediately.
                                    : const SizedBox.shrink(),
                              ),
                            );
                          }

                          final lead = visibleLeads[index];

                          return LeadReportCard(
                            lead: lead,
                            onFollowUp: () {},
                            onCall: () {
                              launchPhoneCall(context, lead.contactNumber);
                            },
                            onWhatsApp: () {
                              launchWhatsApp(
                                context,
                                leads[index].whatsappNumber.isNotEmpty
                                    ? leads[index].whatsappNumber
                                    : leads[index].contactNumber,
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
