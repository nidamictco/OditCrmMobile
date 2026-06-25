import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_card.dart';
import 'package:sizer/sizer.dart';

class LeadListWidget extends StatelessWidget {
  final List<LeadData> leads;
  final List<ValueNotifier<bool>> closeNotifiers;
  final void Function(int index) onToggleExpand;
  final void Function(int index) onSwipeOpen;

  const LeadListWidget({
    super.key,
    required this.leads,
    required this.closeNotifiers,
    required this.onToggleExpand,
    required this.onSwipeOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (leads.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            'No Data Found',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.h),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leads.length,
        separatorBuilder: (_, __) => SizedBox(height: 1.2.h),
        itemBuilder: (context, index) {
          final lead = leads[index];
          return LeadCard(
            data: lead,
            closeNotifier: closeNotifiers[index],
            onSwipeOpen: () => onSwipeOpen(index), 
            onToggleExpand: () => onToggleExpand(index),
            onCall: () => launchPhoneCall(context, lead.phone),
            onMessage: () => launchWhatsApp(context, lead.phone),
          );
        },
      ),
    );
  }
}
