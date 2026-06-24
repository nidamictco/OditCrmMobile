import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/feature/lead_details/widgets/info_row.dart';
import 'package:odit_crm_mobile/feature/lead_details/widgets/lead_details_info_card.dart';
import 'package:odit_crm_mobile/feature/lead_details/widgets/lead_handled_staff_card.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:sizer/sizer.dart';

class LeadDetailsTab extends StatelessWidget {
  final AddLeadModel lead;

  const LeadDetailsTab({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 1.w,
        vertical: 1.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Client Info Card
          LeadDetailsInfoCard(
            title: 'Client Info',
            children: [
              InfoRow(title: 'Client Name', value: lead.clientName),
              InfoRow(title: 'Phone', value: lead.contactNumber),
              InfoRow(title: 'WhatsApp Number', value: lead.whatsappNumber),
              InfoRow(title: 'Email', value: lead.email),
              InfoRow(title: 'Address', value: lead.address),
              InfoRow(title: 'State', value: lead.state),
              InfoRow(title: 'District', value: lead.district),
              InfoRow(title: 'PIN Code', value: lead.pinCode),
              InfoRow(title: 'Post Office', value: lead.postOffice),
            ],
          ),

          // Section 2: Lead Info Card
          LeadDetailsInfoCard(
            title: 'Lead Info',
            children: [
              InfoRow(title: 'Created date', value: lead.createdAt.toString()),
              InfoRow(title: 'Created by', value: lead.createdBy),
              InfoRow(title: 'Lead Source', value: lead.leadSource),
              InfoRow(title: 'Lead Stage', value: lead.leadStage),
              InfoRow(title: 'Category', value: lead.leadCategory),
              InfoRow(title: 'Remark', value: lead.remarks),
            ],
          ),

          // Section 3: Lead Handled Staff Card
          LeadDetailsInfoCard(
            title: 'Lead Handled Staff',
            children: [
              LeadHandledStaffCard(
                name: lead.createdBy.isNotEmpty ? lead.createdBy : 'Fairooza',
                phone: lead.contactNumber,
                // callCount: lead.,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
