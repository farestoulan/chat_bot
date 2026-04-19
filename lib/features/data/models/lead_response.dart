/// Response model for lead creation API
class LeadResponse {
  final bool success;
  final int? leadId;
  final String message;

  const LeadResponse({
    required this.success,
    this.leadId,
    required this.message,
  });

  factory LeadResponse.fromJson(Map<String, dynamic> json) => LeadResponse(
        success: json['success'] as bool? ?? false,
        leadId: (json['lead_id'] as num?)?.toInt(),
        message: json['message'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'lead_id': leadId,
        'message': message,
      };
}
