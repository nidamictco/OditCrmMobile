import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';

/// Resolves a display name from an already-loaded LeadsModel list by ID.
/// Falls back to `fallback` (the raw/stored value on the lead) when the ID
/// is empty, not yet loaded, or the record was deleted — so a rename never
/// shows a blank field and a still-loading list never crashes anything.
///
/// This is what makes renamed categories/stages/sources show their CURRENT
/// name everywhere, instead of whatever string got copied onto the lead
/// document back when it was created.
String resolveLeadName(List<LeadsModel> list, String id, String fallback) {
  if (id.isEmpty) return fallback;
  final match = list.where((m) => m.id == id);
  if (match.isEmpty) return fallback;
  final name = match.first.name;
  return name.isEmpty ? fallback : name;
}

/// Humanizes stage codes for UI display only (e.g. "FOLLOWUP" -> "Follow Up").
/// NEVER use this for filtering/counting/business logic — those must keep
/// reading the raw code.
String humanizeStageName(String raw) {
  final upper = raw.trim().toUpperCase();
  const specialCases = {
    'FOLLOWUP': 'Follow Up',
    'NEW': 'New',
    'TRANSFERRED': 'Transferred',
    'CLOSED': 'Closed',
  };
  if (specialCases.containsKey(upper)) return specialCases[upper]!;
  if (raw.isEmpty) return raw;
  return raw
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}