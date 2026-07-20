import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/utils/lead_name_resolver.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/info_row.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/lead_details_info_card.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/lead_handled_staff_card.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/data/subCategory.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';
import 'package:sizer/sizer.dart';

class LeadDetailsTab extends StatelessWidget {
  final AddLeadModel lead;

  const LeadDetailsTab({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
     final state = context.watch<AddLeadCubit>().state;

  final categoryName = resolveLeadName(
    state.categories, lead.leadCategoryId, lead.leadCategory,
  );
  final stageDisplay = humanizeStageName(
    resolveLeadName(state.stages, lead.leadStageId, lead.leadStage),
  );
  final sourceName = resolveLeadName(
    state.sources, lead.leadSourceId, lead.leadSource,
  );
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
              InfoRow(title: 'Lead Source', value:sourceName),
              InfoRow(title: 'Lead Stage', value: stageDisplay),
             InfoRow(title: 'Category', value: categoryName),           // NEW — split out
    _SubCategoryNameRow(                                        // NEW
      categoryId: lead.leadCategoryId,
      subCategoryId: lead.leadSubCategoryId,
      fallbackName: lead.leadSubCategory,
    ),
              InfoRow(title: 'Remark', value: lead.remarks), 
            ],
          ),

          // Section 3: Additional Details Card
          //
          // The AddLeadCubit is already provided by LeadDetailsScreen via
          // BlocProvider.value — no extra BlocProvider is needed here.
          //
          // state.additionalFields (List<AdditionalFieldModel>) is populated
          // inside AddLeadCubit.initialize() which is called in
          // LeadDetailsScreen.initState(). The BlocBuilder rebuilds this
          // section once the definitions finish loading, so there is no
          // race condition.
          //
          // Key resolution: lead.additionalFields stores {fieldId: value}.
          // We match each fieldId against AdditionalFieldModel.id and
          // display AdditionalFieldModel.fieldName as the row title.
          // If the document was deleted from ADDITIONAL_FIELD, the raw
          // fieldId is shown as a safe fallback.
          if (lead.additionalFields?.isNotEmpty ?? false)
            BlocBuilder<AddLeadCubit, AddLeadState>(
              buildWhen: (prev, curr) =>
                  prev.additionalFields != curr.additionalFields ||
                  prev.isLoadingAdditionalFields !=
                      curr.isLoadingAdditionalFields,
              builder: (context, state) {
                return LeadDetailsInfoCard(
                  title: 'Additional Details',
                  children: lead.additionalFields!.entries.map((entry) {
                    // Resolve field ID → human-readable fieldName.
                    // Falls back to entry.key if the definition is still
                    // loading or the field no longer exists.
                    final matchedField = state.additionalFields
                        .where((field) => field.id == entry.key)
                        .firstOrNull;

                    final title = matchedField?.fieldName ?? entry.key;

                    return InfoRow(title: title, value: entry.value);
                  }).toList(),
                );
              },
            ),

          // Section 4: Lead Handled Staff Card
          LeadDetailsInfoCard(
            title: 'Lead Handled Staff',
            children: [
              LeadHandledStaffCard(
                name: lead.createdBy.isNotEmpty ? lead.createdBy : 'Fairooza',
                phone: lead.contactNumber,
              
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// NEW — resolves Sub Category name by ID, independently of AddLeadCubit's
// shared state.subCategories (which is scoped to the Follow Up form's
// currently-selected category, not necessarily this lead's category).
// Opens its own scoped stream against lead.leadCategoryId so it can never
// show a name resolved against the wrong category.
class _SubCategoryNameRow extends StatefulWidget {
  final String categoryId;
  final String subCategoryId;
  final String fallbackName;

  const _SubCategoryNameRow({
    required this.categoryId,
    required this.subCategoryId,
    required this.fallbackName,
  });

  @override
  State<_SubCategoryNameRow> createState() => _SubCategoryNameRowState();
}

class _SubCategoryNameRowState extends State<_SubCategoryNameRow> {
  Stream<List<LeadsModel>>? _stream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  @override
  void didUpdateWidget(covariant _SubCategoryNameRow old) {
    super.didUpdateWidget(old);
    // Only re-subscribe if this row now points at a different category
    // (e.g. the parent's `lead` changed) — avoids resubscribing on every
    // unrelated rebuild.
    if (old.categoryId != widget.categoryId) {
      _initStream();
    }
  }

  void _initStream() {
    _stream = widget.categoryId.isEmpty
        ? null
        : SubCategoryRepository(categoryId: widget.categoryId).watchSubCategories();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subCategoryId.isEmpty || _stream == null) {
      // Nothing to resolve — fall back to the stored name, or show nothing.
      return widget.fallbackName.isEmpty
          ? const SizedBox.shrink()
          : InfoRow(title: 'Sub Category', value: widget.fallbackName);
    }

    return StreamBuilder<List<LeadsModel>>(
      stream: _stream,
      builder: (context, snapshot) {
        final resolved = resolveLeadName(
          snapshot.data ?? const [],
          widget.subCategoryId,
          widget.fallbackName,
        );
        if (resolved.isEmpty) return const SizedBox.shrink();
        return InfoRow(title: 'Sub Category', value: resolved);
      },
    );
  }
}