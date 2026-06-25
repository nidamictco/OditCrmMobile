import 'package:equatable/equatable.dart';

class GeneralSettingsModel extends Equatable {
  const GeneralSettingsModel({
    this.newLead = true,
    this.facebookLead = true,
    this.transferLead = true,
    this.whatsapp = false,
    this.cloudCall = true,
    this.phoneCall = false,
    this.autoAssign = false,
  });

  final bool newLead;
  final bool facebookLead;
  final bool transferLead;
  final bool whatsapp;
  final bool cloudCall;
  final bool phoneCall;
  final bool autoAssign;

  @override
  List<Object?> get props => [
    newLead, facebookLead, transferLead,
    whatsapp, cloudCall, phoneCall, autoAssign,
  ];

  factory GeneralSettingsModel.fromMap(Map<String, dynamic> map) {
    return GeneralSettingsModel(
      newLead:      map['newLead']      ?? true,
      facebookLead: map['facebookLead'] ?? true,
      transferLead: map['transferLead'] ?? true,
      whatsapp:     map['whatsapp']     ?? false,
      cloudCall:    map['cloudCall']    ?? true,
      phoneCall:    map['phoneCall']    ?? false,
      autoAssign:   map['autoAssign']   ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'newLead':      newLead,
    'facebookLead': facebookLead,
    'transferLead': transferLead,
    'whatsapp':     whatsapp,
    'cloudCall':    cloudCall,
    'phoneCall':    phoneCall,
    'autoAssign':   autoAssign,
  };

  GeneralSettingsModel copyWith({
    bool? newLead,
    bool? facebookLead,
    bool? transferLead,
    bool? whatsapp,
    bool? cloudCall,
    bool? phoneCall,
    bool? autoAssign,
  }) {
    return GeneralSettingsModel(
      newLead:      newLead      ?? this.newLead,
      facebookLead: facebookLead ?? this.facebookLead,
      transferLead: transferLead ?? this.transferLead,
      whatsapp:     whatsapp     ?? this.whatsapp,
      cloudCall:    cloudCall    ?? this.cloudCall,
      phoneCall:    phoneCall    ?? this.phoneCall,
      autoAssign:   autoAssign   ?? this.autoAssign,
    );
  }
}