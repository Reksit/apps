enum EventStatus { pending, approved, rejected, cancelled, completed }

enum EventType { alumniInitiated, managementRequested }

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String organizerId;
  final String organizerName;
  final String organizerEmail;
  final EventStatus status;
  final EventType type;
  final String? specialRequirements;
  final String? rejectionReason;
  final String? approvedBy;
  final String? rejectedBy;
  final DateTime submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final List<String> attendees;
  final String? department;
  final String? targetAudience;
  final int? maxAttendees;
  final String? contactEmail;
  final String? contactPhone;
  final String? requestedBy;
  final String? requestedByName;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDateTime,
    this.endDateTime,
    required this.organizerId,
    required this.organizerName,
    required this.organizerEmail,
    required this.status,
    required this.type,
    this.specialRequirements,
    this.rejectionReason,
    this.approvedBy,
    this.rejectedBy,
    required this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
    required this.attendees,
    this.department,
    this.targetAudience,
    this.maxAttendees,
    this.contactEmail,
    this.contactPhone,
    this.requestedBy,
    this.requestedByName,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startDateTime: DateTime.parse(json['startDateTime'] ?? DateTime.now().toIso8601String()),
      endDateTime: json['endDateTime'] != null ? DateTime.parse(json['endDateTime']) : null,
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'] ?? '',
      organizerEmail: json['organizerEmail'] ?? '',
      status: _parseEventStatus(json['status']),
      type: _parseEventType(json['type']),
      specialRequirements: json['specialRequirements'],
      rejectionReason: json['rejectionReason'],
      approvedBy: json['approvedBy'],
      rejectedBy: json['rejectedBy'],
      submittedAt: DateTime.parse(json['submittedAt'] ?? DateTime.now().toIso8601String()),
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      rejectedAt: json['rejectedAt'] != null ? DateTime.parse(json['rejectedAt']) : null,
      attendees: (json['attendees'] as List<dynamic>?)?.cast<String>() ?? [],
      department: json['department'],
      targetAudience: json['targetAudience'],
      maxAttendees: json['maxAttendees'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      requestedBy: json['requestedBy'],
      requestedByName: json['requestedByName'],
    );
  }

  static EventStatus _parseEventStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return EventStatus.pending;
      case 'APPROVED':
        return EventStatus.approved;
      case 'REJECTED':
        return EventStatus.rejected;
      case 'CANCELLED':
        return EventStatus.cancelled;
      case 'COMPLETED':
        return EventStatus.completed;
      default:
        return EventStatus.pending;
    }
  }

  static EventType _parseEventType(String? type) {
    switch (type?.toUpperCase()) {
      case 'ALUMNI_INITIATED':
        return EventType.alumniInitiated;
      case 'MANAGEMENT_REQUESTED':
        return EventType.managementRequested;
      default:
        return EventType.alumniInitiated;
    }
  }

  String get statusDisplay {
    switch (status) {
      case EventStatus.pending:
        return 'Pending';
      case EventStatus.approved:
        return 'Approved';
      case EventStatus.rejected:
        return 'Rejected';
      case EventStatus.cancelled:
        return 'Cancelled';
      case EventStatus.completed:
        return 'Completed';
    }
  }

  String get typeDisplay {
    switch (type) {
      case EventType.alumniInitiated:
        return 'Alumni Initiated';
      case EventType.managementRequested:
        return 'Management Requested';
    }
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startDateTime);
  }

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && 
           (endDateTime == null || now.isBefore(endDateTime!));
  }

  bool get isPast {
    return endDateTime != null && DateTime.now().isAfter(endDateTime!);
  }

  String get formattedDate {
    return '${startDateTime.day}/${startDateTime.month}/${startDateTime.year}';
  }

  String get formattedTime {
    final hour = startDateTime.hour.toString().padLeft(2, '0');
    final minute = startDateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDateTime {
    return '$formattedDate at $formattedTime';
  }
}