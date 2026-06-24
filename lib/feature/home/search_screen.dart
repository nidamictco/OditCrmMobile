import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:odit_crm_mobile/feature/lead_details/presentation/lead_details_screen.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_card.dart';
import 'package:sizer/sizer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ValueNotifier<bool>> _closeNotifiers = [];

  @override
  void initState() {
    super.initState();
    final leadCubit = context.read<AddLeadCubit>();
    if (leadCubit.state.listStatus != LeadListStatus.loaded) {
      leadCubit.fetchLeads();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final n in _closeNotifiers) {
      n.dispose();
    }
    super.dispose();
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

  List<AddLeadModel> _filterLeads(List<AddLeadModel> leads, String query) {
    if (query.trim().isEmpty) return leads;
    final q = query.toLowerCase().trim();
    return leads.where((lead) {
      return lead.clientName.toLowerCase().contains(q) ||
          lead.contactNumber.toLowerCase().contains(q);
    }).toList();
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
            if (state.listStatus == LeadListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.listStatus == LeadListStatus.failure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    state.listError ?? 'Failed to load leads',
                    style: TextStyle(color: Colors.red, fontSize: 16.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final filteredLeads = _filterLeads(state.leads, _searchQuery);
            _syncCloseNotifiers(filteredLeads.length);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                  SizedBox(height: 2.h),

                  LeadHeaderCard(
                    title: 'Leads',
                    subtitle: '${filteredLeads.length} records found',
                  ),
                  SizedBox(height: 2.h),

                  if (filteredLeads.isEmpty) ...[
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
                            'No leads found',
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
                              'Try searching with another name or phone number',
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
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredLeads.length,
                      separatorBuilder: (_, __) => SizedBox(height: 2.h),
                      itemBuilder: (_, index) {
                        final lead = filteredLeads[index];
                        return SearchLeadCard(
                          id: lead.id ?? '',
                          name: lead.clientName.isEmpty
                              ? 'Unknown'
                              : lead.clientName,
                          phone: lead.contactNumber,
                          tag: lead.leadCategory.isEmpty
                              ? 'General'
                              : lead.leadCategory,
                          assignedTo: lead.assignedStaff.isEmpty
                              ? 'Unassigned'
                              : lead.assignedStaff,
                          status: lead.leadStage.isEmpty
                              ? 'New'
                              : lead.leadStage,
                          nextFollowUp: _getFollowUpText(lead),
                          lastCall: _formatDate(lead.calledDate),
                          leadSource: lead.leadSource.isEmpty
                              ? 'Direct Entry'
                              : lead.leadSource,
                          priority: lead.priority.isEmpty
                              ? 'Normal'
                              : lead.priority,
                          closeNotifier: _closeNotifiers[index],
                          onSwipeOpen: () => _onSwipeOpen(index),
                        );
                      },
                    ),
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
  final ValueChanged<String> onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
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
              onChanged: onChanged,
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
            ),
          ),
          SizedBox(width: 2.w),
          Padding(
            padding: EdgeInsets.only(right: 2.5.w),
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
          Icon(
            Icons.keyboard_arrow_up_rounded,
            color: const Color(0xFF666666),
            size: 6.w,
          ),
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
  final String tag;
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
    required this.tag,
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
                              leadCategory: widget.tag,
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
                      tag: widget.tag,
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
  final String tag;
  final String assignedTo;
  final String status;
  final String nextFollowUp;
  final String lastCall;

  const _SearchLeadCardBody({
    required this.name,
    required this.phone,
    required this.tag,
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
                  label: tag,
                  textColor: const Color(0xFF2F80ED),
                  backgroundColor: const Color(0xFFDEEDFF),
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
                print('ffffffffffff');
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
