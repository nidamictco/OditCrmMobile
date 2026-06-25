class LeadDetailsModel {
  final String leadName;
  final String leadStatus;
  final String leadCategory;
  final String phoneNumber;
  final String assignedStaff;
  final String leadSource;
  final String createdDate;
  final String leadFolder;

  final String clientName;
  final String whatsappNumber;
  final String email;
  final String address;
  final String state;
  final String district;
  final String pinCode;
  final String postOffice;
  final String createdBy;
  final String product;
  final String cost;
  final String subCategory;
  final String remark;

  const LeadDetailsModel({
    required this.leadName,
    required this.leadStatus,
    required this.leadCategory,
    required this.phoneNumber,
    required this.assignedStaff,
    required this.leadSource,
    required this.createdDate,
    required this.leadFolder,
    this.clientName = '',
    this.whatsappNumber = '',
    this.email = '',
    this.address = '',
    this.state = '',
    this.district = '',
    this.pinCode = '',
    this.postOffice = '',
    this.createdBy = '',
    this.product = '',
    this.cost = '',
    this.subCategory = '',
    this.remark = '',
  });
}
