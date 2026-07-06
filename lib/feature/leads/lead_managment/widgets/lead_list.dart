import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/home/search_screen.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/add_lead.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/filtering.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/status_card.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/section_header.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_list_widget.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/report_section.dart';
import 'package:sizer/sizer.dart';
export 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LeadFilter — single source of truth for all filtering and counting rules.
//
// Rules (no date filter active):
//   New          → leadStage == NEW  (no date restriction)
//   Followup     → leadStage == FOLLOWUP && (followUpDate == today
//                   OR followUpDate < today) && NOT completed today
//   Missed       → (NEW && createdAt < today)
//                   OR (FOLLOWUP && followUpDate < today)
//                   OR (TRANSFERRED && followUpDate < today)
//   Called       → latest followUp.calledDate == today
//   Transferred  → leadStage == TRANSFERRED  (no date restriction)
//   Closed       → leadStage == CLOSED       (no date restriction)
//
// Rules (date filter active — replace "today" with the selected window):
//   New          → leadStage == NEW && createdAt inside [from, to]
//   Followup     → leadStage == FOLLOWUP && (followUpDate inside [from, to]
//                   OR followUpDate < from) && NOT completed inside [from, to]
//   Missed       → (NEW && createdAt < from)
//                   OR (FOLLOWUP && followUpDate < from)
//                   OR (TRANSFERRED && followUpDate < from)
//   Called       → latest followUp.calledDate inside [from, to]
//   Transferred  → leadStage == TRANSFERRED && createdAt inside [from, to]
//   Closed       → leadStage == CLOSED && createdAt inside [from, to]
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// LeadFilter — UNCHANGED. All predicates, window logic, and rules are exactly
// as before. Pagination never touches filtering — it only windows the final
// filtered+sorted list before it's handed to the widget.
// ─────────────────────────────────────────────────────────────────────────────
class LeadFilter {
  final FilterResult? appliedFilters;

  late final DateTime _windowStart;
  late final DateTime _windowEnd;
  late final bool _hasDateFilter;

  LeadFilter(this.appliedFilters) {
    _hasDateFilter = _computeHasDateFilter();
    _windowStart = _computeWindowStart();
    _windowEnd = _computeWindowEnd();
  }

  // bool _computeHasDateFilter() {
  //   if (appliedFilters == null) return false;
  //   final today = _todayString();
  //   return appliedFilters!.fromDate != today || appliedFilters!.toDate != today;
  // }

bool _computeHasDateFilter() {
  if (appliedFilters == null) return false;
  return appliedFilters!.fromDate.isNotEmpty && appliedFilters!.toDate.isNotEmpty;
}

  DateTime _computeWindowStart() {
    if (!_hasDateFilter || appliedFilters == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    final parsed = _parseDate(appliedFilters!.fromDate);
    if (parsed == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  DateTime _computeWindowEnd() {
    if (!_hasDateFilter || appliedFilters == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
    final parsed = _parseDate(appliedFilters!.toDate);
    if (parsed == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
    return DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);
  }

  bool _isInWindow(DateTime date) =>
      !date.isBefore(_windowStart) && !date.isAfter(_windowEnd);

  bool _isBeforeWindow(DateTime date) => date.isBefore(_windowStart);

  dynamic _rawFor(String id, List<dynamic> rawLeads) {
    for (final r in rawLeads) {
      if (r != null && r.id == id) return r;
    }
    return null;
  }

  bool passesSecondaryFilters(LeadData lead) {
    if (appliedFilters == null) return true;

    final staff = appliedFilters!.selectedItems['Assigned Staff'];
    if (staff != null && staff.isNotEmpty) {
      if (!staff.any((s) => lead.assignedTo.toLowerCase() == s.toLowerCase())) {
        return false;
      }
    }

    final category = appliedFilters!.selectedItems['Category'];
    if (category != null && category.isNotEmpty) {
      if (!category.any(
        (c) => lead.category.toLowerCase() == c.toLowerCase(),
      )) {
        return false;
      }
    }

    final priority = appliedFilters!.selectedItems['Priority'];
    if (priority != null && priority.isNotEmpty) {
      if (!priority.any(
        (p) => lead.priority.toLowerCase() == p.toLowerCase(),
      )) {
        return false;
      }
    }

    return true;
  }

  bool isNew(LeadData lead) {
    if (lead.status.toUpperCase() != 'NEW') return false;
    if (!_hasDateFilter) return true;
    if (lead.createdAt == null) return false;
    return _isInWindow(lead.createdAt!);
  }

  bool isFollowup(LeadData lead, List<dynamic> rawLeads) {
    final raw = _rawFor(lead.id, rawLeads);
    if (raw == null) return false;
    if (raw.leadStage.toString().toUpperCase() != 'FOLLOWUP') return false;

    final followUpDate = raw.followUpDate as DateTime?;
    if (followUpDate == null) return false;

    final inWindow = _isInWindow(followUpDate);
    final beforeWindow = _isBeforeWindow(followUpDate);

    if (!inWindow && !beforeWindow) return false;
    if (_isCompletedInWindow(raw)) return false;

    return true;
  }

  bool _isCompletedInWindow(dynamic raw) {
    final followups = raw.followUp;
    if (followups == null || followups.isEmpty) return false;
    dynamic latest;
    for (final f in followups) {
      if (latest == null ||
          (f.calledDate as DateTime).isAfter(latest.calledDate as DateTime)) {
        latest = f;
      }
    }
    if (latest == null) return false;
    return _isInWindow(latest.calledDate as DateTime);
  }

  bool isFollowupInWindow(dynamic raw) {
    if (raw.leadStage.toString().toUpperCase() != 'FOLLOWUP') return false;
    final followUpDate = raw.followUpDate as DateTime?;
    if (followUpDate == null) return false;
    return _isInWindow(followUpDate) && !_isCompletedInWindow(raw);
  }

  bool isFollowupPending(dynamic raw) {
    if (raw.leadStage.toString().toUpperCase() != 'FOLLOWUP') return false;
    final followUpDate = raw.followUpDate as DateTime?;
    if (followUpDate == null) return false;
    return _isBeforeWindow(followUpDate) && !_isCompletedInWindow(raw);
  }

  bool isMissed(LeadData lead, List<dynamic> rawLeads) {
    final raw = _rawFor(lead.id, rawLeads);
    if (raw == null) return false;

    final stage = raw.leadStage.toString().toUpperCase();

    if (stage == 'NEW') {
      if (lead.createdAt == null) return false;
      return _isBeforeWindow(lead.createdAt!);
    }

    if (stage == 'FOLLOWUP') {
      final followUpDate = raw.followUpDate as DateTime?;
      if (followUpDate == null) return false;
      return _isBeforeWindow(followUpDate);
    }

    if (stage == 'TRANSFERRED') {
      final followUpDate = raw.followUpDate as DateTime?;
      if (followUpDate == null) return false;
      return _isBeforeWindow(followUpDate);
    }

    return false;
  }

  bool isCalled(LeadData lead, List<dynamic> rawLeads) {
    final raw = _rawFor(lead.id, rawLeads);
    if (raw == null) return false;

    final followups = raw.followUp;
    if (followups == null || followups.isEmpty) return false;

    dynamic latest;
    for (final f in followups) {
      if (latest == null ||
          (f.calledDate as DateTime).isAfter(latest.calledDate as DateTime)) {
        latest = f;
      }
    }
    if (latest == null) return false;

    return _isInWindow(latest.calledDate as DateTime);
  }

  bool isTransferred(LeadData lead) {
    if (lead.status.toUpperCase() != 'TRANSFERRED') return false;
    if (!_hasDateFilter) return true;
    if (lead.createdAt == null) return false;
    return _isInWindow(lead.createdAt!);
  }

  bool isClosed(LeadData lead) {
    if (lead.status.toUpperCase() != 'CLOSED') return false;
    if (!_hasDateFilter) return true;
    if (lead.createdAt == null) return false;
    return _isInWindow(lead.createdAt!);
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

  static String _todayString() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LeadListScreen
// ─────────────────────────────────────────────────────────────────────────────
class LeadListScreen extends StatefulWidget {
  final int selectedTab;
  final String? initialStatus;

  const LeadListScreen({
    super.key,
    required this.selectedTab,
    this.initialStatus = 'New',
  });

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  // ── UI state ──────────────────────────────────────────────────────────────
  bool _isReportView = false;
  late String _selectedStatus;
  bool _sortByNewest = true;
  bool _isFirstLoad = true;

  // ── Filter state ──────────────────────────────────────────────────────────
  FilterResult? _appliedFilters;

  // ── Swipe / expand state ──────────────────────────────────────────────────
  List<ValueNotifier<bool>> _closeNotifiers = [];
  final Set<String> _expandedLeadPhones = {};

  // ── PAGINATION STATE ──────────────────────────────────────────────────────
  // NEW: how many leads from the filtered+sorted list are currently visible.
  static const int _pageSize = 10;
  int _visibleCount = _pageSize;
  // NEW: guards against firing multiple "load more" batches concurrently.
  bool _isLoadingMore = false;
  // NEW: ScrollController to detect when the user nears the bottom of the
  // CustomScrollView. Attached to the outer scroll view since the inner
  // ListView is shrinkWrap+NeverScrollableScrollPhysics (it scrolls with
  // the parent), so listening here correctly captures real scroll position.
  final ScrollController _scrollController = ScrollController();

  // NEW: tracks the last filter/sort/status signature so we can detect
  // "did the active filter set change" and reset pagination accordingly,
  // per requirement #11. We compare a lightweight signature instead of
  // deep-equality on FilterResult to avoid extra dependencies.
  String _lastFilterSignature = '';

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus ?? 'New';
    log('[LeadListScreen] initState() called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        log('[LeadListScreen] fetchLeads() on init');
        context.read<AddLeadCubit>().watchLeadsRealtime();
      }
    });

    // NEW: attach scroll listener for infinite scroll detection.
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    for (final n in _closeNotifiers) {
      n.dispose();
    }
    // NEW: remove listener + dispose the scroll controller to avoid leaks.
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ── NEW: Scroll listener — triggers loading the next batch ────────────────
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    // Trigger when within 300px of the bottom — feels smooth, loads ahead
    // of the user actually hitting the very last pixel.
    final nearBottom = position.pixels >= position.maxScrollExtent - 300;

    if (nearBottom) {
      _loadMoreIfNeeded();
    }
  }

  // ── NEW: Loads the next batch of leads (UI-side — just reveals more of
  // the already-fetched, already-filtered list). Structured so that when
  // Firestore-side pagination (limit()/startAfterDocument()) is introduced
  // later, only this method needs to change to trigger a repository call
  // instead of incrementing _visibleCount.
  void _loadMoreIfNeeded({int? totalAvailable}) {
    if (_isLoadingMore) return; // prevent duplicate concurrent loads
    if (totalAvailable != null && _visibleCount >= totalAvailable) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate the "fetch" tick so the spinner is visible even though this
    // is just revealing already-loaded local data. When real Firestore
    // pagination is added, replace this Future.delayed block with the
    // actual repository call (e.g. fetchLeadsPage(startAfter: ...)) and
    // append results instead of just bumping _visibleCount.
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _visibleCount += _pageSize;
        _isLoadingMore = false;
      });
    });
  }

  // ── NEW: Resets pagination back to the first page. Called whenever the
  // active status tab, filters, or sort order changes (requirement #11).
  void _resetPagination() {
    setState(() {
      _visibleCount = _pageSize;
      _isLoadingMore = false;
    });
  }

  // ── Mapped leads — UNCHANGED ───────────────────────────────────────────────

  List<LeadData> _mapLeads(List<dynamic> firestoreLeads) {
    return firestoreLeads.map((lead) {
      return LeadData(
        id: lead.id ?? '',
        name: lead.clientName,
        phone: lead.contactNumber,
        assignedTo: lead.assignedStaff,
        category: lead.leadCategory.isEmpty
            ? 'Uncategorized'
            : lead.leadCategory,
        status: lead.leadStage,
        notificationCount: 0,
        isExpanded: _expandedLeadPhones.contains(lead.contactNumber),
        source: lead.leadSource,
        priority: lead.priority,
        createdAt: lead.createdAt,
      );
    }).toList();
  }

  // ── Filtered list for the active status tab — UNCHANGED logic, this still
  // returns the FULL filtered+sorted list. Pagination windowing happens
  // separately in build(), after this and _applySorting() run, so that
  // status counts (#9) always see the complete filtered set.

  List<LeadData> _getFilteredLeads(
    List<LeadData> mappedLeads,
    List<dynamic> rawLeads,
    LeadFilter filter,
  ) {
    final candidates = mappedLeads
        .where(filter.passesSecondaryFilters)
        .toList();

    switch (_selectedStatus) {
      case 'New':
        return candidates.where(filter.isNew).toList();

      case 'Followup':
        final todayGroup = <LeadData>[];
        final pendingGroup = <LeadData>[];

        for (final lead in candidates) {
          dynamic raw;
          for (final r in rawLeads) {
            if (r != null && r.id == lead.id) {
              raw = r;
              break;
            }
          }
          if (raw == null) continue;

          if (filter.isFollowupInWindow(raw)) {
            todayGroup.add(lead);
          } else if (filter.isFollowupPending(raw)) {
            pendingGroup.add(lead);
          }
        }

        todayGroup.sort((a, b) {
          dynamic aRaw, bRaw;
          for (final r in rawLeads) {
            if (r != null && r.id == a.id) aRaw = r;
            if (r != null && r.id == b.id) bRaw = r;
          }
          final aDate = aRaw?.followUpDate as DateTime?;
          final bDate = bRaw?.followUpDate as DateTime?;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });

        pendingGroup.sort((a, b) {
          dynamic aRaw, bRaw;
          for (final r in rawLeads) {
            if (r != null && r.id == a.id) aRaw = r;
            if (r != null && r.id == b.id) bRaw = r;
          }
          final aDate = aRaw?.followUpDate as DateTime?;
          final bDate = bRaw?.followUpDate as DateTime?;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });

        return [...todayGroup, ...pendingGroup];

      case 'Missed':
        return candidates.where((l) => filter.isMissed(l, rawLeads)).toList();

      case 'Called':
        return candidates.where((l) => filter.isCalled(l, rawLeads)).toList();

      case 'Transferred':
        return candidates.where(filter.isTransferred).toList();

      case 'Closed':
        return candidates.where(filter.isClosed).toList();

      default:
        return candidates;
    }
  }

  // ── Status card counts — UNCHANGED. Always computed against the FULL
  // candidates list, never the paginated window, satisfying requirement #9.

  Map<String, int> _buildStatusCounts(
    List<LeadData> mappedLeads,
    List<dynamic> rawLeads,
    LeadFilter filter,
  ) {
    final candidates = mappedLeads
        .where(filter.passesSecondaryFilters)
        .toList();

    int followupCount = 0;
    for (final lead in candidates) {
      dynamic raw;
      for (final r in rawLeads) {
        if (r != null && r.id == lead.id) {
          raw = r;
          break;
        }
      }
      if (raw != null &&
          (filter.isFollowupInWindow(raw) || filter.isFollowupPending(raw))) {
        followupCount++;
      }
    }

    return {
      'New': candidates.where(filter.isNew).length,
      'Followup': followupCount,
      'Missed': candidates.where((l) => filter.isMissed(l, rawLeads)).length,
      'Called': candidates.where((l) => filter.isCalled(l, rawLeads)).length,
      'Transferred': candidates.where(filter.isTransferred).length,
      'Closed': candidates.where(filter.isClosed).length,
    };
  }

  // ── Sorting — UNCHANGED ─────────────────────────────────────────────────────

  List<LeadData> _applySorting(List<LeadData> leads) {
    if (_selectedStatus == 'Followup') return leads;
    final sorted = List<LeadData>.from(leads);
    sorted.sort((a, b) {
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return _sortByNewest
          ? b.createdAt!.compareTo(a.createdAt!)
          : a.createdAt!.compareTo(b.createdAt!);
    });
    return sorted;
  }

  // ── Filter-active indicator — UNCHANGED ─────────────────────────────────────

  String _getTodayString() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  // bool get _isFilterActive {
  //   if (_appliedFilters == null) return false;
  //   final todayStr = _getTodayString();
  //   if (_appliedFilters!.fromDate != todayStr ||
  //       _appliedFilters!.toDate != todayStr)
  //     return true;
  //   return _appliedFilters!.selectedItems.values.any((v) => v.isNotEmpty);
  // }
 
  bool get _isFilterActive {
    if (_appliedFilters == null) return false;
    final hasDate =
        _appliedFilters!.fromDate.isNotEmpty && _appliedFilters!.toDate.isNotEmpty;
    final hasCheckbox =
        _appliedFilters!.selectedItems.values.any((v) => v.isNotEmpty);
    return hasDate || hasCheckbox;
  }

  // ── Swipe / expand helpers ────────────────────────────────────────────────
  // UNCHANGED except _getFilteredCloseNotifiers now operates on the
  // paginated (visible) list passed in from build(), so the notifier-to-card
  // mapping stays correct after more leads are appended.

  void _syncCloseNotifiers(int length) {
    if (_closeNotifiers.length != length) {
      for (final n in _closeNotifiers) {
        n.dispose();
      }
      _closeNotifiers = List.generate(length, (_) => ValueNotifier(false));
    }
  }

  List<ValueNotifier<bool>> _getFilteredCloseNotifiers(
    List<LeadData> allLeads,
    List<LeadData> filteredLeads,
  ) {
    return filteredLeads
        .map((lead) => _closeNotifiers[allLeads.indexOf(lead)])
        .toList();
  }

  bool _getAreAllExpanded(List<LeadData> leads) =>
      leads.isNotEmpty && leads.every((l) => l.isExpanded);

  void _toggleAllExpanded(List<LeadData> leads) {
    final expand = !_getAreAllExpanded(leads);
    setState(() {
      for (final lead in leads) {
        if (expand) {
          _expandedLeadPhones.add(lead.phone);
        } else {
          _expandedLeadPhones.remove(lead.phone);
        }
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    log('[LeadListScreen] build() triggered');

    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        if (state.listStatus == LeadListStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_isFirstLoad && state.leads.isNotEmpty) {
          for (final lead in state.leads) {
            _expandedLeadPhones.add(lead.contactNumber);
          }
          _isFirstLoad = false;
        }

        final mappedLeads = _mapLeads(state.leads);
        _syncCloseNotifiers(mappedLeads.length);

        final filter = LeadFilter(_appliedFilters);

        // Full filtered + sorted list (UNCHANGED logic) — this is the
        // "source of truth" used for status counts (#9) and for computing
        // the paginated window below.
        final fullFilteredLeads = _applySorting(
          _getFilteredLeads(mappedLeads, state.leads, filter),
        );

        // NEW: Detect filter/status/sort changes and reset pagination.
        // Signature combines everything that can change which leads are
        // shown or their order — selectedStatus, sort direction, and a
        // cheap hash of applied filters. Comparing this string is far
        // cheaper than deep-comparing FilterResult objects every build.
        final currentSignature =
            '$_selectedStatus|$_sortByNewest|${_appliedFilters?.fromDate}|'
            '${_appliedFilters?.toDate}|${_appliedFilters?.selectedItems}';

        if (currentSignature != _lastFilterSignature) {
          _lastFilterSignature = currentSignature;
          // Reset pagination on the NEXT frame to avoid calling setState
          // during build(). This satisfies requirement #11.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _resetPagination();
          });
        }

        // NEW: Window the full filtered list down to the currently visible
        // page. This is the ONLY list passed to LeadListWidget — the UI,
        // LeadCard, swipe behavior, and expand/collapse logic never know
        // pagination exists.
        final visibleCount = _visibleCount.clamp(0, fullFilteredLeads.length);
        final paginatedLeads = fullFilteredLeads.sublist(0, visibleCount);

        // NEW: whether more leads remain beyond what's currently visible.
        final hasMore = visibleCount < fullFilteredLeads.length;

        final filteredCloseNotifiers = _getFilteredCloseNotifiers(
          mappedLeads,
          paginatedLeads, // NEW: notifiers now sized to the paginated list
        );

        // Status counts ALWAYS use the full filtered list, never the
        // paginated one — satisfies requirement #9.
        final statusCounts = _buildStatusCounts(
          mappedLeads,
          state.leads,
          filter,
        );

        final updatedStatusCards = statusCards.map((card) {
          return card.copyWith(count: statusCounts[card.label] ?? 0);
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            // NEW: reset pagination on pull-to-refresh too, so the user
            // sees the first page again with fresh data (requirement #8
            // — RefreshIndicator continues working exactly as before, just
            // also resets the page window).
            _resetPagination();
            await context.read<AddLeadCubit>().fetchLeads();
          },
          child: Container(
            color: const Color(0xFFF3F4F6),
            child: CustomScrollView(
              // NEW: attach the scroll controller here so _onScroll can
              // read real scroll position of the whole page.
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Static top section — UNCHANGED ────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lead Status',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 1.8.h),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: updatedStatusCards.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2.w,
                                mainAxisSpacing: 2.w,
                                childAspectRatio: 0.99,
                              ),
                          itemBuilder: (context, index) => StatusCard(
                            data: updatedStatusCards[index],
                            isSelected:
                                _selectedStatus ==
                                updatedStatusCards[index].label,
                            onTap: () => setState(() {
                              _selectedStatus = updatedStatusCards[index].label;
                              // NEW: explicit reset here too (in addition to
                              // the signature check) so the tap feels instant
                              // rather than waiting one frame.
                              _visibleCount = _pageSize;
                            }),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        SectionHeader(
                          title: 'Leads',
                          // NEW: subtitle still reflects the TOTAL filtered
                          // count, not just what's visible — matches prior
                          // UX where the count was the full result size.
                          subtitle: '${fullFilteredLeads.length} Leads',
                          isReportActive: _isReportView,
                          areAllExpanded: _getAreAllExpanded(mappedLeads),
                          isFilterActive: _isFilterActive,
                          sortIcon: _sortByNewest
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          sortBgColor: _sortByNewest
                              ? const Color(0xFFF3F4F6)
                              : AppColors.bottomNavBlue,
                          sortIconColor: _sortByNewest
                              ? const Color(0xFF6B7280)
                              : Colors.white,
                          onAdd: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateLeadScreen(),
                              ),
                            );
                            if (context.mounted) {
                              context.read<AddLeadCubit>().fetchLeads();
                            }
                          },
                          onChart: () =>
                              setState(() => _isReportView = !_isReportView),
                          // onFilter: () async {
                          //   final result = await showFilterBottomSheet(
                          //     context,
                          //     initialFilters: _appliedFilters,
                          //   );
                          //   if (result != null) {
                          //     setState(() {
                          //       final todayStr = _getTodayString();
                          //       final hasActiveDate =
                          //           result.fromDate != todayStr ||
                          //           result.toDate != todayStr;
                          //       final hasActiveCheckbox = result
                          //           .selectedItems
                          //           .values
                          //           .any((s) => s.isNotEmpty);
                          //       _appliedFilters =
                          //           (hasActiveDate || hasActiveCheckbox)
                          //           ? result
                          //           : null;
                          //       // NEW: reset pagination immediately on filter
                          //       // apply (requirement #11).
                          //       _visibleCount = _pageSize;
                          //     });
                          //   }
                          // },
                          onFilter: () async {
                            final result = await showFilterBottomSheet(
                              context,
                              initialFilters: _appliedFilters,
                            );
                            if (result != null) {
                              setState(() {
                                _appliedFilters = result.isCleared
                                    ? null
                                    : result;
                                _visibleCount = _pageSize;
                              });
                            }
                          },
                          onSearch: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<AddLeadCubit>(),
                                  child: const SearchScreen(),
                                ),
                              ),
                            );
                          },
                          onDownload: () {
                            setState(() {
                              _sortByNewest = !_sortByNewest;
                              // NEW: reset pagination on sort toggle too.
                              _visibleCount = _pageSize;
                            });
                          },
                          onmenu: () => _toggleAllExpanded(mappedLeads),
                        ),
                        SizedBox(height: 1.5.h),
                      ],
                    ),
                  ),
                ),

                // ── Animated list / report section — UNCHANGED structure ──────
                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _isReportView
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 16.w),
                            child: ReportSection(
                              key: const ValueKey('report'),
                              // Report view uses the FULL filtered list, not
                              // the paginated window — reports should always
                              // reflect the complete filtered data set.
                              leads: fullFilteredLeads,
                              selectedStatus: _selectedStatus,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(bottom: 13.w),
                            child: Column(
                              children: [
                                LeadListWidget(
                                  key: const ValueKey('leads'),
                                  leads: paginatedLeads, // NEW: paginated only
                                  closeNotifiers: filteredCloseNotifiers,
                                  onToggleExpand: (index) {
                                    final lead = paginatedLeads[index];
                                    setState(() {
                                      if (_expandedLeadPhones.contains(
                                        lead.phone,
                                      )) {
                                        _expandedLeadPhones.remove(lead.phone);
                                      } else {
                                        _expandedLeadPhones.add(lead.phone);
                                      }
                                    });
                                  },
                                  onSwipeOpen: (index) {
                                    // NOTE: kept identical to original —
                                    // still references _closeNotifiers (the
                                    // full unfiltered list) exactly as the
                                    // existing code did, to avoid changing
                                    // swipe-close behavior.
                                    for (
                                      int i = 0;
                                      i < _closeNotifiers.length;
                                      i++
                                    ) {
                                      if (i != index) {
                                        _closeNotifiers[i].value = true;
                                        Future.microtask(
                                          () =>
                                              _closeNotifiers[i].value = false,
                                        );
                                      }
                                    }
                                  },
                                ),

                                // NEW: bottom loading indicator — shown only
                                // while a batch is loading. Sits below the
                                // list, inside the same scrollable column,
                                // satisfying requirement #2.
                                if (_isLoadingMore)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2.h,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),

                                // NEW: invisible trigger zone — ensures
                                // _onScroll's "near bottom" check has a
                                // chance to fire even on very short lists
                                // where maxScrollExtent might be small. Also
                                // acts as a manual fallback affordance.
                                if (hasMore && !_isLoadingMore)
                                  SizedBox(
                                    height: 1,
                                    child: Builder(
                                      builder: (context) {
                                        // Fires once when this sliver enters
                                        // the layout pass, covering the edge
                                        // case where content is shorter than
                                        // the viewport (no natural scroll).
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (!_scrollController
                                                  .hasClients) {
                                                return;
                                              }
                                              final pos =
                                                  _scrollController.position;
                                              if (pos.maxScrollExtent <= 0) {
                                                _loadMoreIfNeeded(
                                                  totalAvailable:
                                                      fullFilteredLeads.length,
                                                );
                                              }
                                            });
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
