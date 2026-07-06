import 'dart:convert';
import 'package:flutter/services.dart';

class IndiaLocationService {
  static Map<String, List<String>>? _cache;

  // static Future<Map<String, List<String>>> loadStateDistricts() async {
  //   if (_cache != null) return _cache!;

  //   final jsonStr = await rootBundle.loadString(
  //     'assets/data/india_states_districts.json',
  //   );
  //   final data = json.decode(jsonStr) as Map<String, dynamic>;
  //   final states = data['states'] as List<dynamic>;

  //   _cache = {
  //     for (final s in states)
  //       s['state'] as String: List<String>.from(s['districts'] as List),
  //   };

  //   return _cache!;
  // }
  static Future<Map<String, List<String>>> loadStateDistricts() async {
  if (_cache != null) return _cache!;

  try {
    final jsonStr = await rootBundle.loadString(
      'assets/data/india_states_district.json',
    );
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final states = data['states'] as List<dynamic>;

    _cache = {
      for (final s in states)
        s['state'] as String: List<String>.from(s['districts'] as List),
    };

    return _cache!;
  } catch (e) {
    print('❌ IndiaLocationService error: $e'); 
    return {};
  }
}
}